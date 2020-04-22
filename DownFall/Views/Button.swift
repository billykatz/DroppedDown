//
//  Button.swift
//  DownFall
//
//  Created by William Katz on 3/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

protocol ButtonDelegate: class {
    func buttonTapped(_ button: Button)
}

class Button: SKShapeNode {
    
    static let small = CGSize(width: 75, height: 30)
    static let medium = CGSize(width: 110, height: 50)
    static let large = CGSize(width: 150, height: 75)
    
    static let inGameLarge = CGSize(width: 200, height: 160)
    
    weak var delegate: ButtonDelegate?
    
    var identifier: ButtonIdentifier
    let originalBackground: UIColor
    var showSelection = false
    
    var dropShadow: SKShapeNode?
    var dropShadowOffset: CGFloat = 5.0
    var unpressedPosition: CGPoint? = nil
    var depressedPosition: CGPoint? = nil
    
    /// view to expand touch region of button
    lazy var touchTargetExpandingView: SKSpriteNode = {
        let view = SKSpriteNode(texture: nil, color: .clear, size: self.frame.scale(by: Style.Button.touchzone, andYAmount: Style.Button.touchzone).size)
        view.alpha = 0.0
        view.zPosition = Precedence.underground.rawValue
        view.isUserInteractionEnabled = true
        return view
    }()
    
    /// view that is the visual button
    var buttonView: SKShapeNode?
    
    private var isDisabled: Bool = false
    
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat = UIFont.largeSize,
         fontColor: UIColor = UIColor.eggshellWhite,
         backgroundColor: UIColor = .clayRed,
         showSelection: Bool = true,
         addTextLabel: Bool = true,
         disable: Bool = false) {
        
        //Set properties
        self.delegate = delegate
        self.identifier = identifier
        self.showSelection = showSelection
        
        // set the original color so that we can toggle between that and the selected state
        originalBackground = backgroundColor
        
        //Call super
        super.init()
        self.path = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
        
        
        let buttonPath = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
        self.buttonView = SKShapeNode(path: buttonPath)
        buttonView?.color = self.originalBackground
        
        //add the shadow
        let shadowPath = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2 - dropShadowOffset, width: size.width, height: size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
        let shadowShape = SKShapeNode(path: shadowPath)
        shadowShape.color = .storeBlack
        self.dropShadow = shadowShape
        
        // does this have to be hardcoded?
        shadowShape.zPosition = -1
        addChild(shadowShape)
        
        // set the name to the identifier
        name = identifier.rawValue
        isUserInteractionEnabled = true
        zPosition = precedence.rawValue
        
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
        
        //add touch expanding view
        addChild(touchTargetExpandingView)

        //enable/disable
        self.isDisabled = disable
        
        self.color = .clear
        
        // set points for moving the button slightly
        
        unpressedPosition = self.frame.center
        depressedPosition = self.frame.center.translateVertically(-dropShadowOffset)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Touch Events

extension Button {
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
    
    public func removeShadow() {
        dropShadow?.removeFromParent()
    }
    public func addShadow() {
        addChildSafely(dropShadow)
    }
    
    public func enabled(_ on: Bool) {
        self.isDisabled = !on
        buttonView?.color = on ? originalBackground : .lightGray
    }
    
    
    private func buttonTapWasCancelled() {
        guard !isDisabled else { return }
        if showSelection {
            buttonView?.color = originalBackground
        }
        unpress()
    }
    
    private func buttonWasTapped() {
        guard !isDisabled else { return }
        if showSelection {
            buttonView?.color = originalBackground
        }
        delegate?.buttonTapped(self)
        unpress()
    }
    
    private func buttonTapBegan() {
        guard !isDisabled else { return }
        if showSelection {
            buttonView?.color = .lightGray
        }
        depress()
    }
    
    private func depress() {
        guard let newPosition = depressedPosition else { return }
        buttonView?.position = newPosition
        dropShadow?.removeFromParent()
    }
    
    private func unpress() {
        guard let newPosition = unpressedPosition else { return }
        buttonView?.position = newPosition
        addOptionalChild(dropShadow)
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

