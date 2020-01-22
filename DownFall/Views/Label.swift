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
    func labelPressCancelled(_ label: Label)
}

class Label: ParagraphNode {
    weak var delegate: LabelDelegate?
    
    init(text: String,
         width: CGFloat,
         delegate: LabelDelegate?,
         precedence: Precedence,
         identifier: ButtonIdentifier,
         fontSize: CGFloat = UIFont.largeSize,
         fontColor: UIColor = .black) {
        
        super.init(text: text, paragraphWidth: width, fontSize: fontSize, fontColor: fontColor)
        self.delegate = delegate
        fontName = ParagraphNode.defaultFontName
        name = identifier.rawValue
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
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let translatedPosition = CGPoint(x: self.frame.center.x + position.x, y: self.frame.center.y + position.y)
        if self.frame.contains(translatedPosition) {
            self.delegate?.labelPressed(self)
        } else {
            self.delegate?.labelPressCancelled(self)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.labelPressCancelled(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.wasTouched(touches, with: event) {
            self.delegate?.labelPressBegan(self)
        }
    }
}
