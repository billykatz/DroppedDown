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
        static let resume = "Resume"
        static let win = "You Won!!"
        static let playAgain = "Play Again?"
    }
    
    enum MenuType {
        case pause
        case gameWin
        
        func buttonText() -> String {
            switch self {
            case .pause:
                return Constants.resume
            case .gameWin:
                return Constants.playAgain
            }
        }
    }
    
    init(_ menuType: MenuType, playableRect: CGRect) {
        let menuSizeWidth = playableRect.size.width * 0.7
        let menuSizeHeight = playableRect.size.height * 0.5
        
        
        super.init(texture: SKTexture(imageNamed: "menu"), color: .black, size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        isUserInteractionEnabled = true
        
        setupButtons(menuType, playableRect)
        self.zPosition = 20
        
    }
    
    func setupButtons(_ menuType: MenuType, _ playableRect: CGRect) {
        let menuSizeWidth = playableRect.size.width * 0.7
        
        let button = Button.build(menuType.buttonText(), size: CGSize(width: menuSizeWidth * 0.8, height: 200))
        button.position = playableRect.center
        button.zPosition = 1
        button.name = menuType.buttonText()
        self.addChild(button)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let nodes = self.nodes(at: touch.location(in: self)) as? [SKSpriteNode] else {
                return
        }
        

        for node in nodes {
            if node.name == Constants.resume {
                InputQueue.append(Input(.play))
                node.color = .white
            }
            
            if node.name == Constants.playAgain {
                InputQueue.append(Input(.playAgain))
                node.color = .white
            }
        }

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let nodes = self.nodes(at: touch.location(in: self)) as? [SKSpriteNode] else {
                return
        }
        
        
        for node in nodes {
            if node.name == Constants.resume {
                node.color = .gray
            }
            
            if node.name == Constants.playAgain {
                node.color = .gray
            }
        }
        
    }

}
