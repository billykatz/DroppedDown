//
//  RuneDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol RuneDetailViewModelable {
    var ability: AnyAbility? { get }
    var progress: CGFloat { get }
    var confirmed: ((AnyAbility) -> ())? { get set }
    var canceled: (() -> ())? { get set }
    var isCharged: Bool { get }
    var chargeDescription: String? { get }
    
}

struct RuneDetailViewModel: RuneDetailViewModelable {
    var ability: AnyAbility?
    var progress: CGFloat
    var confirmed: ((AnyAbility) -> ())?
    var canceled: (() -> ())?
    
    /// returns true is we have completed the charging of a rune
    var isCharged: Bool {
        guard let rune = ability else { return false }
        return progress >= CGFloat(rune.cooldown)
    }
    
    /// returns a string to display to players that describes how to recahrge the rune
    var chargeDescription: String? {
        guard let rune = ability else { return nil }
        var strings: [String] = []
        for type in rune.rechargeType {
            switch type {
            case .rock:
                let grouped = rune.rechargeMinimum > 1
                if grouped {
                    strings.append("Mine \(rune.cooldown) groups of \(rune.rechargeMinimum) or more.")
                } else {
                    strings.append("Mine \(rune.cooldown) rocks.")
                }
            default:
                break
            }
        }
        strings.removeDuplicates()
        
        return strings.joined(separator: ". ")
    }
}

class RuneDetailView: SKSpriteNode, ButtonDelegate {
    let viewModel: RuneDetailViewModelable
    
    struct Constants {
        static let detailBackgroundScale = CGFloat(0.6)
    }
    
    init(viewModel: RuneDetailViewModelable, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        setupRuneView()
        setupDetailView()
        setupButtons()
    }
    
    func setupRuneView() {
        let viewModel = RuneSlotViewModel(rune: self.viewModel.ability,
                                          registerForUpdates: false,
                                          progress: Int(self.viewModel.progress))
        let runeSlotView = RuneSlotView(viewModel: viewModel,
                                        size: .oneFifty)
        runeSlotView.position = CGPoint.position(runeSlotView.frame, inside: frame, verticalAlign: .center, horizontalAnchor: .left)
        runeSlotView.zPosition = Precedence.foreground.rawValue
        viewModel.runeWasTapped = { [weak self] (_,_) in self?.viewModel.canceled?() }
        addChild(runeSlotView)
        
    }
    
    func setupDetailView() {
        let detailView = SKShapeNode(rectOf: size.scale(by: Constants.detailBackgroundScale))
        detailView.color = .runeDetailColor
        detailView.zPosition = Precedence.background.rawValue
        detailView.position = CGPoint.position(detailView.frame, inside: frame, verticalAlign: .center, horizontalAnchor: .center)
        addChild(detailView)
        
        let textOffset = Style.Padding.less
        
        let titleColumnWidth = CGFloat(180.0)
        let titleContainer = SKSpriteNode(color: .clear, size: CGSize(width: titleColumnWidth, height: detailView.frame.height))
        titleContainer.position = CGPoint.position(titleContainer.frame, inside: detailView.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        /// effect text
        let titleFontSize = UIFont.mediumSize
        let effectTitle = ParagraphNode(text: "Effect:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        let chargeTitle = ParagraphNode(text: "Charge:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        let progressTitle = ParagraphNode(text: "Progress:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        
        progressTitle.position = CGPoint.position(progressTitle.frame, inside: titleContainer.frame, verticalAlign: .bottom, horizontalAnchor: .right, yOffset: textOffset)
        chargeTitle.position = CGPoint.position(chargeTitle.frame, inside: titleContainer.frame, verticalAlign: .center, horizontalAnchor: .right)
        effectTitle.position = CGPoint.position(effectTitle.frame, inside: titleContainer.frame, verticalAlign: .top, horizontalAnchor: .right, yOffset: textOffset)
        
        titleContainer.addChild(progressTitle)
        titleContainer.addChild(chargeTitle)
        titleContainer.addChild(effectTitle)
        
        
        // description container
        let descriptionWidth = detailView.frame.width - titleColumnWidth
        let descriptionContainer = SKSpriteNode(color: .clear, size: CGSize(width: descriptionWidth, height: detailView.frame.height))
        descriptionContainer.position = CGPoint.alignVertically(descriptionContainer.frame, relativeTo: titleContainer.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        
        // description paragraphs
        let descriptionOffset = textOffset + 3.0
        let descriptionFontSize = UIFont.smallSize
        let effectDescription = ParagraphNode(text: viewModel.ability?.description ?? "", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
        let chargeDescription = ParagraphNode(text: viewModel.chargeDescription ?? "", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
        if let ability = viewModel.ability {
            let progressDescription = ParagraphNode(text: "\(Int(viewModel.progress))/\( ability.cooldown)", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
            progressDescription.position = CGPoint.position(progressDescription.frame, inside: descriptionContainer.frame, verticalAlign: .bottom, horizontalAnchor: .left, yOffset: descriptionOffset)
            descriptionContainer.addChild(progressDescription)
        }
        
        effectDescription.position = CGPoint.position(effectDescription.frame, inside: descriptionContainer.frame, verticalAlign: .top, horizontalAnchor: .left, yOffset: descriptionOffset)
        chargeDescription.position = CGPoint.position(chargeDescription.frame, inside: descriptionContainer.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        descriptionContainer.addChild(effectDescription)
        descriptionContainer.addChild(chargeDescription)
        
        detailView.addChild(titleContainer)
        detailView.addChild(descriptionContainer)
        
    }
    
    func setupButtons() {
        if viewModel.ability != nil {
            
            let confirmSprite = SKSpriteNode(texture: SKTexture(imageNamed: "buttonAffirmitive"), size: .oneHundred)
            let confirmButton = Button(size: .oneHundred, delegate: self, identifier: .backpackConfirm, image: confirmSprite, shape: .circle, showSelection: true, disable: !viewModel.isCharged)
            confirmButton.position = CGPoint.position(confirmButton.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: Style.Padding.more)
            addChild(confirmButton)
        }
        
        let cancelSprite = SKSpriteNode(texture: SKTexture(imageNamed: "buttonNegative"), size: .oneHundred)
        let cancelButton = Button(size: .oneHundred, delegate: self, identifier: .backpackCancel, image: cancelSprite, shape: .circle, showSelection: true)
        cancelButton.position = CGPoint.alignHorizontally(cancelButton.frame, relativeTo: frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: Style.Padding.more, horizontalPadding: Style.Padding.more)
        
        addChild(cancelButton)
    }
    
    /// MARK: ButtonDelegate
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .backpackCancel:
            viewModel.canceled?()
        case .backpackConfirm:
            guard let ability = viewModel.ability else { return }
            viewModel.confirmed?(ability)
        default:
            break
        }
    }
    
}
