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
    
    //boss controller
    private var bossController: BossController?
    
    //touch state
    private var touchWasSwipe = false
    private var touchWasCanceled = false
    
    // rotate preview
    private var rotatePreview: RotatePreviewView?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparation neccessary for didMove(to:) to be called
    public func commonInit(boardSize: Int,
                           entities: EntitiesModel,
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel? = nil,
                           level: Level) {
        // init our level
        self.level = level
        Referee.injectLevel(level)
        
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
        board = Board.build(tileCreator: tileCreator, difficulty: difficulty, level: level)
        self.boardSize = boardSize
        
        // create haptic generator
        generator = HapticGenerator()
        
        // create boss controller
        if level.type == .boss {
            bossController = BossController(foreground: foreground, playableRect: size.playableRect, levelSize: level.boardSize, boardSize: boardSize)
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        // preview view
        self.rotatePreview = RotatePreviewView()
    
        // create the renderer
        self.renderer = Renderer(playableRect: size.playableRect,
                                 foreground: foreground,
                                 boardSize: boardSize,
                                 precedence: Precedence.foreground,
                                 level: level!,
                                 touchDelegate: self
        )
        
        
        // Register for inputs we care about
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                guard let self = self,
                let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                else { return }
                
                self.foreground.removeAllChildren()
                if case TileType.player = self.board.tiles[playerIndex].type {
                    self.removeFromParent()
                    self.swipeRecognizerView?.removeFromSuperview()
                    self.gameSceneDelegate?.resetToMain(self)
                }

            } else if input.type == .visitStore {
                guard let self = self,
                    let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                    else { return }
                
                self.foreground.removeAllChildren()
                if case let TileType.player(data) = self.board.tiles[playerIndex].type {
                    self.removeFromParent()
                    self.swipeRecognizerView?.removeFromSuperview()
                    self.gameSceneDelegate?.visitStore(data)
                }

            }
        }

        //Turn watcher
        TurnWatcher.shared.register()
    }
    
    public func prepareForReuse() {
        board = nil
        renderer = nil
        foreground = nil
        gameSceneDelegate = nil
        generator = nil
        bossController = nil
        rotatePreview = nil
        swipeRecognizerView?.removeFromSuperview()
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
    
    
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
    
    private var lastPosition: CGPoint?
    private var swipeDirection: SwipeDirection?
    enum SwipeDirection {
        case right
        case left
        
        init(from vector: CGVector) {
            if vector.dx > 0 { self = .right }
            else { self = .left }
        }
    }
    
    enum RotateDirection {
        case counterClockwise
        case clockwise
        
        init(from swipeDirection: SwipeDirection) {
            switch swipeDirection {
            case .right:
                self = .counterClockwise
            case .left:
                self = .clockwise
            }
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self.foreground)
        if lastPosition == nil {
            lastPosition = currentPosition
        }
        guard let lastPosition = lastPosition, (abs(currentPosition.x - lastPosition.x) > 25.0 || abs(currentPosition.y - lastPosition.y) > 25.0 || touchWasSwipe) else {
            return
        }
        touchWasSwipe = true
        
        // deteremine the vector of the swipe
        let vector = currentPosition - lastPosition
        // set the swipe for the duration of this swipe gesture
        if self.swipeDirection == nil && !(view?.isInTop(currentPosition) ?? true) {
            let swipeDirection = SwipeDirection(from: vector)
            self.swipeDirection = swipeDirection
            
            let rotateDir = RotateDirection(from: swipeDirection)
            
            switch rotateDir {
            case .clockwise:
                rotateClockwise(preview: true)
            case .counterClockwise:
                rotateCounterClockwise(preview: true)
            }
        }
        
        
        /// update the preview view
        if touchWasSwipe {
            guard let swipeDirection = swipeDirection else { return }
            let distance: CGFloat
            switch swipeDirection {
            case .left, .right:
                distance = vector.dx
            }
            self.rotatePreview?.touchesMoved(distance: distance)
        }
        
        // set the last position for the next update
        self.lastPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastPosition = nil
        self.swipeDirection = nil
        if !touchWasSwipe {
            guard !touchWasCanceled else {
                touchWasCanceled = false
                return
            }
            self.renderer?.touchesEnded(touches, with: event)
        } else {
            self.rotatePreview?.touchesEnded()
        }
        self.touchWasSwipe = false
    }
}

//MARK: Swiping logic
extension GameScene {
    
//    @objc func swiped(_ gestureRecognizer: UISwipeGestureRecognizer) {
//        guard let inTop = self.view?.isInTop(gestureRecognizer),
//            let onRight = self.view?.isOnRight(gestureRecognizer)
//            else { return }
//
//        touchWasSwipe = true
//        switch gestureRecognizer.direction {
//        case .down:
//            onRight ? rotateClockwise() : rotateCounterClockwise()
//        case .up:
//            !onRight ? rotateClockwise() : rotateCounterClockwise()
//        case .left:
//            !inTop ? rotateClockwise() : rotateCounterClockwise()
//        case .right:
//            inTop ? rotateClockwise() : rotateCounterClockwise()
//        default:
//            fatalError("There should only be four directions in our swipe gesture recognizer")
//        }
//    }
}

//MARK: - Rotate
extension GameScene {
    private func rotateClockwise(preview: Bool) {
        InputQueue.append(Input(.rotateClockwise(preview: preview)))
    }
    private func rotateCounterClockwise(preview: Bool) {
        InputQueue.append(Input(.rotateCounterClockwise(preview: preview)))
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

}
