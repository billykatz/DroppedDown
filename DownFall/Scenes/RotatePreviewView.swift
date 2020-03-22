//
//  RotatePreviewView.swift
//  DownFall
//
//  Created by Katz, Billy on 3/21/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class RotatePreviewView {
    
    var sprites: [[DFTileSpriteNode]] = []
    var originalPosition: [[CGPoint]] = []
    var finalPosition: [[CGPoint]] = []
    var tileTransformation: [TileTransformation] = []
    var originalInput: Transformation?
    var totalDistance = CGFloat(300.0)
    var distancedMoved = CGFloat(0.0)
    var rotateInputType: InputType?
    var ratio: CGFloat = 0
    
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
    
    func preview(sprites: [[DFTileSpriteNode]], rotateTransformation: Transformation) {
        print("### rotate type \(rotateTransformation.inputType)")
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
        print(rotateTransformation.inputType!)
        print("We are here now")
    }
    
    func touchesMoved(distance: CGFloat) {
        guard !sprites.isEmpty, !tileTransformation.isEmpty, !originalPosition.isEmpty,
            let inputType = self.rotateInputType else { return }
        if case InputType.rotateClockwise = inputType {
            totalDistance = CGFloat(-300.0)
        } else {
            totalDistance = CGFloat(300.0)
        }
        distancedMoved += distance
        self.ratio = max(min(distancedMoved/totalDistance, 1.0), 0.0)
        for spriteRow in 0..<sprites.count {
            for spriteCol in 0..<sprites.count {
                let transformation = tileTransformation.first { (tileTrans) -> Bool in
                    tileTrans.initial == TileCoord(spriteRow, spriteCol)
                }
                
                guard let tileTrans = transformation else { fatalError() }
                
                let sprite = sprites[spriteRow][spriteCol]
                let originalSpritePosition = originalPosition[tileTrans.initial.row][tileTrans.initial.column]
                let rotatedSpritePosition = originalPosition[tileTrans.end.row][tileTrans.end.column]
                self.finalPosition[spriteRow][spriteCol] = rotatedSpritePosition
                
                let vector = rotatedSpritePosition - originalSpritePosition
                let newSpritePosition = CGPoint(x: originalSpritePosition.x + vector.dx * ratio, y: originalSpritePosition.y + vector.dy * ratio)
                
                /// set the new position
                sprite.position = newSpritePosition

                
                
            }
        }
    }
    
    private let returnToStartRatio = CGFloat(0.6)
    
    func touchesEnded() {
        guard !sprites.isEmpty, !originalPosition.isEmpty else {
            rotateInputType = nil
            distancedMoved = 0
            sprites = []
            originalPosition = []
            finalPosition = []
            tileTransformation = []
            totalDistance = 0.0
            ratio = 0
            originalInput = nil
            return
            
        }
        var spriteActions: [SpriteAction] = []
        let returnToStart = ratio < returnToStartRatio
        for row in 0..<sprites.count {
            for col in 0..<sprites.count {
                let position = returnToStart ? originalPosition[row][col] : finalPosition[row][col]
                spriteActions.append(SpriteAction(sprite: sprites[row][col], action: SKAction.move(to: position, duration: 0.07)))
            }
        }
        
        /*
         var sprites: [[DFTileSpriteNode]] = []
         var originalPosition: [[CGPoint]] = []
         var finalPosition: [[CGPoint]] = []
         var tileTransformation: [TileTransformation] = []
         var originalInput: Transformation?
         var totalDistance = CGFloat(300.0)
         var distancedMoved = CGFloat(0.0)
         var rotateInputType: InputType?
         var ratio: CGFloat = 0

         */
        
        rotateInputType = nil
        distancedMoved = 0
        sprites = []
        originalPosition = []
        finalPosition = []
        tileTransformation = []
        totalDistance = 0.0
        ratio = 0
        
        InputQueue.append(Input(.rotatePreviewFinish(spriteActions, returnToStart ? nil : originalInput)))
        
        originalInput = nil
    }
    
}
