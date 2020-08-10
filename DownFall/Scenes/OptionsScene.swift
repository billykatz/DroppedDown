//
//  OptionsScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol OptionsSceneDelegate: class {
    func backSelected()
}

class OptionsScene: SKScene, ButtonDelegate {
    
    private var foreground: SKSpriteNode!
    weak var myDelegate: OptionsSceneDelegate?
    
    private lazy var resetDataButton: Button = {
        
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .resetData)
        return button
        
        
    }()
    
    private lazy var backButton: Button = {
        
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .back)
        return button
        
        
    }()
    
    override func didMove(to view: SKView) {
    
        let foreground = SKSpriteNode(color: .backgroundGray, size: self.size.playableRect.size)
        self.foreground = foreground
        addChildSafely(foreground)
        
        foreground.addChildSafely(resetDataButton)
        
        backButton.position = .position(backButton.frame, inside: foreground.frame, verticalAlign: .top, horizontalAnchor: .left, yOffset: .safeAreaHeight)
        
        
        foreground.addChildSafely(backButton)
    }
    
    func buttonTapped(_ button: Button) {
        switch button.identifier {
            case .resetData:
                /// Order matters here
                GameScope.shared.profileManager.deleteLocalProfile()
                GameScope.shared.profileManager.deleteAllRemoteProfile()
                GameScope.shared.profileManager.resetUserDefaults()
        case .back:
            myDelegate?.backSelected()
            default:
                break
        }
    }
}
