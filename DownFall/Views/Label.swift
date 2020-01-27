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
    func labelPressUnknown(_ label: Label, _ touches: Set<UITouch>, with event: UIEvent?)
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
        let translatedPosition = CGPoint(x: frame.center.x + position.x, y: frame.center.y + position.y)
        if frame.contains(translatedPosition) {
            delegate?.labelPressed(self)
        } else {
            delegate?.labelPressUnknown(self, touches, with: event)
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
