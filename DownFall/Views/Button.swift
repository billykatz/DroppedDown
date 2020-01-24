//
//  Button.swift
//  DownFall
//
//  Created by William Katz on 3/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

enum ButtonIdentifier: String {
    case resume
    case playAgain
    case selectLevel
    case leaveStore
    case storeItem
    case rotate
    case wallet
    case infoPopup
    case visitStore
    case newGame
    case back
    case startTutorial
    case purchase
    case sell
    case close
    case backpack
    case backpackUse
    case backpackCancel
    
    var title: String {
        switch self {
        case .resume:
            return "Resume"
        case .playAgain:
            return "Play Again?"
        case .selectLevel:
            return "Level Select"
        case .leaveStore:
            return "Leave Store"
        case .rotate:
            return "Got it! 👍"
        case .visitStore:
            return "Visit Store"
        case .newGame:
            return "New Game"
        case .back:
            return "Back"
        case .startTutorial:
            return "Start Tutorial"
        case .purchase:
            return "Purchase"
        case .sell:
            return "Sell"
        case .close:
            return "Close"
        case .backpackUse:
            return "Use"
        case .backpackCancel:
            return "Cancel"
        case .wallet, .infoPopup, .storeItem, .backpack:
            return ""
        }
    }
}

protocol ButtonDelegate: class {
    func buttonTapped(_ button: Button)
}

class Button: SKShapeNode {
    
    static let small = CGSize(width: 75, height: 30)
    static let medium = CGSize(width: 100, height: 50)
    static let large = CGSize(width: 150, height: 75)
    
    weak var delegate: ButtonDelegate?
    
    var identifier: ButtonIdentifier
    let originalBackground: UIColor
    var showSelection = false
    
    var dropShadow: SKShapeNode?
    var dropShadowOffset: CGFloat = 10.0
    var unpressedPosition: CGPoint? = nil
    var depressedPosition: CGPoint? = nil
    
    var isDisabled: Bool = false
    
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat,
         fontColor: UIColor,
         backgroundColor: UIColor = .clayRed,
         showSelection: Bool = true) {
        
        //Set properties
        self.delegate = delegate
        self.identifier = identifier
        self.showSelection = showSelection
        
        // set the original color so that we can toggle between that and the selected state
        originalBackground = backgroundColor
        
        self._position = .zero
        //Call super
        super.init()
        self.path = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
        
        //add the shadow
        let shadowPath = CGPath(roundedRect: CGRect(x: -size.width/2, y: -size.height/2 - dropShadowOffset, width: size.width, height: size.height), cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)
        let shadowShape = SKShapeNode(path: shadowPath)
        shadowShape.color = .storeBlack
        self.dropShadow = shadowShape
        
        shadowShape.zPosition = -1
        addChild(shadowShape)
        
        self.zPosition = precedence.rawValue
        
        // set the name to the identifier
        name = identifier.rawValue
        isUserInteractionEnabled = true
        zPosition = precedence.rawValue
        
        
        //Create Label
        let label = Label(text: identifier.title,
                          width: self.frame.width,
                          delegate: self,
                          precedence: precedence,
                          identifier: identifier,
                          fontSize: fontSize,
                          fontColor: fontColor)
        label.position = self.frame.center
        
        // Add Label
        addChild(label)
        
        self.color = backgroundColor
    }
    
    var _position: CGPoint
    override var position: CGPoint {
        get { return _position }
        set {
            super.position = newValue
            _position = newValue
            
            // only set these once
            if unpressedPosition == nil {
                unpressedPosition = newValue
            }
            if depressedPosition == nil {
                depressedPosition = newValue.translateVertically(-dropShadowOffset)
            }
        }
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
        if self.frame.contains(translatedPosition) {
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
        dropShadow?.removeFromParent()
        self.addOptionalChild(dropShadow)
    }
    
    
    private func buttonTapWasCancelled() {
        if showSelection {
            color = originalBackground
        }
        unpress()
    }
    
    private func buttonWasTapped() {
        guard !isDisabled else { return }
        if showSelection {
            color = originalBackground
        }
        delegate?.buttonTapped(self)
        unpress()
    }
    
    private func buttonTapBegan() {
        guard !isDisabled else { return }
        if showSelection {
            color = .lightGray
        }
        depress()
    }
    
    private func depress() {
        guard let newPosition = depressedPosition else { return }
        self.position = newPosition
        dropShadow?.removeFromParent()
    }
    
    private func unpress() {
        guard let newPosition = unpressedPosition else { return }
        self.position = newPosition
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
    
}

