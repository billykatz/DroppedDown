//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    
    // only strong reference to the Board
    private var board: Board!
    
    // the board size
    private var boardSize: Int!
    
    //foreground
    private var foreground: SKNode!
    
    // delegate
    weak var gameSceneDelegate: GameSceneCoordinatingDelegate?
    
    //renderer
    private var renderer: Renderer?
    
    //Generator
    private var generator: HapticGenerator?
    
    //swipe recognizer view
    private var swipeRecognizerView: SwipeRecognizerView?
    
    //level
    private var level: Level?
    
    //touch state
    private var touchWasSwipe = false
    private var touchWasCanceled = false
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparation neccessary for didMove(to:) to be called
    public func commonInit(boardSize: Int,
                           entities: [EntityModel],
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel? = nil,
                           level: Level) {
        // init our level
        self.level = level
        
        //create the foreground node
        foreground = SKNode()
        foreground.position = .zero
        addChild(foreground)
        
        //init our tile creator
        let tileCreator = TileCreator(entities,
                                      difficulty: difficulty,
                                      updatedEntity: updatedEntity,
                                      level: level)
        
        //board
        board = Board.build(size: boardSize, tileCreator: tileCreator, difficulty: difficulty)
        self.boardSize = boardSize
        
        // create haptic generator
        generator = HapticGenerator()
        
    }
    
    override func didMove(to view: SKView) {
    
        // create the renderer
        self.renderer = Renderer(playableRect: size.playableRect,
                                 foreground: foreground,
                                 boardSize: boardSize,
                                 precedence: Precedence.foreground)
        
        
        // SwipeRecognizerView
        swipeRecognizerView = SwipeRecognizerView(frame: view.frame,
                                                        target: self,
                                                        swiped: #selector(swiped))
        view.addSubview(swipeRecognizerView!)
        
        // Register for inputs we care about
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                guard let self = self else { return }
                
                self.foreground.removeAllChildren()
                self.removeFromParent()
                self.gameSceneDelegate?.reset(self)
            } else if input.type == .visitStore {
                guard let self = self,
                    let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                    else { return }
                
                self.foreground.removeAllChildren()
                if case let TileType.player(data) = self.board.tiles[playerIndex].type {
                    self.removeFromParent()
                    self.gameSceneDelegate?.visitStore(data)
                }

            }
        }

        //Turn watcher
        TurnWatcher.shared.register()
        
        //Debug settings triple tap
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tapRecognizer.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapRecognizer)
    }
    
    public func prepareForReuse() {
        board = nil
        renderer = nil
        foreground = nil
        gameSceneDelegate = nil
        generator = nil
        swipeRecognizerView?.removeFromSuperview()
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
}

//MARK: Swiping logic
extension GameScene {
    @objc func swiped(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard let inTop = self.view?.isInTop(gestureRecognizer),
            let onRight = self.view?.isOnRight(gestureRecognizer)
            else { return }
        
        touchWasSwipe = true
        switch gestureRecognizer.direction {
        case .down:
            onRight ? rotateClockwise() : rotateCounterClockwise()
        case .up:
            !onRight ? rotateClockwise() : rotateCounterClockwise()
        case .left:
            !inTop ? rotateClockwise() : rotateCounterClockwise()
        case .right:
            inTop ? rotateClockwise() : rotateCounterClockwise()
        default:
            fatalError("There should only be four directions in our swipe gesture recognizer")
        }
    }
}

//MARK: - Rotate
extension GameScene {
    private func rotateClockwise() {
        InputQueue.append(Input(.rotateClockwise))
    }
    private func rotateCounterClockwise() {
        InputQueue.append(Input(.rotateCounterClockwise))
    }
}

// MARK: - Debug

extension GameScene {
    
    @objc private func tripleTap(_ sender: UITapGestureRecognizer) {
        if sender.numberOfTapsRequired == 3 {
            let touchLocation = sender.location(in: view)
            let newTouch = convertPoint(fromView: touchLocation)
            
            if self.nodes(at: newTouch).contains(where: { node in
                (node as? SKSpriteNode)?.name == "setting"
            }) {
                gameSceneDelegate?.reset(self)
            }
        }
    }
}

// MARK: - Update

extension GameScene {
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        Dispatch.shared.send(input)
    }
}

// MARK: - Touch Relay

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchWasSwipe = false
        self.renderer?.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // avoid inputing touchEnded when a touch is cancelled.
        if !touchWasSwipe {
            touchWasCanceled = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchWasSwipe {
            guard !touchWasCanceled else {
                touchWasCanceled = false
                return
            }
            self.renderer?.touchesEnded(touches, with: event)
        }
    }
}
