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
         identifier: ButtonIdentifier,
         fontSize: CGFloat = 80,
         fontColor: UIColor = .blue) {
        
        super.init()
        self.delegate = delegate
        self.text = text
        fontName = ParagraphNode.defaultFontName
        name = identifier.rawValue
        self.fontSize = fontSize
        self.fontColor = fontColor
        zPosition = precedence.rawValue
        isUserInteractionEnabled = true
    }
    
    init(text: String,
         precedence: Precedence,
         font: UIFont,
         fontColor: UIColor = .blue,
         maxWidth: CGFloat) {
        
        super.init()
        self.text = text
        self.fontName = font.fontName
        self.fontSize = font.pointSize
        zPosition = precedence.rawValue
        preferredMaxLayoutWidth = maxWidth
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
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
