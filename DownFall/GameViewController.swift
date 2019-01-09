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

    private var gameSceneNode: GameScene?
    private var menuScene: Menu?
    private var boardSize = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLevel()
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [.portrait, .portraitUpsideDown]
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController {
    func startLevel() {
        if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene {
            gameSceneNode = scene
            gameSceneNode!.scaleMode = .aspectFill
            gameSceneNode!.gameSceneDelegate = self
            gameSceneNode!.commonInit(boardSize: boardSize)
            
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


// MARK: - MenuDelegate
extension GameViewController: MenuDelegate {
    func didTapPrimary() {
        startLevel()
    }
    
    func didTapSecondary() {
        //TODO: implement secondary button
        print("did tap secondary")
    }
}

extension GameViewController: GameSceneDelegate {
    func shouldShowMenu(win: Bool) {
        menuScene = nil
        gameSceneNode = nil
        guard let view = self.view as? SKView else { return }
        if win {
            boardSize += 1
            let menu = SKScene(fileNamed: "Menu") as! Menu
            menu.menuDelegate = self
            menuScene = menu
            view.presentScene(menuScene)
            menuScene?.configure(title: "You Won :)", primary: "Play Again?", secondary: nil, delegate: self)
        } else {
            boardSize -= 1
            view.presentScene(menuScene)
            gameSceneNode = nil
            menuScene?.configure(title: "You Lost :(", primary: "Play Again?", secondary: nil, delegate: self)
        }
    }
}
