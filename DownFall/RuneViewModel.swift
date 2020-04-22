//
//  RuneViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol RuneSlotViewModelInputs {
    func wasTapped()
}

protocol RuneSlotViewModelOutputs {
    var charged: ((Int, Int) -> ())? { get }
    var textureName: String? { get }
    var isCharged: Bool { get }
    var runeWasTapped: ((AnyAbility?, Int) -> ())? { get }
}

class RuneSlotViewModel: RuneSlotViewModelOutputs, RuneSlotViewModelInputs {
    
    // Output
    var charged: ((Int, Int) -> ())? = nil
    var runeWasTapped: ((AnyAbility?, Int) -> ())? = nil
    
    var textureName: String? {
        guard let rune = rune else { return nil }
        return rune.textureName
    }
    
    // State variables
    private var rune: AnyAbility?
    private var current: Int = 0 {
        didSet {
            charged?(current, rune?.cooldown ?? 0)
        }
    }
    
    init(rune: AnyAbility?) {
        self.rune = rune
        
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input: input)
        }
    }
    
    var isCharged: Bool {
        guard let cooldown = rune?.cooldown else { return false }
        return current >= cooldown
    }
    
    func wasTapped() {
        runeWasTapped?(rune, current)
    }
    
    private func handle(input: Input) {
        switch input.type {
        case .transformation(let trans):
            trackRuneProgress(with: trans)
            return
        default:
            return
        }
    }
    
    private func trackRuneProgress(with trans: [Transformation]) {
        if let inputType = trans.first?.inputType {
            switch inputType {
            case InputType.touch(_, let type):
                if let count = trans.first?.tileTransformation?.first?.count,
                    (rune?.rechargeType.contains(type) ?? false) {
                    advanceGoal(units: count)
                }
            default:
                return
            }
        }
    }
    
    private func advanceGoal(units: Int) {
        guard let cooldown = rune?.cooldown else { return }
        current += units
        current = min(cooldown, current)
    }
}

class RuneSlot: SKSpriteNode {
    let viewModel: RuneSlotViewModel
    
    struct Constants {
        static let backgroundScale = CGFloat(0.9)
        static let runeScale = CGFloat(0.8)
        static let fillableBarViewName = "fillableBar"
        static let outlineName = "outline"
    }
    
    private var outline: SKShapeNode {
        let goldOutline = SKShapeNode(rectOf: self.frame.size)
        goldOutline.color = viewModel.isCharged ? .goldOutlineBright : .goldOutlineDull
        goldOutline.name = Constants.outlineName
        goldOutline.zPosition = Precedence.background.rawValue
        return goldOutline
    }
    
    private lazy var background: SKShapeNode = {
        let background = SKShapeNode(rectOf: self.frame.size.scale(by: Constants.backgroundScale))
        background.color = .runeBackgroundColor
        background.zPosition = 1
        
        return background
    }()
    
    private lazy var runeSprite: SKSpriteNode? = {
        if let textureName = viewModel.textureName {
            let sprite = SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: self.frame.size.scale(by: Constants.runeScale))
            sprite.zPosition = Precedence.menu.rawValue
            return sprite
        }
        
        return nil
    }()
    
    init(viewModel: RuneSlotViewModel, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        self.viewModel.charged = charged
        self.isUserInteractionEnabled = true
        setupView()
    }
    
    func charged(progress: Int, total: Int) {
        self.removeChild(with: Constants.fillableBarViewName)
        let fillableBar = FillableBar(size: self.size.scale(by: Constants.backgroundScale), viewModel: FillableBarViewModel(total: total, progress: progress, fillColor: .lightBarRed, backgroundColor: nil, text: nil, horiztonal: false))
        fillableBar.name = Constants.fillableBarViewName
        fillableBar.zPosition = Precedence.foreground.rawValue
        addChildSafely(fillableBar)
        
        updateOutline()
    }
    
    func updateOutline() {
        removeChild(with: Constants.outlineName)
        addChildSafely(outline)
    }
    
    private func setupView() {
        addChild(outline)
        addChild(background)
        addChildSafely(runeSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RuneSlot {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.wasTapped()
    }
}
