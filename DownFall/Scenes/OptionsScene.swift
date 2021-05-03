//
//  OptionsScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol OptionsSceneDelegate: AnyObject {
    func backSelected()
    func addRandomRune()
}

class OptionsScene: SKScene, ButtonDelegate {
    
    private var foreground: SKSpriteNode!
    weak var optionsDelegate: OptionsSceneDelegate?
    
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
    
    private lazy var addPlayerRune: Button = {
        
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .givePlayerRune)
        return button
    }()

    
    override func didMove(to view: SKView) {
    
        let foreground = SKSpriteNode(color: .backgroundGray, size: self.size.playableRect.size)
        self.foreground = foreground
        addChildSafely(foreground)
        
        resetDataButton.position = .position(resetDataButton.frame, inside: foreground.frame, verticalAlign: .top, horizontalAnchor: .right, yOffset: .safeAreaHeight)
        
        foreground.addChildSafely(resetDataButton)
        
        
        backButton.position = .position(backButton.frame, inside: foreground.frame, verticalAlign: .top, horizontalAnchor: .left, yOffset: .safeAreaHeight)
        
        
        foreground.addChildSafely(backButton)
        
        
        addPlayerRune.position = .zero
        
        foreground.addChildSafely(addPlayerRune)
    }
    
    func buttonTapped(_ button: Button) {
        switch button.identifier {
            case .resetData:
                /// Order matters here
                GameScope.shared.profileManager.deleteLocalProfile()
                GameScope.shared.profileManager.deleteAllRemoteProfile()
                GameScope.shared.profileManager.resetUserDefaults()
        case .back:
            optionsDelegate?.backSelected()
        case .givePlayerRune:
            optionsDelegate?.addRandomRune()
        default:
            break
        }
    }
}
