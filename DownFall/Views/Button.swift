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
        }
    }
}

protocol ButtonDelegate: class {
    func buttonPressed(_ button: Button)
}

class Button: SKSpriteNode {
    weak var delegate: ButtonDelegate?
    
    init(size: CGSize,
         delegate: ButtonDelegate,
         textureName: String,
         precedence: Precedence) {
        
        self.delegate = delegate
        super.init(texture: SKTexture(imageNamed: textureName), color: .white, size: size)
        name = textureName
        isUserInteractionEnabled = true
        zPosition = precedence.rawValue
    }
    
    init(size: CGSize,
         delegate: ButtonDelegate,
         identifier: ButtonIdentifier,
         precedence: Precedence,
         fontSize: CGFloat = 80) {
        
        //Set properties
        self.delegate = delegate
        
        //Call super
        super.init(texture: nil, color: .white, size: size)
        name = identifier.rawValue
        isUserInteractionEnabled = true
        zPosition = precedence.rawValue
        
        
        //Create Label
        let label = Label(text: identifier.title,
                          delegate: self,
                          precedence: precedence,
                          identifier: identifier,
                          fontSize: fontSize)
        label.position = self.frame.center
        
        // Add Label
        addChild(label)
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
        color = .white
        delegate?.buttonPressed(self)
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

