//
//  TutorialScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit

class TutorialScene: SKScene {
    var gameSceneDelegate: GameSceneDelegate?
    
    // only strong reference to the Board
    private var board: Board!
    
    // the board size
    private var boardSize: Int!
    
    //foreground
    private var foreground: SKNode!
    
    //renderer
    private var renderer: Renderer?
    
    //Generator
    private var generator: HapticGenerator?
    
    //touch state
    private var touchWasSwipe = false
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparation neccessary for didMove(to:) to be called
    public func commonInit(boardSize: Int,
                           entities: [EntityModel],
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel? = nil) {
        //create the foreground node
        foreground = SKNode()
        foreground.position = .zero
        addChild(foreground)
        
        //init our tile creator
        let tileCreator = TutorialTileCreator(entities,
                                              difficulty: difficulty,
                                              updatedEntity: updatedEntity)
        
        //board
        board = Board.build(size: boardSize, tileCreator: tileCreator, difficulty:  difficulty)
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
        let swipingRecognizerView = SwipeRecognizerView(frame: view.frame,
                                                        target: self,
                                                        swiped: #selector(swiped))
        view.addSubview(swipingRecognizerView)
        
        // TutorialView
        let tutorialView = TutorialView(tutorialData: GameScope.tutorialOne,
                                        texture: nil,
                                        color: .clear,
                                        size:  CGSize(width: size.playableRect.width, height: size.playableRect.height))
        tutorialView.position = .zero
        tutorialView.zPosition = Precedence.menu.rawValue
        
        foreground.addChild(tutorialView)
        
        // Register for inputs we care about
        Dispatch.shared.register { [weak self] input in
            if input.type == .visitStore {
                guard let self = self,
                    let playerIndex = tileIndices(of: .player(.zero), in: self.board.tiles).first
                    else { return }
                
                self.foreground.removeAllChildren()
                if case let TileType.player(data) = self.board.tiles[playerIndex].type {
                    let revivedData = data.revive()
                    self.removeFromParent()
                    self.gameSceneDelegate?.visitStore(revivedData)
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
        generator = nil
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
}

//MARK: Swiping logic
extension TutorialScene {
    
    @objc func swiped(_ gestureRecognizer: UISwipeGestureRecognizer) {
        let inTop = isInTop(gestureRecognizer: gestureRecognizer)
        let onRight = isOnRight(gestureRecognizer: gestureRecognizer)
        touchWasSwipe = true
        switch gestureRecognizer.direction {
        case .down:
            onRight ? rotateRight() : rotateLeft()
        case .up:
            !onRight ? rotateRight() : rotateLeft()
        case .left:
            !inTop ? rotateRight() : rotateLeft()
        case .right:
            inTop ? rotateRight() : rotateLeft()
        default:
            fatalError("There should only be four directions in our swipe gesture recognizer")
        }
    }
    
    private func isOnRight(gestureRecognizer: UISwipeGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.view)
        return location.x > (self.view?.frame.width ?? 0)/2
    }
    
    private func isInTop(gestureRecognizer: UISwipeGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.view)
        return location.y < (self.view?.frame.height ?? 0)/2
    }
}

//MARK: - Rotate
extension TutorialScene {
    private func rotateRight() {
        if allowedToRotate(clockwise: true) {
            InputQueue.append(Input(.rotateClockwise))
        }
    }
    private func rotateLeft() {
        if allowedToRotate(clockwise: false) {
            InputQueue.append(Input(.rotateCounterClockwise))
        }
    }
    
    func allowedToRotate(clockwise: Bool) -> Bool {
        let rotateDirectionInput : InputType = clockwise ? .rotateClockwise : .rotateCounterClockwise
        let data = GameScope.tutorialOne
        return  rotateDirectionInput == data.currentStep.inputToContinue
    }
}

// MARK: - Update

extension TutorialScene {
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        Dispatch.shared.send(input)
    }
}

// MARK: - Touch Relay

extension TutorialScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchWasSwipe = false
        self.renderer?.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // avoid inputing touchEnded when a touch is cancelled.
        // FIXME: there is probably a better way to fix this
        touchWasSwipe = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchWasSwipe {
            self.renderer?.touchesEnded(touches, with: event)
        }
    }
}


// MARK: - Debug

extension TutorialScene {
    
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
