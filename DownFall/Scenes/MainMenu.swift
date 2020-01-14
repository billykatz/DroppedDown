//
//  MainMenu.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MainMenuDelegate: class {
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?)
    func didSelectStartTutorial(_ playerModel: EntityModel?)
}

class MainMenu: SKScene {
    private var background: SKSpriteNode!
    private var header: Header?
    private var difficultyLabel: ParagraphNode?
    weak var mainMenuDelegate: MainMenuDelegate?
    var playerModel: EntityModel?
    
    override func didMove(to view: SKView) {
        background = self.childNode(withName: "background") as? SKSpriteNode
        background.color = UIColor.clayRed
        
        
        let startButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .newGame,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white,
                                 backgroundColor: .menuPurple)
        
        startButton.position = .zero
        addChild(startButton)
        
        let tutorialButton = Button(size: Style.RunMenu.buttonSize,
                                    delegate: self,
                                    identifier: .startTutorial,
                                    precedence: .menu,
                                    fontSize: UIFont.largeSize,
                                    fontColor: .white,
                                    backgroundColor: .menuPurple)
        
        tutorialButton.position = CGPoint.positionThis(tutorialButton.frame, below: startButton.frame, spacing: Style.Spacing.normal)
        addChild(tutorialButton)
        
        
        let playableRect = size.playableRect
        
        header = Header.build(color: .black,
                              size: CGSize(width: playableRect.width, height: Style.Header.height),
                              precedence: .foreground,
                              delegate: self)
        header?.position = CGPoint.positionThis(header?.frame ?? .zero, inTopOf: playableRect)
        
        addOptionalChild(header)
        
        updateDifficultyLabel()
    }

    func updateDifficultyLabel() {
        difficultyLabel?.removeFromParent()
        difficultyLabel = ParagraphNode(text: "\(GameScope.shared.difficulty)",paragraphWidth: header!.frame.width/2, fontColor: .white)
        difficultyLabel?.zPosition = Precedence.menu.rawValue
        
        header?.addChild(difficultyLabel!)
    }
}



extension MainMenu: HeaderDelegate {
    func settingsTapped(_ header: Header) {
        let difficultyIndex = GameScope.shared.difficulty.rawValue - 1
        GameScope.shared.difficulty = Difficulty.allCases[(difficultyIndex + 1) % Difficulty.allCases.count]
        updateDifficultyLabel()
    }
}

extension MainMenu: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .newGame:
            mainMenuDelegate?.newGame(GameScope.shared.difficulty, playerModel)
        case .startTutorial:
            mainMenuDelegate?.didSelectStartTutorial(playerModel)
        default:
            ()
        }
    }
}
