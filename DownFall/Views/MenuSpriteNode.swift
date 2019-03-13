//
//  Menu.swift
//  DownFall
//
//  Created by William Katz on 3/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class MenuSpriteNode: SKSpriteNode {
    
    struct Constants {
        static let pauseMenu = "pauseMenu"
        static let resume = "resume"
    }
    
    enum MenuType {
        case pause
        
        func buttonText() -> [String] {
            switch self {
            case .pause:
                return ["Resume"]
            }
        }
    }
    
    init(_ menuType: MenuType, playableRect: CGRect) {
        let menuSizeWidth = playableRect.size.width * 0.5
        let menuSizeHeight = playableRect.size.height * 0.5
        
        
        super.init(texture: SKTexture(imageNamed: "menu"), color: .black, size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        isUserInteractionEnabled = true
//        super.init()
        self.name = Constants.pauseMenu
        
//        let buttonTexts = menuType.buttonText()
        let button = Button.build("Resume", size: CGSize(width: menuSizeWidth * 0.8, height: 200))
        button.position = playableRect.center
        button.zPosition = 1
        button.name = "resume"
        self.addChild(button)
        
        self.zPosition = 20
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let positionInScene = touch.location(in: self)
        let nodes = self.nodes(at: positionInScene)
        

        for node in nodes {
            if node.name == Constants.resume {
                InputQueue.append(.play)        
            }
        }

    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
