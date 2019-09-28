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
    func selectLevel()
    func visitStore(_ playerData: EntityModel)
}

class GameScene: SKScene {
    
    private var boardSize: Int?
    private var board: Board?
    
    //foreground
    private var foreground: SKNode!
    
    //delegate
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //game referee
    private var referee: Referee?
    
    //renderer
    private var renderer: Renderer?
    
    //TileCreator
    private var tileCreator: TileCreator?
    
    //Generator
    private var generator: HapticGenerator?
    
    //playable margin
    private var playableRect: CGRect?
    
    //touch state
    private var touchWasSwipe = false
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparationg necessary for didMove(to:) to be called
    public func commonInit(boardSize bsize: Int,
                           entities: [EntityModel],
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel? = nil){
        //TODO: the  order of the following lines of code matter.  (bottom left has to happen before create and position. Consider refactoring
        InputQueue.reset()
        foreground = SKNode()
        foreground.position = .zero
        addChild(foreground)
        
        //playable rect
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        playableRect = CGRect(x: -playableWidth/2,
                              y: -size.height/2,
                              width: playableWidth,
                              height: size.height)
          
        
        //tile creatore
        tileCreator = TileCreator(entities,
                                  difficulty: difficulty,
                                  updatedEntity: updatedEntity)
        
        //board
        board = Board.build(size: bsize, tileCreator: tileCreator!)
        boardSize = bsize
        generator = HapticGenerator()
        
    }
    
    override func didMove(to view: SKView) {
        guard let board = board else { fatalError("failed to init board in commonInit()")}
        
        //Adjust the playbale rect depending on the size of the device
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        playableRect = CGRect(x: -playableWidth/2,
                              y: -size.height/2,
                              width: playableWidth,
                              height: size.height)
        self.renderer = Renderer(playableRect: playableRect!,
                                 foreground: foreground,
                                 board: board,
                                 precedence: Precedence.foreground)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tapRecognizer.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapRecognizer)
        
        let swipeUpGestureReconizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUpGestureReconizer.direction = .up
        view.addGestureRecognizer(swipeUpGestureReconizer)
        
        let swipeDownGestureReconizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDownGestureReconizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureReconizer)
        
        Dispatch.shared.register { [weak self] input in
            if input.type == .playAgain {
                self?.foreground.removeAllChildren()
                let player = board.tiles[board.tiles(of: .player(.zero)).first!]
                if case let TileType.player(data) = player {
                    let revivedData = data.revive()
                    self?.removeFromParent()
                    self?.gameSceneDelegate?.visitStore(revivedData)
                    view.removeGestureRecognizer(swipeUpGestureReconizer)
                    view.removeGestureRecognizer(swipeDownGestureReconizer)
                }
            }
            else if input.type == .selectLevel {
                self?.gameSceneDelegate?.selectLevel()
            }
        }
        
        //Turn watcher
        TurnWatcher.shared.register()
    }
    
    func prepareForReuse() {
        board = nil
        renderer = nil
        tileCreator = nil
        foreground = nil
        gameSceneDelegate = nil
        referee = nil
        generator = nil
        playableRect = nil
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
    
    @objc func swipedUp(_ gestureRecognizer: UISwipeGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.view)
        if isInRightHalf(location) {
            touchWasSwipe = true
            rotateLeft()
        }
    }
    
    @objc func swipedDown(_ gestureRecognizer: UISwipeGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.view)
        if isInRightHalf(location) {
            touchWasSwipe = true
            rotateRight()
        }
    }
    
    
}

//MARK: - Rotate
extension GameScene {
    func rotateRight() {
        let input = Input(.rotateRight)
        InputQueue.append(input)
    }
    func rotateLeft() {
        let input = Input(.rotateLeft)
        InputQueue.append(input)
    }
}

//MARK: - Coordinate Math

extension GameScene {
    
    func isInRightHalf(_ location: CGPoint) -> Bool {
        return rightHalf().contains(location)
    }
    //TODO: remove gesture recgonizers when the scene is not visible
    func rightHalf() -> CGRect {
        guard let playableRect = playableRect,
            let viewRect = self.view?.frame else { fatalError("No playable rect calculated") }
        return CGRect(x: viewRect.width/2,
                      y: viewRect.height/2 - playableRect.height/2,
                      width: playableRect.width/2,
                      height: playableRect.height)
        
    }
}

// MARK: - Debug

extension GameScene {
    
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchWasSwipe {
            self.renderer?.touchesEnded(touches, with: event)
        }
    }
}
