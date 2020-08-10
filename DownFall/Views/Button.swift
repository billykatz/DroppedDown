//
//  Button.swift
//  DownFall
//
//  Created by William Katz on 3/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

extension SKSpriteNode {

    func aspectFillToSize(fillSize: CGSize) {

        guard let texture = texture else { return }
        self.size = texture.size()

        let verticalRatio = fillSize.height / texture.size().height
        let horizontalRatio = fillSize.width /  texture.size().width

        let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio

        self.setScale(scaleRatio)
    }

}

protocol ButtonDelegate: class {
    func buttonTapped(_ button: Button)
}

enum ButtonShape {
    case rectangle
    case circle
}

enum ButtonType {
    case text
    case image
}

class Button: SKShapeNode {
    
    struct Constants {
        static let disabledBackgroundColor = UIColor.darkGray
    }
    
    private weak var delegate: ButtonDelegate?
    private var buttonType: ButtonType
    private var originalBackground: UIColor = .clear
    private var showSelection = false
    
    private var dropShadow: SKShapeNode?
    private var dropShadowOffset: CGFloat = 5.0
    private var unpressedPosition: CGPoint? = nil
    private var depressedPosition: CGPoint? = nil
    
    /// Identifier passed in on init that ids the button on press
    public var identifier: ButtonIdentifier
    
    /// view to expand touch region of button
    private lazy var touchTargetExpandingView: SKSpriteNode = {
        let view = SKSpriteNode(texture: nil, color: .clear, size: self.frame.scale(by: Style.Button.touchzone, andYAmount: Style.Button.touchzone).size)
        view.alpha = 0.0
        view.zPosition = Precedence.underground.rawValue
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    /// view that is the visual button
    private var buttonView: SKShapeNode?
    private var grayOutButtonView: SKShapeNode?
    
    // set thru init or `enable()`
    private var isDisabled: Bool = false
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Creates a button with a image represented in a SKSpriteNode
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         image: SKSpriteNode,
         shape: ButtonShape,
         precedence: Precedence = Precedence.aboveMenu,
         showSelection: Bool = true,
         disable: Bool = false,
         addTextLabel: Bool = false) {
        self.buttonType = .image
        self.delegate = delegate
        self.identifier = identifier
        self.showSelection = showSelection
        
        // Call super
        super.init()
        
        /// create the rectangle the image will live in
        let rectangle = CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        
        /// The shared cornder radius
        let cornerRadius = CGFloat(5.0)
        switch shape {
        case .rectangle:
            /// create the path
            let path = CGPath(roundedRect: rectangle, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
            
            self.buttonView = SKShapeNode(path: path)
            self.buttonView?.color = .clear
            self.path = path
            
        case .circle:
            /// create the path
            let path = CGPath(ellipseIn: rectangle, transform: nil)
            
            /// set our properties
            self.buttonView = SKShapeNode(path: path)
            self.buttonView?.color = .clear
            self.path = path
        }
        
        if addTextLabel {
            //Create Label
            let label = Label(text: identifier.title,
                              width: self.frame.width,
                              delegate: self,
                              precedence: precedence,
                              identifier: identifier,
                              fontSize: .fontLargeSize,
                              fontColor: .brown)
            label.position = self.frame.center
            label.zPosition = Precedence.menu.rawValue
            
            // Add Label
            buttonView?.addChild(label)
        }

        
        // add the image
        image.zPosition = 0
        image.aspectFillToSize(fillSize: size)
        addChildSafely(image)
        
        /// add the path
        addChildSafely(buttonView)
        
        /// add the drop shadow and keep a reference to it
//        shadowShape.color = .storeBlack
//        shadowShape.zPosition = -1
//        self.dropShadow = shadowShape
//        addChild(shadowShape)
        
        //enable/disable
        self.isDisabled = disable
        
        if disable {
            if let grayOutShape = self.buttonView?.copy() as? SKShapeNode {
                grayOutShape.color = .darkGray
                addChild(grayOutShape)
                grayOutShape.zPosition = Precedence.aboveMenu.rawValue
                grayOutShape.alpha = 0.75
                
                removeShadow()
                
                grayOutButtonView = grayOutShape
            }
        }
        
        commonInit(precedence: precedence)
        
    }
    
    /// Creates a button with a text label based on the ButtonIdentifier
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence = .aboveMenu,
         fontSize: CGFloat = .fontLargeSize,
         fontColor: UIColor = UIColor.eggshellWhite,
         backgroundColor: UIColor = .clayRed,
         showSelection: Bool = true,
         addTextLabel: Bool = true,
         disable: Bool = false) {
        
        //Set properties
        self.buttonType = .text
        self.delegate = delegate
        self.identifier = identifier
        self.showSelection = showSelection
        
        // set the original color so that we can toggle between that and the selected state
        originalBackground = backgroundColor
        
        //Call super
        super.init()
        let path = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerWidth: 15.0, cornerHeight: 15.0, transform: nil)
        self.path = path
        
