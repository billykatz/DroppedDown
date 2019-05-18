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
    func shouldShowMenu(win: Bool)
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
    
    //deleagte
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //game referee
    private var referee: Referee?
    
    //renderer
    private var renderer: Renderer?
    
    //playable margin
    private var playableRect: CGRect?

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparationg necessary for didMove(to:) to be called
    public func commonInit(boardSize bsize: Int, difficulty: Difficulty = .normal){
        //TODO: the  order of the following lines of code matter.  (bottom left has to happen before create and position. Consider refactoring
        InputQueue.reset()
        TileCreator.reset()
        
        self.difficulty = difficulty
        board = Board.build(size: bsize)
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
        
        
        
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                self?.gameSceneDelegate?.reset()
            }
        }
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
