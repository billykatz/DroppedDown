//
//  TargetView.swift
//  DownFall
//
//  Created by Katz, Billy on 3/14/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

protocol TargetViewModel {
    var currentTargets: [TileCoord] { get }
    var attackTargets: [BossController.BossAttack] { get }
}

protocol TargetingView {
    var viewModel: TargetViewModel? { get set }
    func dataUpdated()
}

class TargetView: TargetingView {
    private struct Constants {
        static let targetingViewName = "targetingView"
    }
    
    private let bottomLeft: CGPoint
    private let boardSize: CGFloat
    private let tileSize: CGFloat
    private let playableRect: CGRect
    private let foreground: SKNode
    
    private let view: SKSpriteNode
    private let targetingArea: SKSpriteNode
    
    var viewModel: TargetViewModel?
    
    init(foreground: SKNode, playableRect: CGRect, levelSize: Int, boardSize: CGFloat) {
        self.foreground = foreground
        self.playableRect = playableRect
        self.boardSize = boardSize
        
        // compute the tile size
        self.tileSize = GameScope.boardSizeCoefficient * (playableRect.width / CGFloat(levelSize))
        
        // center target area reticles
        let marginWidth = playableRect.width - CGFloat(tileSize * boardSize)
        let marginHeight = playableRect.height - CGFloat(tileSize * boardSize)
        let bottomLeftX = playableRect.minX + marginWidth/2 + tileSize/2
        let bottomLeftY = playableRect.minY + marginHeight/2 + tileSize/2
        self.bottomLeft = CGPoint(x: bottomLeftX, y: bottomLeftY)
        
        // create our container view
        self.view = SKSpriteNode(texture: nil, color: .clear, size: playableRect.size)
        self.view.zPosition = Precedence.foreground.rawValue
        self.view.position = .zero
        
        self.targetingArea = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height))
        self.targetingArea.position = view.frame.center
        self.targetingArea.name = Constants.targetingViewName
        
        view.addChildSafely(targetingArea)
        foreground.addChild(view)
    }
    
    func dataUpdated() {
        targetingArea.removeAllChildren()
        updateTargetArea()
        updateTargetReticles()
        updateAttackReticles()
    }
    
    private func updateTargetArea() {
        
    }
    
    private func updateTargetReticles() {
        
        for target in viewModel?.currentTargets ?? [] {
            let position = translateCoord(target)
            let reticle = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: CGSize(width: tileSize, height: tileSize))
            reticle.position = position
            reticle.zPosition = Precedence.menu.rawValue
            targetingArea.addChildSafely(reticle)
        }
        
    }
    
    private let identifier: String = Identifiers.Sprite.redReticle
    
    private func updateAttackReticles() {
        
        var targets: [TileCoord] = []
        for attack in viewModel?.attackTargets ?? [] {
            switch attack {
            case .bomb(let target):
                targets.append(target)
            case .spawn(let target):
                targets.append(target)
            case .destroy(let setTarget):
                targets.append(contentsOf: setTarget)
            case .hair(let setTarget):
                targets.append(contentsOf: setTarget)
            }
        }
        for target in targets {
            let position = translateCoord(target)
            let reticle = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: CGSize(width: tileSize, height: tileSize))
            reticle.position = position
            reticle.zPosition = Precedence.menu.rawValue
            targetingArea.addChildSafely(reticle)
        }
    }
    

    
    private func translateCoord(_ coord: TileCoord) -> CGPoint {
        
        //tricky, but the row (x) corresponds to the column which start at 0 on the left with the n-1th the farthest right on the board. And the Y coordinate corresponds to the x-axis or the row, that starts at 0 and moves up the screen with the n-1th row at the top of the board.
        let x = CGFloat(coord.column) * tileSize + bottomLeft.x
        let y = CGFloat(coord.row) * tileSize + bottomLeft.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func translatePoint(_ point: CGPoint) -> TileCoord {
        var x = Int(round((point.x - bottomLeft.x) / tileSize))
        
        var y = Int(round((point.y - bottomLeft.y) / tileSize))
        
        //ensure that the coords are in bounds because we allow some touches outside the board
        y = max(0, y)
        y = min(Int(boardSize-1), y)
        
        x = max(0, x)
        x = min(Int(boardSize-1), x)
        
        return TileCoord(y, x)
    }
    
    
    
}
