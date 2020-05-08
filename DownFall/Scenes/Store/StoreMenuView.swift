//
//  StoreMenuView.swift
//  DownFall
//
//  Created by Katz, Billy on 5/8/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

struct ButtonAction {
    let button: ButtonIdentifier
    let action: (StoreMenuView) -> ()
}

struct RuneReplacementViewModel {
    let newRune: Rune
    var oldRune: Rune?
}

enum MenuMode {
    case runeReplacement(RuneReplacementViewModel)
}

class StoreMenuViewModel {
    let title: String
    let body: String
    let backgroundColor: UIColor
    let mode: MenuMode
    let buttonAction: ButtonAction
    var secondaryButtonAction: ButtonAction?
    
    var selectedRuneToReplace: (Rune) -> () = { _ in }
    var deselectedRuneToReplace: () -> () = { }
    
    init(title: String,
         body: String,
         backgroundColor: UIColor,
         mode: MenuMode,
         buttonAction: ButtonAction,
         secondaryButtonAction: ButtonAction? = nil) {
        self.title = title
        self.body = body
        self.backgroundColor = backgroundColor
        self.mode = mode
        self.buttonAction = buttonAction
        self.secondaryButtonAction = secondaryButtonAction
    }
    
}

class StoreMenuView: SKSpriteNode, ButtonDelegate {
    let viewModel: StoreMenuViewModel
    let contentView: SKSpriteNode
    var secondaryButton: Button?
    
    var bodyPosition: CGRect = .zero
    
    struct Constants {
        static let cornerRadius: CGFloat = 5.0
        static let runeOutline: CGSize = CGSize(width: 175, height: 175)
        static let runeSize = CGSize.oneFifty
        static let runeToReplaceName = "runeToReplaceName"
    }
    
    init(viewModel: StoreMenuViewModel, size: CGSize) {
        self.viewModel = viewModel
        contentView = SKSpriteNode(color: .clear, size: size)
        super.init(texture:nil, color: .clear, size: size)
        
        // bind to view model
        viewModel.selectedRuneToReplace = showRuneToReplace
        viewModel.deselectedRuneToReplace = hideRuneToReplace
        
        addChild(contentView)
        setupView()
        setupViewForMode()
    }
    
    var oldOutline: SKShapeNode = SKShapeNode()
    func showRuneToReplace(rune: Rune) {
        let runeSprite = SKSpriteNode(texture: SKTexture(imageNamed: rune.textureName), size: Constants.runeSize)
        runeSprite.position = oldOutline.frame.center
        runeSprite.name = Constants.runeToReplaceName
        addChild(runeSprite)
        secondaryButton?.enable(true)
    }
    
    func hideRuneToReplace() {
        removeChild(with: Constants.runeToReplaceName)
        secondaryButton?.enable(false)
    }
    
    func setupViewForMode() {
        switch viewModel.mode {
        case .runeReplacement(let viewModel):
            let newOutline = SKShapeNode(rect: CGRect(origin: .zero, size: Constants.runeOutline), cornerRadius: Constants.cornerRadius)
            oldOutline = SKShapeNode(rect: CGRect(origin: .zero, size: Constants.runeOutline), cornerRadius: Constants.cornerRadius)

            newOutline.position = CGPoint.alignHorizontally(newOutline.frame, relativeTo: bodyPosition, horizontalAnchor: .right, verticalAlign: .bottom, verticalPadding: Constants.runeOutline.width, horizontalPadding: Constants.runeOutline.width/2, translatedToBounds: true)
            oldOutline.position = CGPoint.alignHorizontally(oldOutline.frame, relativeTo: bodyPosition, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Constants.runeOutline.width, translatedToBounds: true)
            
            
            addChild(newOutline)
            addChild(oldOutline)
            
            let newRuneSprite = SKSpriteNode(texture: SKTexture(imageNamed: viewModel.newRune.textureName), size: Constants.runeSize)
            newRuneSprite.position = newOutline.frame.center
            
            addChild(newRuneSprite)
            
            let replaceText = ParagraphNode(text: "Replace", paragraphWidth: oldOutline.frame.width, fontSize: UIFont.largeSize)
            replaceText.position = CGPoint.alignHorizontally(replaceText.frame, relativeTo: oldOutline.frame, horizontalAnchor: .left, verticalAlign: .bottom, translatedToBounds: true)
            
            addChild(replaceText)
            
            let spaceBetweenBoxes = newOutline.frame.minX - oldOutline.frame.maxX
            let withText = ParagraphNode(text: "with", paragraphWidth: oldOutline.frame.width, fontSize: UIFont.largeSize)
            withText.position = CGPoint.alignVertically(withText.frame, relativeTo: oldOutline.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: (spaceBetweenBoxes - withText.frame.width)/2, translatedToBounds: true)
            
            addChild(withText)
            
        }
    }
    
    func setupView() {
        
        /// background
        let backgroundView = SKSpriteNode(color: viewModel.backgroundColor, size: size)
        backgroundView.zPosition = Precedence.background.rawValue
        
        /// title
        let widthCoefficient = CGFloat(0.9)
        let titleNode = ParagraphNode.labelNode(text: viewModel.title, paragraphWidth: size.width * widthCoefficient,fontSize: UIFont.extraLargeSize)

        titleNode.position = CGPoint.position(titleNode.frame, inside: contentView.frame, verticalAlign: .top, horizontalAnchor: .center, yOffset: Style.Padding.most)
        titleNode.zPosition = Precedence.foreground.rawValue
        
        /// Body
        let bodyNode = ParagraphNode(text: viewModel.body, paragraphWidth: size.width * widthCoefficient, fontSize: UIFont.largeSize)
        bodyNode.position = CGPoint.alignHorizontally(bodyNode.frame, relativeTo: titleNode.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        bodyNode.zPosition = Precedence.foreground.rawValue
        
        /// save this to later set up additional views
        bodyPosition = bodyNode.frame
        
        /// Button
        let horizontalPositioning: CGPoint.Anchor = viewModel.secondaryButtonAction == nil ? .center : .left
        let button = Button(size: Button.extralarge, delegate: self, identifier: viewModel.buttonAction.button, fontColor: UIColor.darkGray, backgroundColor: UIColor.lightGray)
        button.position = CGPoint.position(button.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: horizontalPositioning, xOffset: Style.Padding.more, yOffset: Style.Padding.more)
        button.zPosition = Precedence.foreground.rawValue
        
        if let secondaryButtonAction = viewModel.secondaryButtonAction {
            secondaryButton = Button(size: Button.extralarge, delegate: self, identifier: secondaryButtonAction.button, fontColor: UIColor.eggshellWhite, backgroundColor: UIColor.confirmButtonColor, disable: true)
            secondaryButton?.position = CGPoint.position(secondaryButton?.frame, inside: contentView.frame, verticalAlign: .bottom, horizontalAnchor: .right, xOffset: Style.Padding.more, yOffset: Style.Padding.more)
            secondaryButton?.zPosition = Precedence.foreground.rawValue
            contentView.addChildSafely(secondaryButton)
        }
        
        /// border
        let border = SKShapeNode(rect: self.frame)
        border.strokeColor = UIColor.darkBarPurple
        border.lineWidth = Style.Menu.borderWidth
        contentView.addChild(border)

        
        contentView.addChild(backgroundView)
        contentView.addChild(titleNode)
        contentView.addChild(bodyNode)
        contentView.addChild(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case viewModel.buttonAction.button:
            viewModel.buttonAction.action(self)
        case viewModel.secondaryButtonAction?.button:
            viewModel.secondaryButtonAction?.action(self)
        default:
            ()
        }
    }
    
}
