//
//  LevelCoordinator.swift
//  DownFall
//
//  Created by William Katz on 12/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit



enum LevelType: Int, Codable {
    case first
    case second
    case third
    case boss
    case tutorial1
    case tutorial2
}

struct Level: Decodable {
    let type: LevelType
    let monsters: [EntityModel.EntityType: Double]
    let maxMonstersTotal: Int
    let maxMonstersOnScreen: Int
    let maxGems: Int
    let maxTime: Int
}

protocol LevelCoordinating: StoreSceneDelegate, GameSceneCoordinatingDelegate {
    var gameSceneNode: GameScene? { get set }
    var tutorialSceneNode: TutorialScene? { get set }
    var entities: [EntityModel]? { get set }
    var boardSize: Int { get set }
    var levels: [Level]? { get set }
    
    func presentStore(_ playerData: EntityModel)
    func presentNextLevel(_ playerData: EntityModel?)
    func difficultySelected(_ difficulty: Difficulty)
}

extension LevelCoordinating where Self: UIViewController {
    
    func presentStore(_ playerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            let storeScene = StoreScene(size: self.view!.frame.size,
                                        playerData: playerData,
                                        inventory: StoreInventory())
            storeScene.storeSceneDelegate = self
            view.presentScene(storeScene)
        }
    }
    
    func presentNextLevel(_ playerData: EntityModel?) {
        switch GameScope.shared.difficulty {
        case .tutorial2, .tutorial1:
            tutorialSceneNode?.prepareForReuse()
            if let scene = GKScene(fileNamed: "TutorialScene")?.rootNode as? TutorialScene,
                let entities = entities {
                tutorialSceneNode = scene
                tutorialSceneNode!.gameSceneDelegate = self
                tutorialSceneNode!.scaleMode = .aspectFill
                tutorialSceneNode!.commonInit(boardSize: 4,
                                              entities: entities,
                                              difficulty: GameScope.shared.difficulty,
                                              updatedEntity: nil)
                
                if let view = self.view as! SKView? {
                    view.presentScene(tutorialSceneNode)
                    view.ignoresSiblingOrder = true
                    
                    #if DEBUG
                    view.showsFPS = true
                    view.showsNodeCount = true
                    #endif
                }
            }
        case .easy, .normal, .hard:
            if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
                let entities = entities {
                gameSceneNode = scene
                gameSceneNode!.scaleMode = .aspectFill
                gameSceneNode!.gameSceneDelegate = self
                gameSceneNode!.commonInit(boardSize: boardSize,
                                          entities: entities,
                                          difficulty: GameScope.shared.difficulty,
                                          updatedEntity: playerData)
                
                if let view = self.view as! SKView? {
                    view.presentScene(gameSceneNode)
                    view.ignoresSiblingOrder = true
                    
                    //Debug settings
                    #if DEBUG
                    view.showsFPS = true
                    view.showsNodeCount = true
                    #endif
                    
                }
            }
        }
    }
    
    func difficultySelected(_ difficulty: Difficulty) {
        levels = LevelConstructor.buildLevels(difficulty)
    }
    
    
    // MARK: - StoreSceneDelegate
    
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            presentNextLevel(updatedPlayerData)
        }
    }
    
    // MARK: - GameSceneCoordinatingDelegate
    
    func reset(_ scene: SKScene) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            self?.presentNextLevel(nil)
        }
        
    }
    
    func visitStore(_ playerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            gameSceneNode?.removeFromParent()
            
            
            let storeScene = StoreScene(size: self.view!.frame.size,
                                        playerData: playerData,
                                        inventory: StoreInventory())
            storeScene.storeSceneDelegate = self
            view.presentScene(storeScene)
        }
    }
}


struct LevelConstructor {
    static let monstersOnScreenDivisor = 2
    
    static func buildLevels(_ difficulty: Difficulty) -> [Level]? {
        var levels: [Level] = []
        for index in 0..<4 {
            guard let levelType = LevelType(rawValue: index) else { return nil }
            let maxMonstersTotal = LevelConstructor.maxMonstersTotalPer(levelType, difficulty: difficulty)
            let maxMonstersOnScreen = maxMonstersTotal/LevelConstructor.monstersOnScreenDivisor
            levels[index] = Level(type: levelType,
                                  monsters: monstersPerLevel(levelType, difficulty: difficulty),
                                  maxMonstersTotal: maxMonstersTotal,
                                  maxMonstersOnScreen: maxMonstersOnScreen,
                                  maxGems: 1,
                                  maxTime: timePer(levelType, difficulty: difficulty))
        }
        
        return levels
    }
    
    static func monstersPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: Double] {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.5, .bat: 0.5]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .dragon: 0.33]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .dragon: 0.33]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.25, .bat: 0.25, .dragon: 0.25, .alamo: 0.25]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return [.bat: 0.25, .dragon: 0.25, .alamo: 0.25, .wizard: 0.25]
            case .normal, .hard:
                return [.bat: 0.20, .dragon: 0.20, .alamo: 0.20, .wizard: 0.20, .lavaHorse: 0.20]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
    
    static func maxMonstersTotalPer(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return 6
            case .normal:
                return 12
            case .hard:
                return 20
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return 8
            case .normal:
                return 15
            case .hard:
                return 25
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return 10
            case .normal:
                return 20
            case .hard:
                return 30
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
    
    static func timePer(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return 50
            case .normal:
                return 45
            case .hard:
                return 40
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return 60
            case .normal:
                return 50
            case .hard:
                return 45
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return 70
            case .normal:
                return 55
            case .hard:
                return 50
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
}
