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
        case .storeItem:
            return ""
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
        case .wallet, .infoPopup:
            return ""
        }
    }
}

protocol ButtonDelegate: class {
    func buttonTapped(_ button: Button)
}

class Button: SKSpriteNode {
    
    static let small = CGSize(width: 75, height: 30)
    static let medium = CGSize(width: 100, height: 50)
    static let large = CGSize(width: 150, height: 75)
    
    weak var delegate: ButtonDelegate?
    
    var identifier: ButtonIdentifier
    let originalBackground: UIColor
    
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat,
         fontColor: UIColor,
         backgroundColor: UIColor = .clayRed) {
        
        //Set properties
        self.delegate = delegate
        self.identifier = identifier
        
        // set the original color so that we can toggle between that and the selected state
        originalBackground = backgroundColor
        
        //Call super
        super.init(texture: nil, color: .white, size: size)
        
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
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Touch Events

extension Button {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            buttonWasPressed()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            buttonPressBegan()
        }
    }
    
    private func buttonWasPressed() {
        color = originalBackground
        delegate?.buttonTapped(self)
    }
    
    private func buttonPressBegan() {
        color = .lightGray
    }
}

//MARK:- LabelDelegate

extension Button: LabelDelegate {
    func labelPressed(_ label: Label) {
        buttonWasPressed()
    }
    
    func labelPressBegan(_ label: Label) {
        buttonPressBegan()
    }
    
}

