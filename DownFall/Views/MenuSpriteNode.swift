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
        
        var buttonText: String {
            switch self {
            case .pause:
                return Constants.resume
            case .gameWin:
                return Constants.playAgain
            }
        }
        
        var buttonIdentifer: ButtonIdentifier {
            switch self {
            case .pause:
                return ButtonIdentifier.resume
            case .gameWin:
                return ButtonIdentifier.playAgain
            }
            
        }
    }
    
    init(_ menuType: MenuType, playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * 0.7
        let menuSizeHeight = playableRect.size.height * 0.25
        
        
        super.init(texture: SKTexture(imageNamed: "menu"),
                   color: .black,
                   size: CGSize(width: menuSizeWidth, height: menuSizeHeight))
        
        setupButtons(menuType, playableRect, precedence: precedence)
        zPosition = precedence.rawValue
        
    }
    
    func setupButtons(_ menuType: MenuType, _ playableRect: CGRect, precedence: Precedence) {
        let menuSizeWidth = playableRect.size.width * 0.7
        let buttonWidth = CGSize(width: menuSizeWidth * 0.8, height: 200)
        let button = Button(size: buttonWidth,
                            delegate: self,
                            identifier: menuType.buttonIdentifer,
                            precedence: precedence)
        button.position = playableRect.center
        addChild(button)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- ButtonDelegate

extension MenuSpriteNode: ButtonDelegate {
    func buttonPressBegan(_ button: Button) { }
    
    func buttonPressed(_ button: Button) {
        guard let identifier = ButtonIdentifier(rawValue: button.name ?? "") else { return }
        
        switch identifier {
        case .resume:
            InputQueue.append(Input(.play))
        case .playAgain:
            InputQueue.append(Input(.playAgain))
        }
    }
}
