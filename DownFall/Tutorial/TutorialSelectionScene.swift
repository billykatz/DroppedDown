//
//  TutorialSelectionScene.swift
//  DownFall
//
//  Created by William Katz on 12/20/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

class TutorialSelectionScene: SKScene, ButtonDelegate {
    func buttonTapped(_ button: Button) {
        
    }
    

    let levels: [Level?]
    
    init(size: CGSize, levels: [Level]) {
        self.levels = levels
        super.init(size: size)
        
        
        let backButton = Button(size: Style.Button.size,
                                delegate: self,
                                identifier: .back,
                                precedence: .foreground,
                                fontSize: UIFont.largeSize,
                                fontColor: .white)
        
        backButton.position = CGPoint.position(this: backButton.frame, centeredInBottomOf: frame)
        addChild(backButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


