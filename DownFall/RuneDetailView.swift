//
//  RuneDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit
import Combine

protocol RuneDetailViewModelable {
    var rune: Rune? { get }
    var progress: CGFloat { get }
    var confirmed: ((Rune) -> ())? { get set }
    var canceled: (() -> ())? { get set }
    var isCharged: Bool { get }
    var chargeDescription: String? { get }
    var mode: ViewMode { get }
}

class RuneDetailViewModel: RuneDetailViewModelable {
    var rune: Rune?
    var progress: CGFloat
    var confirmed: ((Rune) -> ())?
    var canceled: (() -> ())?
    var mode: ViewMode
    
    init(rune: Rune?, progress: CGFloat, confirmed: ((Rune) -> ())?, canceled: (() -> ())?, mode: ViewMode) {
        self.rune = rune
        self.progress = progress
        self.confirmed = confirmed
        self.canceled = canceled
        self.mode = mode
    }
    
    /// returns true is we have completed the charging of a rune
    var isCharged: Bool {
        guard let rune = rune else { return false }
        return progress >= CGFloat(rune.cooldown)
    }
    
    /// returns a string to display to players that describes how to recahrge the rune
    var chargeDescription: String? {
        guard let rune = rune else { return nil }
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
    
    /// The dispose bag
    private var disposables = Set<AnyCancellable>()
    
    private let viewModel: RuneDetailViewModelable
    
    private var confirmButton: Button?
    
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
    
    
    
    public func enableButton(_ enable: Bool) {
        confirmButton?.enable(enable && viewModel.isCharged)
    }
    
    private func setupView() {
        setupRuneView()
        setupDetailView()
        setupButtons()
    }
    
    private func setupRuneView() {
        let size = CGSize.oneFifty
        
        let viewModel = RuneSlotViewModel(rune: self.viewModel.rune)
        let runeSlotView = RuneSlotView(viewModel: viewModel,
                                        size: size)
        runeSlotView.position = CGPoint.position(runeSlotView.frame, inside: frame, verticalAlign: .center, horizontalAnchor: .left)
        runeSlotView.zPosition = Precedence.foreground.rawValue
        
        /// listen for updates from the rune slot.  tapping on the rune slot in the rune detail view toggles the view back to the All Runes view (non-detail non-targeting)
        viewModel
            .runeWasTapped
            .sink(receiveValue: { [weak self] (_) in
                self?.viewModel.canceled?()
            }).store(in: &disposables)
        addChild(runeSlotView)
    }
    
    private func setupDetailView() {
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
        let titleFontSize: CGFloat = .fontMediumSize
        let effectTitle = ParagraphNode(text: "Effect:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        let chargeTitle = ParagraphNode(text: "Charge:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        let progressTitle = ParagraphNode(text: "Progress:", paragraphWidth: titleColumnWidth, fontSize: titleFontSize)
        
        progressTitle.position = CGPoint.position(progressTitle.frame, inside: titleContainer.frame, verticalAlign: .bottom, horizontalAnchor: .right, yOffset: textOffset)
        chargeTitle.position = CGPoint.position(chargeTitle.frame, inside: titleContainer.frame, verticalAlign: .center, horizontalAnchor: .right)
        effectTitle.position = CGPoint.position(effectTitle.frame, inside: titleContainer.frame, verticalAlign: .top, horizontalAnchor: .right, yOffset: textOffset)
        
    
        titleContainer.addChild(effectTitle)
        titleContainer.addChild(progressTitle)
        titleContainer.addChild(chargeTitle)
        
        
        // description container
        let descriptionWidth = detailView.frame.width - titleColumnWidth
        let descriptionContainer = SKSpriteNode(color: .clear, size: CGSize(width: descriptionWidth, height: detailView.frame.height))
        descriptionContainer.position = CGPoint.alignVertically(descriptionContainer.frame, relativeTo: titleContainer.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        
        // description paragraphs
        let descriptionOffset = textOffset + 3.0
        let descriptionFontSize: CGFloat = .fontSmallSize
        let effectDescription = ParagraphNode(text: viewModel.rune?.description ?? "", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
        let chargeDescription = ParagraphNode(text: viewModel.chargeDescription ?? "", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
        
        
        
        effectDescription.position = CGPoint.position(effectDescription.frame, inside: descriptionContainer.frame, verticalAlign: .top, horizontalAnchor: .left, yOffset: descriptionOffset)
        chargeDescription.position = CGPoint.position(chargeDescription.frame, inside: descriptionContainer.frame, verticalAlign: .center, horizontalAnchor: .left)
        
        descriptionContainer.addChild(effectDescription)
        
        if let ability = viewModel.rune {
            let progressDescription = ParagraphNode(text: "\(Int(viewModel.progress))/\( ability.cooldown)", paragraphWidth: descriptionWidth, fontSize: descriptionFontSize)
            progressDescription.position = CGPoint.position(progressDescription.frame, inside: descriptionContainer.frame, verticalAlign: .bottom, horizontalAnchor: .left, yOffset: descriptionOffset)
            descriptionContainer.addChild(progressDescription)
        }
        
        detailView.addChild(descriptionContainer)
        detailView.addChild(titleContainer)
        
    }
    
    private func setupButtons() {
        
        /// there is a rune in the rune model
        if viewModel.rune != nil {
            
            let confirmSprite = SKSpriteNode(texture: SKTexture(imageNamed: "buttonAffirmitive"), size: .oneHundred)
            let confirmButton = Button(size: .oneHundred, delegate: self, identifier: .backpackConfirm, image: confirmSprite, shape: .circle, showSelection: true, disable: !viewModel.isCharged)
            confirmButton.position = CGPoint.position(confirmButton.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: Style.Padding.more)
            addChild(confirmButton)
            
            self.confirmButton = confirmButton
        }
        
        /// Cancel button is added everytime because a empty rune slot can be viewed and the player needs a way to get back to normal mode
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
            guard let ability = viewModel.rune else { return }
            viewModel.confirmed?(ability)
        default:
            break
        }
    }
    
}
