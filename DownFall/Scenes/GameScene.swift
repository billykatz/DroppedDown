//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit
import GameplayKit

protocol GameSceneCoordinatingDelegate: class {
    func navigateToMainMenu(_ scene: SKScene, playerData: EntityModel)
//    func lostGame(_ scene: SKScene, playerData: EntityModel)
    
    func visitStore(_ playerData: EntityModel, _ goalProgress: [GoalTracking])
}


class GameScene: SKScene {
    
    struct Constants {
        static let swipeDistanceThreshold = CGFloat(25.0)
        static let quickSwipeDistanceThreshold = CGFloat(100.0)
    }
    
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
    private var lastPosition: CGPoint?
    private var swipeDirection: SwipeDirection?
    
    // rotate preview
    private var rotatePreview: RotatePreviewView?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparation neccessary for didMove(to:) to be called
    public func commonInit(boardSize: Int,
                           entities: EntitiesModel,
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel? = nil,
                           level: Level,
                           randomSource: GKLinearCongruentialRandomSource?) {
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
                                      level: level,
                                      randomSource: randomSource ?? GKLinearCongruentialRandomSource())
        
        //board
        board = Board.build(tileCreator: tileCreator, difficulty: difficulty, level: level)
        self.boardSize = boardSize
        
        // create haptic generator
        generator = HapticGenerator()
        
    }
    
    override func didMove(to view: SKView) {
        
        // preview view
        self.rotatePreview = RotatePreviewView()
    
        // create the renderer
        self.renderer = Renderer(playableRect: size.playableRect,
                                 foreground: foreground,
                                 boardSize: boardSize,
                                 precedence: Precedence.foreground,
                                 level: level!
        )
        
        
        // Register for inputs we care about
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                guard let self = self,
                let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                else { return }
                
                self.foreground.removeAllChildren()
                if case let TileType.player(data) = self.board.tiles[playerIndex].type {
                    self.removeFromParent()
                    self.swipeRecognizerView?.removeFromSuperview()
                    self.gameSceneDelegate?.navigateToMainMenu(self, playerData: data)
                }
            } else if case InputType.transformation(let trans) = input.type, let firstInputType = trans.first?.inputType {
                if case InputType.runeProgressRecord(_) = firstInputType {
                    guard let self = self,
                        let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                        else { return }
                    
                    self.foreground.removeAllChildren()
                    if case let TileType.player(data) = self.board.tiles[playerIndex].type {
                        self.removeFromParent()
                        self.swipeRecognizerView?.removeFromSuperview()
                        self.gameSceneDelegate?.visitStore(data, [])
                    
                    }
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
        rotatePreview = nil
        swipeRecognizerView?.removeFromSuperview()
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
}

//MARK: Touch and Swiping logic
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchWasSwipe = false
        self.renderer?.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // avoid inputing touchEnded when a touch is cancelled.
        touchWasCanceled = true
        touchWasSwipe = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self.foreground)
        
        // set the lastPosition once until we have detected a swipe
        if lastPosition == nil {
            lastPosition = currentPosition
        }
        guard let lastPosition = lastPosition, (abs(currentPosition.x - lastPosition.x) > Constants.swipeDistanceThreshold || abs(currentPosition.y - lastPosition.y) > Constants.swipeDistanceThreshold || touchWasSwipe) else {
            touchWasSwipe = false
            return
        }
        touchWasSwipe = true
        
        // deteremine the vector of the swipe
        let vector = currentPosition - lastPosition
        // set the swipe for the duration of this swipe gesture
        let touchIsOnRight = (view?.isOnRight(currentPosition) ?? false)
        if self.swipeDirection == nil {
            let swipeDirection = SwipeDirection(from: vector)
            
            /// finally set the swipeDirection
            self.swipeDirection = swipeDirection
            
            /// deteremine which clock rotation to apply
            let rotateDir = RotateDirection(from: swipeDirection, isOnRight: touchIsOnRight)
            
            /// call functions that send rotate input
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
            var distance: CGFloat
            switch swipeDirection {
            case .up, .down:
                distance = vector.dy
            }
            distance *= (touchIsOnRight ? 1 : -1)
            self.rotatePreview?.touchesMoved(distance: distance)
        }
        
        // set the last position for the next update
        self.lastPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            self.renderer?.touchesEnded(touches, with: event)
            self.lastPosition = nil
            self.swipeDirection = nil
            self.touchWasSwipe = false
        }
        
        if !touchWasSwipe {
            guard !touchWasCanceled else {
                touchWasCanceled = false
                return
            }
        } else {
            self.rotatePreview?.touchesEnded()
        }
    }
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
