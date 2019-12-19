//
//  LevelSelect.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol LevelSelectDelegate: class {
    func didSelect(_ difficulty: Difficulty, _ playerModel: EntityModel?)
}

class LevelSelect: SKScene {
    private var background: SKSpriteNode!
    private var header: Header?
    private var difficultyLabel: ParagraphNode?
    weak var levelSelectDelegate: LevelSelectDelegate?
    var playerModel: EntityModel?
    
    override func didMove(to view: SKView) {
        background = self.childNode(withName: "background") as? SKSpriteNode
        background.color = UIColor.clayRed
        
        
        let startButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .newGame,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white)
        
        startButton.position = .zero
        addChild(startButton)
        
        let playableRect = size.playableRect
        
        header = Header.build(color: .black,
                              size: CGSize(width: playableRect.width, height: Style.Header.height),
                              precedence: .foreground,
                              delegate: self)
        header?.position = CGPoint.positionThis(header?.frame ?? .zero, inTopOf: playableRect)
        
        addChild(header)
        
        updateDifficultyLabel()
    }

    func updateDifficultyLabel() {
        difficultyLabel?.removeFromParent()
        difficultyLabel = ParagraphNode(text: "\(GameScope.shared.difficulty)",paragraphWidth: header!.frame.width/2, fontColor: .white)
        difficultyLabel?.zPosition = Precedence.menu.rawValue
        
        header?.addChild(difficultyLabel!)
    }
}



extension LevelSelect: HeaderDelegate {
    func settingsTapped(_ header: Header) {
        let difficultyIndex = GameScope.shared.difficulty.rawValue - 1
        GameScope.shared.difficulty = Difficulty.allCases[(difficultyIndex + 1) % Difficulty.allCases.count]
        updateDifficultyLabel()
    }
}

extension LevelSelect: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        levelSelectDelegate?.didSelect(GameScope.shared.difficulty, playerModel)
    }
}