        let buttonPath = path
        self.buttonView = SKShapeNode(path: buttonPath)
        buttonView?.color = self.originalBackground
        
        //add the shadow
        if !disable {
            let shadowPath = path
            let shadowShape = SKShapeNode(path: shadowPath)
            shadowShape.color = .storeBlack
            self.dropShadow = shadowShape
            // does this have to be hardcoded?
            shadowShape.zPosition = -1
            addChild(shadowShape)
        }
        
        
        if addTextLabel {
            //Create Label
            let label = Label(text: identifier.title,
                              width: self.frame.width,
                              delegate: self,
                              precedence: precedence,
                              identifier: identifier,
                              fontSize: fontSize,
                              fontColor: fontColor)
            label.position = self.frame.center
            label.zPosition = Precedence.menu.rawValue
            
            // Add Label
            buttonView?.addChild(label)
        }
        
        self.addChildSafely(buttonView)
        
        //enable/disable
        self.isDisabled = disable
        enable(!disable)
        
        commonInit(precedence: precedence)
    }
    
    func commonInit(precedence: Precedence) {
        //add touch expanding view
        addChild(touchTargetExpandingView)
        
        // set the name to the identifier
        name = identifier.rawValue
        isUserInteractionEnabled = true
        zPosition = precedence.rawValue
        
        /// set the positions for pressing and releasing
        unpressedPosition = self.frame.center
        depressedPosition = self.frame.center.translateVertically(-dropShadowOffset)
        
        /// set the color to clear
        self.color = .clear
        
    }
    
    /// Sets the internal disabled state.  Updates the UI.
    public func enable(_ on: Bool) {
        self.isDisabled = !on
        if buttonType == .text {
            buttonView?.color = on ? originalBackground : Constants.disabledBackgroundColor
            if on { setupShadow() }
            else { removeShadow() }
        } else {
            if on {
                grayOutButtonView?.removeFromParent()
                setupShadow()
            }
            else {
                addChildSafely(grayOutButtonView)
                removeShadow()
            }
        }
    }
    
    private func removeShadow() {
        dropShadow?.removeFromParent()
    }
    private func addShadow() {
        addChildSafely(dropShadow)
    }
    
    /// Creates the shadow if necessary
    ///
    private func setupShadow() {
        guard buttonType != .image else { return }
        if dropShadow == nil {
            let shadowPath = CGPath(roundedRect: CGRect(x: -frame.size.width/2, y: -frame.size.height/2 - dropShadowOffset, width: frame.size.width, height: frame.size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
            let shadowShape = SKShapeNode(path: shadowPath)
            shadowShape.color = .storeBlack
            self.dropShadow = shadowShape
            // does this have to be hardcoded?
            shadowShape.zPosition = -1
            addChild(shadowShape)
        }
    }
    
    /// Call when the button tap was cancelled
    /// Changes the color back to the original color
    /// Unpresses the button
    private func buttonTapWasCancelled() {
        guard !isDisabled else { return }
        if showSelection && buttonType != .image {
            buttonView?.color = originalBackground
        }
        unpress()
    }
    
    /// Call when button was tapped
    /// Changes the color back to the original color
    /// Unpresses the button
    /// Informs the delegate that the button was tapped
    private func buttonWasTapped() {
        guard !isDisabled else { return }
        if showSelection && buttonType != .image {
            buttonView?.color = originalBackground
        }
        delegate?.buttonTapped(self)
        unpress()
    }
    
    /// Call when the button tap has started
    /// Changes the color and calls depress
    private func buttonTapBegan() {
        guard !isDisabled else { return }
        if showSelection && buttonType != .image {
            buttonView?.color = .lightGray
        }
        depress()
    }
    
    /// Sets our position to 'depressed'
    /// Removes shadow as well
    private func depress() {
        guard let newPosition = depressedPosition else { return }
        buttonView?.position = newPosition
        dropShadow?.removeFromParent()
    }
    
    /// Sets our position to 'unpressed'
    private func unpress() {
        guard let newPosition = unpressedPosition else { return }
        buttonView?.position = newPosition
        addOptionalChild(dropShadow)
    }
}

//MARK:- Touch Events

extension Button {
    private func frameContains(_ p: CGPoint) -> Bool {
        let translatedPosition = CGPoint(x: self.frame.center.x + position.x, y: self.frame.center.y + position.y)
        return frame.contains(translatedPosition)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let translatedPosition = CGPoint(x: self.frame.center.x + position.x, y: self.frame.center.y + position.y)
        if frame.contains(translatedPosition) {
            buttonWasTapped()
        } else {
            buttonTapWasCancelled()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            buttonTapWasCancelled()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            buttonTapBegan()
        }
    }
}

//MARK:- LabelDelegate

extension Button: LabelDelegate {
    func labelPressed(_ label: Label) {
        buttonWasTapped()
    }
    
    func labelPressBegan(_ label: Label) {
        buttonTapBegan()
    }
    
    func labelPressCancelled(_ label: Label) {
        buttonTapWasCancelled()
    }
    
    func labelPressUnknown(_ label: Label, _ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
}

