//
//  GameViewController.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit



class GameViewController: UIViewController {
    
    //TODO: move to a different file
    func data(from fileName: String) throws -> Data? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            }
            catch {
                fatalError()
            }
        }
        return nil
    }

    private var gameSceneNode: GameScene?
    private var boardSize = 7
    private var entities: [EntityModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let entityData = try! data(from: "entities")!
        entities = try! JSONDecoder().decode(EntitiesModel.self, from: entityData).entities
        startLevel()
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [.portrait]
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController {
    private func startLevel() {
        gameSceneNode = nil
        if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
            let entities = entities {
            gameSceneNode = scene
            gameSceneNode!.scaleMode = .aspectFill
            gameSceneNode!.gameSceneDelegate = self
            gameSceneNode!.commonInit(boardSize: boardSize, entities: entities)
            
            if let view = self.view as! SKView? {
                view.presentScene(gameSceneNode)
                view.ignoresSiblingOrder = true
                
                //Debug settings
                //TODO: remove for release
                view.showsFPS = true
                view.showsNodeCount = true
                
            }
        }
    }
}


extension GameViewController: GameSceneDelegate {
    func reset() {
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let remove = SKAction.removeFromParent()
        gameSceneNode?.run(SKAction.group([fadeOut, remove])) { [weak self] in
            self?.startLevel()
        }
    }
}
