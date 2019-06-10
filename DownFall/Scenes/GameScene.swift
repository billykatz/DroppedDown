//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

protocol GameSceneDelegate: class {
    func reset()
}

class GameScene: SKScene {
    
    private var tileSize = 100
    private var boardSize: Int?
    private var board: Board?
    
    //foreground
    private var foreground: SKNode!
    
    //diffculty
    private var difficulty: Difficulty?
    
    //delegate
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //game referee
    private var referee: Referee?
    
    //renderer
    private var renderer: Renderer?
    
    //TileCreator
    private var tileCreator: TileCreator?
    
    //playable margin
    private var playableRect: CGRect?

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparationg necessary for didMove(to:) to be called
    public func commonInit(boardSize bsize: Int,
                           entities: [EntityModel],
                           difficulty: Difficulty = .normal){
        //TODO: the  order of the following lines of code matter.  (bottom left has to happen before create and position. Consider refactoring
        InputQueue.reset()
        tileCreator = TileCreator(entities)
        self.difficulty = difficulty
        board = Board.build(size: bsize, tileCreator: tileCreator!)
        boardSize = bsize
    }
    
    override func didMove(to view: SKView) {
        foreground = self.childNode(withName: "foreground")!
        
        //Adjust the playbale rect depending on the size of the device
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableRect = CGRect(x: -playableWidth/2,
                              y: -size.height/2,
                              width: playableWidth,
                              height: size.height)
        self.renderer = Renderer(playableRect: playableRect,
                                 foreground: foreground,
                                 board: self.board!,
                                 precedence: Precedence.foreground)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tapRecognizer.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapRecognizer)
        
        view.addSubview(createLeftSwipeView(playableWidth))
        view.addSubview(createRightSwipeView(playableWidth))
        
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                self?.gameSceneDelegate?.reset()
            }
        }
    }
    
}

// MARK: - Swipe Controls

extension GameScene {
    
    private func createRightSwipeView(_ playableWidth: CGFloat) -> SKView {
        let rightSubView = SKView(frame: CGRect(x: self.view!.frame.width/2,
                                                y: -size.height/2,
                                                width: playableWidth/2,
                                                height: size.height))
        rightSubView.allowsTransparency = true
        rightSubView.backgroundColor = .clear
        rightSubView.alpha = 0.05
        
        let rightHalfSwipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightHalfSwipeUp))
        rightHalfSwipeUpRecognizer.direction = .up
        
        let rightHalfSwipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightHalfSwipeDown))
        rightHalfSwipeDownRecognizer.direction = .down
        
        rightSubView.addGestureRecognizer(rightHalfSwipeUpRecognizer)
        rightSubView.addGestureRecognizer(rightHalfSwipeDownRecognizer)
        return rightSubView
    }
    
    
    private func createLeftSwipeView(_ playableWidth: CGFloat) -> SKView {
        let leftSubView = SKView(frame: CGRect(x: (self.view!.frame.width/2) - (playableWidth/2),
                                                y: -size.height/2,
                                                width: playableWidth/2,
                                                height: size.height))
        leftSubView.alpha = 0.05
        leftSubView.backgroundColor = .clear
        leftSubView.allowsTransparency = true
        let leftHalfSwipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftHalfSwipeUp))
        leftHalfSwipeUpRecognizer.direction = .up
        
        let leftHalfSwipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftHalfSwipeDown))
        leftHalfSwipeDownRecognizer.direction = .down
        
        leftSubView.addGestureRecognizer(leftHalfSwipeUpRecognizer)
        leftSubView.addGestureRecognizer(leftHalfSwipeDownRecognizer)
        leftSubView.backgroundColor = .clear
        return leftSubView
    }
    
    @objc func rightHalfSwipeUp(_ sender: UITapGestureRecognizer) {
        let input = Input(.rotateLeft)
        InputQueue.append(input)
    }
    
    @objc func rightHalfSwipeDown(_ sender: UITapGestureRecognizer) {
        let input = Input(.rotateRight)
        InputQueue.append(input)
    }
    
    @objc func leftHalfSwipeDown(_ sender: UITapGestureRecognizer) {
        let input = Input(.rotateLeft)
        InputQueue.append(input)
    }
    
    @objc func leftHalfSwipeUp(_ sender: UITapGestureRecognizer) {
        let input = Input(.rotateRight)
        InputQueue.append(input)
    }
    
    
    @objc func tripleTap(_ sender: UITapGestureRecognizer) {
        
        if sender.numberOfTapsRequired == 3 {
            let touchLocation = sender.location(in: view)
            let newTouch = convertPoint(fromView: touchLocation)
            
            if self.nodes(at: newTouch).contains(where: { node in
                (node as? SKSpriteNode)?.name == "setting"
            }) {
                gameSceneDelegate?.reset()
            }
        } else  if sender.numberOfTapsRequired == 2 {
            let touchLocation = sender.location(in: view)
            let newTouch = convertPoint(fromView: touchLocation)
            
            if self.nodes(at: newTouch).contains(where: { node in
                (node as? SKSpriteNode)?.name == "setting"
            }) {
                debugPrint(InputQueue.debugDescription)
            }

        }
    }
}

// MARK: - Update
    
extension GameScene {
    /// Called every frame
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        Dispatch.shared.send(input)
    }
}

// MARK: - Touch Relay

extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.renderer?.touchesEnded(touches, with: event)
    }
}
