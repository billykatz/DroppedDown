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
    private var board: Board? {
        didSet {
            if board != nil {
                referee = Referee(board!)
            }
        }
    }
    
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
        self.difficulty = difficulty
        board = Board.build(size: bsize)
        boardSize = bsize
        
        referee = Referee(board!)
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
                                 board: self.board!)
    }
    
    /// Called every frame
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        route(board?.handle(input: input), for: input)
    }
    
    
    /// Switches on input type and calls the appropriate function to determine the new board
    private func route(_ transformation: Transformation?, for input: Input) {
        switch input.type {
        case .touch, .rotateRight, .rotateLeft, .monsterDies, .playerAttack, .monsterAttack, .gameWin, .gameLose:
            board = transformation?.endBoard
        case .play, .pause, .animationsFinished:
            //we only need to pass along the input
            ()
        case .playAgain:
            gameSceneDelegate?.reset()
        }
        //route the transformation and input to the Renderer
        renderer?.render(transformation, for: input)
        
        if input.userGenerated {
            Referee.enforceRules(transformation?.endBoard).forEach {
                InputQueue.append($0)
            }
        }
    }
}

// MARK: - Touch Relay

extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.renderer?.touchesEnded(touches, with: event)
    }
}

