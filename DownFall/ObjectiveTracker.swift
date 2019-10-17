//
//  ObjectiveTracker.swift
//  DownFall
//
//  Created by William Katz on 7/23/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

let objectiveBackgroundId = "objectiveBackgroundId"

protocol ProvidesObjectiveData {
    var shouldSpawnExit: Bool { get }
}

enum Goal {
    case exit
}

enum RotateDirection {
    case left
    case right
}

class ObjectiveTracker {
    let goal: Goal
    let absoluteDirection: Direction
    var distance: Int
    let initialDistance: Int
    var relativeDirection: Direction
    let playableRect: CGRect
    weak var foreground: SKNode?
    var hasSpawnedExit = false
    
    init(goal: Goal,
         objectiveAbsoluteDirection: Direction,
         objectiveDistance: Int,
         playableRect: CGRect,
         foreground: SKNode) {
        self.goal = goal
        self.absoluteDirection = objectiveAbsoluteDirection
        self.distance = objectiveDistance
        self.initialDistance = objectiveDistance
        self.relativeDirection = objectiveAbsoluteDirection
        self.playableRect = playableRect
        self.foreground = foreground
        
        foreground.addChild(createForeground)
        
//        Dispatch.shared.register { [weak self] (input) in
//            switch input.type {
//            case .rotateLeft:
//                self?.rotated(.left)
//            case .rotateRight:
//                self?.rotated(.right)
//            case .transformation(let trans):
//                if let inputType = trans.inputType {
//                    switch inputType {
//                    case .touch(_, _):
//                        if let newTilesCount = trans.tileTransformation?[1].count {
//                            self?.explored(newTilesCount)
//                        }
//                        if !(self?.hasSpawnedExit ?? false) {
//                            if let endTiles = trans.endTiles {
//                                for i in 0..<endTiles.count {
//                                    for j in 0..<endTiles[i].count {
//                                        if endTiles[i][j] == .exit {
//                                            self?.hasSpawnedExit = true
//                                            self?.delete()
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    default:
//                        ()
//                    }
//                }
//
//            default:
//                ()
//            }
//        }
    }
    
    private func explored(_ numberOfRocks: Int) {
        if relativeDirection == absoluteDirection {
            distance -= numberOfRocks
            distance = max(distance, 0)
            update()
        }
    }
    
    private func rotated(_ dir: RotateDirection) {
        switch (relativeDirection, dir) {
            
        //rotating left
        case (.north, .left):
            relativeDirection = .west
        case (.west, .left):
            relativeDirection = .south
        case (.south, .left):
            relativeDirection = .east
        case (.east, .left):
            relativeDirection = .north
            
        //rotating right
        case (.north, .right):
            relativeDirection = .east
        case (.east, .right):
            relativeDirection = .south
        case (.south, .right):
            relativeDirection = .west
        case (.west, .right):
            relativeDirection = .north
        case (.northEast, _),
             (.southEast, _),
             (.northWest, _),
             (.southWest, _):
            ()
        }
        
        //update view
        update()
    }
    
    
    func delete() {
        for child in foreground?.children ?? [] {
            if child.name == objectiveBackgroundId {
                child.removeFromParent()
            }
        }
    }
    
    func update() {
        delete()
        if !hasSpawnedExit {
            foreground?.addChild(createForeground)
        }
    }
    
    private var createForeground: SKNode {
        let arrowSize: Double = 105
        let exitSpriteSize: Double = 125
        
        let objectiveForeground = SKNode()
        let objectiveBackground = SKSpriteNode(color: .lightGray,
                                               size: CGSize(width: playableRect.width * 0.9,
                                                            height: 150))
        
        
        let objectiveArrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"),
                                          size: CGSize(width: arrowSize, height: arrowSize))
        objectiveArrow.zRotation = zRotation
        objectiveArrow.position = CGPoint(x: objectiveBackground.frame.width/2 - (2*objectiveArrow.frame.width) - 50,
                                          y: (objectiveBackground.frame.height/2 - objectiveArrow.frame.height/2) / 2)

        let exitSprite = SKSpriteNode(texture: SKTexture(imageNamed: "exit"),
                                      size: CGSize(width: exitSpriteSize,
                                                   height: exitSpriteSize))
        exitSprite.zPosition = Precedence.foreground.rawValue
        exitSprite.position = CGPoint(x: objectiveBackground.frame.width/2 - exitSprite.frame.width - 15,
                                      y: (objectiveBackground.frame.height/2 - exitSprite.frame.height/2) / 2)
        
        let distanceLabel = SKLabelNode(fontNamed: "Helvetica-bold")
        distanceLabel.fontSize = 36
        switch abs(distance) {
        case 0..<10 :
            distanceLabel.text = "Almost there!"
        case 10..<30:
            distanceLabel.text = "It's getting closer, I can feel it!"
        case 30...Int.max:
            distanceLabel.text = "The exit is far away."
        default:
            () // Silly compiler, this is impossible
        }
        distanceLabel.position = CGPoint(x: -objectiveBackground.frame.width/2 + distanceLabel.frame.width + 15,
                                         y: (objectiveBackground.frame.height/2 - objectiveArrow.frame.height/2) / 2)
        
        objectiveBackground.addChild(distanceLabel)
        objectiveBackground.addChild(objectiveArrow)
        objectiveBackground.addChild(exitSprite)
        objectiveForeground.addChild(objectiveBackground)
        
        objectiveBackground.position = CGPoint(x: playableRect.midX, y: playableRect.maxY - 385 - 116)
        
        objectiveForeground.name = objectiveBackgroundId
        
        return objectiveForeground
    }
    
    public var zRotation: CGFloat {
        switch relativeDirection {
        case .north:
            return 0
        case .west:
            return .pi / 2 * 1
        case .south:
            return .pi / 2 * 2
        case .east:
            return .pi / 2 * 3
        case .northEast,
             .southEast,
             .northWest,
             .southWest:
            fatalError("We should not be rotating like this!")
        }
    }
    
    public var uprightZRotation: CGFloat {
        switch relativeDirection {
        case .north:
            return 0
        case .west:
            return .pi / 2 * 3
        case .south:
            return .pi / 2 * 2
        case .east:
            return .pi / 2 * 1
        case .northEast,
             .southEast,
             .northWest,
             .southWest:
            fatalError("We should not be rotating like this!")
        }
    }

}


extension ObjectiveTracker: ProvidesObjectiveData {
    var shouldSpawnExit: Bool {
        return absoluteDirection == relativeDirection && distance == 0
    }
}
