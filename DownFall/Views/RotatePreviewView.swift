//
//  RotatePreviewView.swift
//  DownFall
//
//  Created by Katz, Billy on 3/21/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class RotatePreviewView {
    
    private var sprites: [[DFTileSpriteNode]] = []
    private var originalPosition: [[CGPoint]] = []
    private var finalPosition: [[CGPoint]] = []
    private var tileTransformation: [TileTransformation] = []
    private var originalInput: Transformation?
    private var distancedMoved = CGFloat(0.0)
    private var rotateInputType: InputType?
    private var distanceTraveledRatio: CGFloat = 0
    private let returnToStartRatio = CGFloat(0.33)
    
    init() {
        Dispatch.shared.register { [weak self] (input) in
            switch input.type {
            case let .rotatePreview(sprites, rotateTrans):
                self?.preview(sprites: sprites, rotateTransformation: rotateTrans)
            default:
                ()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func preview(sprites: [[DFTileSpriteNode]], rotateTransformation: Transformation) {
        self.sprites = sprites
        self.originalInput = rotateTransformation
        self.tileTransformation = rotateTransformation.tileTransformation?.first ?? []
        self.rotateInputType = rotateTransformation.inputType
        for spriteRow in 0..<sprites.count {
            originalPosition.append([])
            finalPosition.append([])
            for spriteCol in 0..<sprites.count {
                finalPosition[spriteRow].append(.zero)
                originalPosition[spriteRow].append(sprites[spriteRow][spriteCol].position)
            }
        }
        for tilePosition in self.tileTransformation {
            finalPosition[tilePosition.initial.row][tilePosition.initial.column] = originalPosition[tilePosition.end.row][tilePosition.end.column]
        }
    }
    
    public func touchesMoved(distance: CGFloat) {
        guard !sprites.isEmpty, !tileTransformation.isEmpty, !originalPosition.isEmpty,
            let inputType = self.rotateInputType else { return }
        
        // determine the total distance we must moved
        let totalDistance: CGFloat
        if case InputType.rotateClockwise = inputType {
            totalDistance = -300.0
        } else {
            totalDistance = 300.0
        }
        
        distancedMoved += distance
        self.distanceTraveledRatio = max(min(distancedMoved/totalDistance, 1.0), 0.0)
        for spriteRow in 0..<sprites.count {
            for spriteCol in 0..<sprites.count {
                let transformation = tileTransformation.first { (tileTrans) -> Bool in
                    tileTrans.initial == TileCoord(spriteRow, spriteCol)
                }
                
                guard let tileTrans = transformation else { fatalError() }
                
                let sprite = sprites[spriteRow][spriteCol]
                let originalSpritePosition = originalPosition[tileTrans.initial.row][tileTrans.initial.column]
                let rotatedSpritePosition = originalPosition[tileTrans.end.row][tileTrans.end.column]
                
                let vector = rotatedSpritePosition - originalSpritePosition
                let newSpritePosition = CGPoint(x: originalSpritePosition.x + vector.dx * distanceTraveledRatio, y: originalSpritePosition.y + vector.dy * distanceTraveledRatio)
                
                /// set the new position
                sprite.position = newSpritePosition

                
                
            }
        }
    }
    
    public func touchesEnded() {
        defer {
            rotateInputType = nil
            distancedMoved = 0
            sprites = []
            originalPosition = []
            finalPosition = []
            tileTransformation = []
            distanceTraveledRatio = 0
            originalInput = nil
        }
        
        
        guard !sprites.isEmpty, !originalPosition.isEmpty else { return }
        var spriteActions: [SpriteAction] = []
        let returnToStart = distanceTraveledRatio < returnToStartRatio
        for row in 0..<sprites.count {
            for col in 0..<sprites.count {
                let position = returnToStart ? originalPosition[row][col] : finalPosition[row][col]
                spriteActions.append(SpriteAction(sprite: sprites[row][col], action: SKAction.move(to: position, duration: AnimationSettings.RotatePreview.finishRotateSpeed)))
            }
        }
        
        InputQueue.append(Input(.rotatePreviewFinish(spriteActions, returnToStart ? nil : originalInput)))
    }
    
}
