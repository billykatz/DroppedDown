//
//  Label.swift
//  DownFall
//
//  Created by William Katz on 5/17/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol LabelDelegate: class {
    func labelPressed(_ label: Label)
    func labelPressBegan(_ label: Label)
}

class Label: SKLabelNode {
    weak var delegate: LabelDelegate?
    
    init(text: String,
         delegate: LabelDelegate,
         precedence: Precedence,
         identifier: ButtonIdentifier) {
        
        super.init()
        self.delegate = delegate
        self.text = text
        fontName = "Times"
        name = identifier.rawValue
        fontSize = 80
        fontColor = .blue
        zPosition = precedence.rawValue
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Touch Events

extension Label {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            self.delegate?.labelPressed(self)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            self.delegate?.labelPressBegan(self)
        }
    }
}
