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
    
    //coordinates
    private var bottomLeft: (Int, Int)?
    
    //foreground
    private var foreground: SKNode!

    //animating
    private var animating: Bool = false
    
    //input queue
//    private var inputQueue: InputQueue!
    
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
        bottomLeft = (-1 * tileSize/2 * bsize, -1 * tileSize/2 * bsize)
        
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
        guard let transformation = board?.handle(input: input) else { animating = false; return }
        referee = Referee(transformation.endBoard)
        render(transformation, for: input)
    }
    
    
    /// Switches on input type and calls the appropriate function to determine the new board
    private func render(_ transformation: Transformation?, for input: Input) {
        guard let trans = transformation else { return }
        switch input{
        case .touch(_):
            board = trans.endBoard
            renderer?.computeNewBoard(for: trans)
        case .rotateLeft, .rotateRight:
            board = trans.endBoard
            renderer?.rotate(for: trans)
        case .playerAttack:
            // we should just render the new board here
//            render(board: trans.endBoard)
            return
        case .monsterAttack:
            self.animating = false
            return
        case .monsterDies(_):
            board = trans.endBoard
//            computeNewBoard(for: trans)
        case .gameWin:
            gameWin(trans)
        case .gameLose:
            gameLost()
        case .animationFinished:
            ()
        }
    }
}

// MARK: - Touch Relay

extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.renderer?.touchesEnded(touches, with: event)
    }
}

//MARK: - Game win and Game loss

extension GameScene {
    private func gameWin(_ transformation: Transformation) {
        guard let trans = transformation.tileTransformation?.first else { return }
//        animate(trans) { [weak self] in
//            guard let strongSelf = self else { return }
//            let wait = SKAction.wait(forDuration:0.5)
//            let action = SKAction.run { [weak self] in
//                guard let strongSelf = self else { return }
//                strongSelf.gameSceneDelegate?.shouldShowMenu(win: true)
//            }
//            strongSelf.run(SKAction.sequence([wait,action]))
//        }
    }
    
    private func gameLost() {
        let wait = SKAction.wait(forDuration:0.5)
        let action = SKAction.run { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.gameSceneDelegate?.shouldShowMenu(win: false)
        }
        self.run(SKAction.sequence([wait,action]))
    }
}
//MARK: - Communication from VC
extension GameScene {
    /// Debug only, use to reset the board easily
    private func reset() {
//        board = Board.build(size: boardSize!)
//        spriteNodes = createAndPositionSprites(from: board!.tiles)
//        foreground.removeAllChildren()
//        addSpriteTilesToScene()
    }
}

