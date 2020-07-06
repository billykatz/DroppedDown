//
//  ProfileView.swift
//  DownFall
//
//  Created by Katz, Billy on 7/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol ProfileViewDelegate: class {
    func navigateToMainMenu(_ profileView: SKSpriteNode)
}

class ProfileView: SKSpriteNode, ButtonDelegate {
    var playableRect: CGRect
    weak var navigationDelegate: ProfileViewDelegate?
    
    // Buttons
    private lazy var newProfile: Button = {
        let button = Button(size: CGSize.oneFifty,
                            delegate: self,
                            identifier: .newProfile,
                            precedence: .aboveMenu)
        button.position = CGPoint.position(button.frame, inside: opaqueBackground.frame, verticalAlign: .bottom, horizontalAnchor: .center, xOffset: 50.0, yOffset: 100.0, translatedToBounds: true)
        return button
    }()
    
    // transparents background
    private lazy var transparentBackground: SKSpriteNode = {
        let background = SKSpriteNode(color: .backgroundGray, size: playableRect.size)
        background.alpha = 0.5
        return background
    }()
    
    // opaque part of background
    private lazy var opaqueBackground: SKSpriteNode = {
        let background = SKSpriteNode(color: .backgroundGray, size: playableRect.size.scale(by: 0.8))
        return background
    }()
    
    // Labels
    
    init(size: CGSize,
         navigationDelegate: ProfileViewDelegate,
         profileManager: ProfileSaving = GameScope.shared.profileManager) {
        //playable rect
        playableRect = size.playableRect
        self.navigationDelegate = navigationDelegate
                
        /// Super init'd
        super.init(texture: nil, color: .clear, size: size)
        
        self.color = .clear
        
        newProfile.zPosition = Precedence.aboveMenu.rawValue
        addChild(transparentBackground)
        addChild(opaqueBackground)
        addChild(newProfile)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Button delegation
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .newProfile:
            navigationDelegate?.navigateToMainMenu(self)
        default:
            break
        }
    }
}


