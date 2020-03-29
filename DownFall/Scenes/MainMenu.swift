//
//  MainMenu.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MainMenuDelegate: class {
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?, level: LevelType)
    func didSelectStartTutorial(_ playerModel: EntityModel?)
}

class MainMenu: SKScene {
    private var background: SKSpriteNode!
    private var header: Header?
    private var difficultyLabel: ParagraphNode?
    private var levelLabel: ParagraphNode?
    weak var mainMenuDelegate: MainMenuDelegate?
    var playerModel: EntityModel?
    
    private var levelTypeIndex = 0 {
        didSet {
            let position = levelLabel?.position
            levelLabel?.removeFromParent()
            levelLabel = ParagraphNode(text: "\(LevelType.gameCases[levelTypeIndex])",paragraphWidth: 300, fontColor: .white)
            levelLabel?.zPosition = Precedence.menu.rawValue
            levelLabel?.position = position ?? .zero
            addOptionalChild(levelLabel)

        }
    }
    
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
        
        startButton.position = CGPoint(x: 0, y: 400)
        addChild(startButton)
        
        let levelButton = Button(size: Style.RunMenu.buttonSize,
                                      delegate: self,
                                      identifier: .cycleLevel,
                                      precedence: .menu,
                                      fontSize: UIFont.largeSize,
                                      fontColor: UIColor.white,
                                      backgroundColor: .menuPurple)
        
        levelButton.position = CGPoint.alignHorizontally(levelButton.frame, relativeTo: startButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Style.Padding.most)
        
        addChild(levelButton)
        
        
        levelTypeIndex = 0
        
        //TODO: reinstate tutorial
        //        let tutorialButton = Button(size: Style.RunMenu.buttonSize,
        //                                    delegate: self,
        //                                    identifier: .startTutorial,
        //                                    precedence: .menu,
        //                                    fontSize: UIFont.largeSize,
        //                                    fontColor: .white,
        //                                    backgroundColor: .menuPurple)
        
        //        tutorialButton.position = CGPoint.positionThis(tutorialButton.frame, below: startButton.frame, spacing: Style.Spacing.normal)
        //        addChild(tutorialButton)
        
        
        let playableRect = size.playableRect
        
        header = Header.build(color: .black,
                              size: CGSize(width: playableRect.width, height: Style.Header.height),
                              precedence: .foreground,
                              delegate: self)
        header?.position = CGPoint.position(header?.frame ?? .zero, centeredInTopOf: playableRect)
        
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



extension MainMenu: SettingsDelegate {
    func settingsTapped() {
        let difficultyIndex = GameScope.shared.difficulty.rawValue - 1
        GameScope.shared.difficulty = Difficulty.allCases[(difficultyIndex + 1) % Difficulty.allCases.count]
        updateDifficultyLabel()
    }
}

extension MainMenu: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .newGame:
            mainMenuDelegate?.newGame(GameScope.shared.difficulty,
                                      playerModel,
                                      level: LevelType.gameCases[levelTypeIndex])
        case .startTutorial:
            mainMenuDelegate?.didSelectStartTutorial(playerModel)
        case .cycleLevel:
            if levelTypeIndex + 1 == LevelType.gameCases.count {
                levelTypeIndex = 0
            } else {
               levelTypeIndex += 1
            }
        default:
            ()
        }
    }
}
