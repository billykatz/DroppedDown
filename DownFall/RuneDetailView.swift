//
//  RuneDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

struct RuneDetailViewModel {
    var ability: AnyAbility?
    var progress: CGFloat
    var isCharged: Bool {
        guard let rune = ability else { return false }
        return progress >= CGFloat(rune.cooldown)
    }
    
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
    var confirmed: ((AnyAbility) -> ())?
    var canceled: (() -> ())?
}

class RuneDetailView: SKSpriteNode, ButtonDelegate {
    let viewModel: RuneDetailViewModel
    
    struct Constants {
        static let detailBackgroundScale = CGFloat(0.6)
    }
     
    init(viewModel: RuneDetailViewModel, size: CGSize) {
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
        let runeSlotView = RuneSlotView(viewModel: RuneSlotViewModel(rune: viewModel.ability,
                                                                 registerForUpdates: false,
                                                                 progress: Int(viewModel.progress)),
                                    size: .oneFifty)
        runeSlotView.position = CGPoint.position(runeSlotView.frame, inside: frame, verticalAlign: .center, horizontalAnchor: .left)
        runeSlotView.zPosition = Precedence.foreground.rawValue
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
            let confirmButton = Button(size: .oneHundred, delegate: self, identifier: .backpackConfirm, image: confirmSprite, precedence: .foreground, shape: .circle, showSelection: true, disable: !viewModel.isCharged)
            confirmButton.position = CGPoint.position(confirmButton.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: Style.Padding.more)
            addChild(confirmButton)
        }
        
        let cancelSprite = SKSpriteNode(texture: SKTexture(imageNamed: "buttonNegative"), size: .oneHundred)
        let cancelButton = Button(size: .oneHundred, delegate: self, identifier: .backpackCancel, image: cancelSprite, precedence: .foreground, shape: .circle, showSelection: true)
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
