//
//  RuneDetailView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit
import Combine

class RuneDetailView: SKSpriteNode, ButtonDelegate {
    
    struct Constants {
        static let detailBackgroundScale = CGFloat(0.6)
        static let disabledCheckMarkName = "check-mark-disabled"
        static let enabledCheckMarkName = "check-mark-enabled"
        static let chargeIconNotFullName = "charging-icon-not-full"
        static let chargeIconFullName = "Charging-icon-full"
        static let targetIconName = "target-icon"
        static let targetsViewContainerName = "targetsContainer"
        static let buttonSize = CGSize(widthHeight: 130)
        static let chargedIconSize = CGSize(width: 28, height: 52.5)
        static let noRuneDescription = "Empty Rune Slot\nCollect a Rune to store it in this slot."
    }
    
    private var disposables = Set<AnyCancellable>()
    
    private let viewModel: RuneDetailViewModelable
    
    private var descriptionView: SKShapeNode?
    
    private lazy var disabledConfirmButton: ShiftShaft_Button = {
        let diabledConfirmSprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.disabledCheckMarkName), size: Constants.buttonSize)
        let disabledConfirmButton = ShiftShaft_Button(size: Constants.buttonSize, delegate: self, identifier: .runeUseConfirmBeforeReady, image: diabledConfirmSprite, shape: .circle, showSelection: true, disable: false)
        return disabledConfirmButton
    }()
    
    private lazy var enabledConfirmButton: ShiftShaft_Button = {
        let enabledConfirmSprite = SKSpriteNode(texture: SKTexture(imageNamed: Constants.enabledCheckMarkName), size: Constants.buttonSize)
        let enabledConfirmButton = ShiftShaft_Button(size: Constants.buttonSize, delegate: self, identifier: .backpackConfirm, image: enabledConfirmSprite, shape: .circle, showSelection: true, disable: false)
        return enabledConfirmButton
    }()
    
    private lazy var chargedIconNotFull: SKSpriteNode = {
        return SKSpriteNode(texture: SKTexture(imageNamed: Constants.chargeIconNotFullName), size: Constants.chargedIconSize)
    }()
    
    private lazy var chargedIconFull: SKSpriteNode = {
        return SKSpriteNode(texture: SKTexture(imageNamed: Constants.chargeIconFullName), size: Constants.chargedIconSize)
    }()
    
    private lazy var targetIcon: SKSpriteNode = {
        return SKSpriteNode(texture: SKTexture(imageNamed: Constants.targetIconName), size: CGSize(width: 32, height: 32))
    }()
    
    private var chargeDescriptionFontColor: UIColor {
        if viewModel.rune?.isCharged ?? false {
            return .runeChargedYellow
        } else {
            return .white
        }
    }
    
    private var progressBackgroundBorderColor: UIColor {
        if viewModel.rune?.isCharged ?? false {
            return .runeChargedYellow
        } else {
            return .runeDetailFillColor
        }
    }
    
    private var chargeIcon: SKSpriteNode {
        if viewModel.rune?.isCharged ?? false {
            return chargedIconFull
        } else {
            return chargedIconNotFull
        }
    }

    
    init(viewModel: RuneDetailViewModelable, size: CGSize) {
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func shouldEnableConfirmButton(allTargets: AllTarget) -> Bool {
        guard let rune = viewModel.rune else { return false }
        return allTargets.areLegal && rune.targets == allTargets.targets.count
    }
    
    public func enableButton(_ enable: Bool, targets: AllTarget) {
        guard viewModel.rune?.isCharged ?? false else { return }
        disabledConfirmButton.removeFromParent()
        enabledConfirmButton.removeFromParent()
        if shouldEnableConfirmButton(allTargets: targets) {
            addChild(enabledConfirmButton)
            disabledConfirmButton.removeFromParent()
        } else {
            addChild(disabledConfirmButton)
            enabledConfirmButton.removeFromParent()
        }
        
        addTargetsView(allTargets: targets)
    }
    
    private func setupView() {
        /// set up detail view first so we can base everything else off of that
        setupDetailView()
        
        setupRuneView()
        setupButtons()
        addTargetsView(allTargets: nil)
        
    }
    
    private func setupDetailView() {

        let chargedWidth = 568
        let nonChargedWidth = 720
        let detailViewWidth = (viewModel.rune?.isCharged ?? false) ? chargedWidth : nonChargedWidth
        
        let detailView = SKShapeNode(rectOf: CGSize(width: detailViewWidth, height: 215), cornerRadius: 10.0)
        detailView.strokeColor = .runeDetailBorderColor
        detailView.fillColor = .runeDetailFillColor
        detailView.lineWidth = 5
        detailView.zPosition = Precedence.background.rawValue
        detailView.position = CGPoint.position(detailView.frame, inside: frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: 195, yOffset: 5.0, translatedToBounds: true)
        self.descriptionView = detailView
        addChild(detailView)
        
        
        // description container
        let descriptionWidth = detailView.frame.width - Style.Padding.most * 2
        let descriptionHeight = detailView.frame.height - Style.Padding.more
        let descriptionContainer = SKSpriteNode(color: .clear, size: CGSize(width: descriptionWidth, height: descriptionHeight))
        descriptionContainer.position = .zero//, xOffset: Style.Padding.normal, yOffset: Style.Padding.normal, translatedToBounds: true)
        
        // description paragraphs
        
        let effectDescription = ParagraphNode(text: viewModel.rune?.description ?? Constants.noRuneDescription, paragraphWidth: descriptionWidth, fontSize: 65.0)
        let chargeDescription = ParagraphNode(text: viewModel.chargeDescription ?? "", paragraphWidth: descriptionWidth, fontSize: 60.0, fontColor: chargeDescriptionFontColor)
        
        
        // position Effect and Charge labels
        effectDescription.position = CGPoint.position(effectDescription.frame, inside: descriptionContainer.frame, verticalAlign: .top, horizontalAnchor: .left, translatedToBounds: true)
        chargeDescription.position = CGPoint.position(chargeDescription.frame, inside: descriptionContainer.frame, verticalAlign: .bottom, horizontalAnchor: .left, yOffset: 4, translatedToBounds: true)
        
        // add them to the container
        descriptionContainer.addChild(effectDescription)
        descriptionContainer.addChild(chargeDescription)
        
        detailView.addChild(descriptionContainer)
        

        addProgressView()
    }
    
    
    private func setupRuneView() {
        let size = CGSize(widthHeight: 180.0)
        
        let viewModel = RuneSlotViewModel(rune: self.viewModel.rune)
        let runeSlotView = RuneSlotView(viewModel: viewModel,
                                        size: size,
                                        justDisplayRune: true)
        
        runeSlotView.position = CGPoint.alignVertically(runeSlotView.frame, relativeTo: descriptionView?.frame, horizontalAnchor: .left, verticalAlign: .top, verticalPadding: -Style.Padding.more, horizontalPadding: 0.0,  translatedToBounds: true)
        runeSlotView.zPosition = Precedence.foreground.rawValue
        
        /// listen for updates from the rune slot.  tapping on the rune slot in the rune detail view toggles the view back to the All Runes view (non-detail non-targeting)
        viewModel
            .runeWasTapped
            .sink(receiveValue: { [weak self] (_) in
                self?.viewModel.canceled?()
            }).store(in: &disposables)
        addChild(runeSlotView)
    }
    
    private func shakeTargetsView() {
        guard let targetsView = self.childNode(withName: Constants.targetsViewContainerName) else { return }
        let blinkNode = Animator().blinkNode(node: targetsView)
        let shake = Animator().shakeNode(node: targetsView, duration: 0.5, amp: 10, delayBefore: blinkNode.duration)
        blinkNode.run()
        shake.run()
    }
    
    private func addTargetsView(allTargets: AllTarget?) {
        guard let rune = viewModel.rune, rune.isCharged else { return }
        let targetsStrokeColor: UIColor
        if  let allTargets = allTargets,
            shouldEnableConfirmButton(allTargets: allTargets)
        {
            targetsStrokeColor = .runeChargedYellow
        } else { //if let allTargets = allTargets?.allTargetCoords,
                 // allTargets.count < (rune.targets? ?? 0) {
            targetsStrokeColor = .runeIllegalTargetsRed
        }
        
        self.removeChild(with: Constants.targetsViewContainerName)
        let containerView = SKSpriteNode(color: .clear, size: CGSize(width: 140, height: 60))
        containerView.position = CGPoint.alignVertically(containerView.frame, relativeTo: descriptionView?.frame, horizontalAnchor: .right, verticalAlign: .top, horizontalPadding: Style.Padding.most + 4)
        
        let progressShapeSize = CGSize(width: 140, height: 60)
        let shapeNode = SKShapeNode(rectOf: progressShapeSize, cornerRadius: 10)
        shapeNode.fillColor = .runeDetailBorderColor
        shapeNode.strokeColor = targetsStrokeColor
        shapeNode.lineWidth = 2.0
        
        let progressDescription = ParagraphNode(text: "\(allTargets?.targets.count ?? 0)/\(rune.targets ?? 0)", paragraphWidth: 200.0, fontSize: 60.0)
        progressDescription.position = CGPoint.position(progressDescription.frame, inside: shapeNode.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: Style.Padding.more, yOffset: 2.0, translatedToBounds: true)
        
        targetIcon.position = CGPoint.position(targetIcon.frame, inside: shapeNode.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: Style.Padding.most)
        
        containerView.addChildSafely(shapeNode)
        containerView.addChildSafely(progressDescription)
        containerView.addChildSafely(targetIcon)
        
        containerView.name = Constants.targetsViewContainerName
        
        addChild(containerView)
    }
    
    private func addProgressView() {
        if let ability = viewModel.rune {
            let progressShapeSize = CGSize(width: 140, height: 60)
            let shapeNode = SKShapeNode(rectOf: progressShapeSize, cornerRadius: 10)
            shapeNode.fillColor = .runeDetailBorderColor
            shapeNode.strokeColor = progressBackgroundBorderColor
            shapeNode.lineWidth = 2.0
            
            let progressText =  "\(Int(viewModel.progress))/\(ability.cooldown)"
            let fontSize: CGFloat
            if progressText.count > 3 {
                fontSize = 48
            } else {
                fontSize = 60
            }
            let progressDescription = ParagraphNode(text: "\(Int(viewModel.progress))/\(ability.cooldown)", paragraphWidth: 200.0, fontSize: fontSize)
            progressDescription.position = CGPoint.position(progressDescription.frame, inside: shapeNode.frame, verticalAlign: .center, horizontalAnchor: .right, xOffset: 12.0, yOffset: 2.0, translatedToBounds: true)
            
            chargeIcon.position = CGPoint.position(chargeIcon.frame, inside: shapeNode.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: Style.Padding.more)
            
            shapeNode.addChild(progressDescription)
            shapeNode.addChild(chargeIcon)
            
            shapeNode.position = CGPoint.alignVertically(shapeNode.frame, relativeTo: descriptionView?.frame, horizontalAnchor: .left, verticalAlign: .bottom, horizontalPadding: Style.Padding.more, translatedToBounds: true)
            
            self.addChild(shapeNode)
        }
    }
    
    private func setupButtons() {
        
        /// there is a rune in the rune model
        if let rune = viewModel.rune, rune.isCharged {
            let position = CGPoint.alignVertically(disabledConfirmButton.frame, relativeTo: descriptionView?.frame, horizontalAnchor: .right, verticalAlign: .bottom, verticalPadding: 22.0, horizontalPadding: 34.0)
            disabledConfirmButton.position = position
            enabledConfirmButton.position = position

            addChild(disabledConfirmButton)
        }
        
        /// Cancel button is added everytime because a empty rune slot can be viewed and the player needs a way to get back to normal mode
        let size = CGSize(widthHeight: 100)
        let cancelSprite = SKSpriteNode(texture: SKTexture(imageNamed: "cancel-button-with-larger-tap-target"), size: size)
        let cancelButton = ShiftShaft_Button(size: size, delegate: self, identifier: .backpackCancel, image: cancelSprite, shape: .circle, showSelection: true)
        cancelButton.position = CGPoint.position(cancelButton.frame, inside: frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: -5.0, yOffset: -50.0)
        cancelButton.zPosition = 100000000000
        
        addChild(cancelButton)
    }
    
    /// MARK: ButtonDelegate
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .backpackCancel:
            viewModel.canceled?()
        case .backpackConfirm:
            guard let ability = viewModel.rune else { return }
            viewModel.confirmed?(ability)
            HapticGenerator.shared.playStyle(.medium)
        case .runeUseConfirmBeforeReady:
            shakeTargetsView()
            HapticGenerator.shared.playStyle(.soft)
        default:
            break
        }
    }
    
}
