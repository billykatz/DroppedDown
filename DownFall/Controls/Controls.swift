//
//  Controls.swift
//  DownFall
//
//  Created by William Katz on 3/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class Controls: SKSpriteNode {
    
    struct Constants {
        static let rotateRight = "rotateRight"
    }
    
    static func build(color: UIColor,
                      size: CGSize) -> Controls {
        let controls = Controls(texture: SKTexture(imageNamed: "header"), color: color, size: size)
        let rotateRight = SKSpriteNode(imageNamed: "rotateRight")
        rotateRight.scale(to: CGSize(width: 200.0, height: 200.0))
        rotateRight.zPosition = 3
        let rotateRightX = controls.frame.maxX - rotateRight.frame.width/2
        rotateRight.position = CGPoint(x: rotateRightX, y: size.height/2 - rotateRight.frame.height/2)
        rotateRight.name = Constants.rotateRight
        
        let rotateLeft = SKSpriteNode(imageNamed: "rotateLeft")
        rotateLeft.scale(to: CGSize(width: 200.0, height: 200.0))
        rotateLeft.zPosition = 3
        let rotateLeftX = controls.frame.minX + rotateLeft.frame.width/2
        rotateLeft.position = CGPoint(x: rotateLeftX, y: size.height/2 - rotateLeft.frame.height/2)
        rotateLeft.name = "rotateLeft"
        
        controls.addChild(rotateLeft)
        controls.addChild(rotateRight)
        return controls
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let positionInScene = touch.location(in: self)
        let nodes = self.nodes(at: positionInScene)
        
        for node in nodes {
            if node.name == Constants.rotateRight {
                Dispatch.sharedInstance.post(.rotate)
            }
        }
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
