//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

extension Notification.Name {
    static let shiftReplace = Notification.Name("shiftReplace")
    static let shiftDown = Notification.Name("shiftDown")
    static let removeTiles = Notification.Name("removeTiles")
    static let newTiles = Notification.Name("newTiles")
    static let transformation = Notification.Name("transformation")
    static let neighborsFound = Notification.Name("neighborsFound")
    static let rotated = Notification.Name("rotated")
}
typealias TileCoord = (Int, Int)

struct Transformation {
    let initial : (Int, Int)
    let end : (Int, Int)
}

class Board {
    
    var spriteNodes : [[DFTileSpriteNode]]
    var selectedTiles : [(Int, Int)]
    var newTiles : [(Int, Int)]
    var coordsToFill : [(Int, Int)]
    var transformation : [Transformation]
    
    var bottomLeft : (Int, Int) = (0,0)
    
    
    var tileSize = 50
    
    init(_ tiles: [[DFTileSpriteNode]]) {
        self.spriteNodes = tiles
        self.selectedTiles = []
        self.coordsToFill = []
        self.newTiles = []
        self.transformation = []
        bottomLeft = (-1 * tileSize/2 * spriteNodes.count, -1 * tileSize/2 * spriteNodes[0].count )
    }
    
    func findNeighbors(_ x: Int, _ y: Int){
        //consider saving space by keep track of head of queue, then just return the whole queue
        var queue : [(Int, Int)] = [(x, y)]
        var head = 0
        
        while head < queue.count {
            let (tileRow, tileCol) = queue[head]
            let tileSpriteNode = spriteNodes[tileRow][tileCol]
            tileSpriteNode.search = .black
            head += 1
            //add neighbors to queue
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    if valid(neighbor: (i,j), for: (tileRow, tileCol)) {
                        //potential neighbor within bounds
                        let neighbor = spriteNodes[i][j]
                        if neighbor.search == .white {
                            if neighbor.rockColor == tileSpriteNode.rockColor {
                                neighbor.search = .gray
                                queue.append((i,j))
                            }
                        }
                    }
                }
            }
        }
        resetVisited()
        selectedTiles = queue
        let note = Notification.init(name: .neighborsFound, object: nil, userInfo: ["tiles":selectedTiles])
        NotificationCenter.default.post(note)
    }
    
    func valid(neighbor : (Int, Int), for DFTileSpriteNode: (Int, Int)) -> Bool {
        let (neighborRow, neighborCol) = neighbor
        let (tileRow, tileCol) = DFTileSpriteNode
        guard neighborRow >= 0 && neighborRow < spriteNodes.count && neighborCol >= 0 && neighborCol < spriteNodes[neighborRow].count else {
            return false
        }
        let tileSum = tileRow + tileCol
        let neighborSum = neighborRow + neighborCol
        guard neighbor != DFTileSpriteNode else { return false }
        guard (tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0) else { return false }
        return true
    }
    
    func resetVisited() {
        for i in 0..<spriteNodes.count {
            for j in 0..<spriteNodes[i].count {
                spriteNodes[i][j].search = .white
            }
        }
        
        selectedTiles = []
        
    }

    
    func reset(size: Int) {
        for row in 0..<size {
            for col in 0..<size {
                spriteNodes[row][col] = DFTileSpriteNode.randomTile()
            }
        }
    }
    
    func shiftReplaceTiles() {
        removeTiles()
        //reflect the shift down
//        fillEmpty()
//        NotificationCenter.default.post(name: .shiftReplace, object: nil)

    }
    
    
    func removeTiles() {
        for (row, col) in selectedTiles {
            spriteNodes[row][col] = DFTileSpriteNode.init(color: .empty)
        }
        NotificationCenter.default.post(name: .removeTiles, object: nil)
        selectedTiles = []
    }
    
    func shiftDown() {
        transformation = []
        for col in 0..<spriteNodes.count {
            var shift = 0
            for row in 0..<spriteNodes[col].count {
                if spriteNodes[row][col].rockColor == .empty {
                    shift += 1
                } else {
                    if shift != 0 {
                        let trans = Transformation.init(initial: (row, col), end: (row-shift, col))
                        transformation.append(trans)
                        let intermediateTile = spriteNodes[row][col]
                        spriteNodes[row][col] = spriteNodes[row-shift][col]
                        spriteNodes[row-shift][col] = intermediateTile
                    }
                }
            }
            //could create newTiles array here
        }
        NotificationCenter.default.post(name: .shiftDown, object: nil, userInfo: ["transformation": transformation])
    }
    
    func fillEmpty() {
        newTiles = []
        for col in 0..<spriteNodes.count {
            for row in 0..<spriteNodes[col].count {
                if spriteNodes[row][col].rockColor == .empty {
                    newTiles.append((row, col))
                    spriteNodes[row][col] = DFTileSpriteNode.randomTile()
                }
            }
        }
        NotificationCenter.default.post(name: .newTiles, object: nil, userInfo: ["newTiles": newTiles])
    }
    
}

extension Board {
    
    func removeActions() {
        for i in 0..<spriteNodes.count {
            for j in 0..<spriteNodes[i].count {
                spriteNodes[i][j].removeAllActions()
                spriteNodes[i][j].run(SKAction.fadeIn(withDuration: 0.2))
            }
        }
    }
    
    func blinkTiles(at locations: [(Int, Int)]) {
        let blinkOff = SKAction.fadeOut(withDuration: 0.2)
        let blinkOn = SKAction.fadeIn(withDuration: 0.2)
        let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))
        
        for locale in locations {
            spriteNodes[locale.0][locale.1].run(blink)
        }
    }

}

extension Board {
    // class functions
    class func build(size: Int) -> Board {
        var tiles : [[DFTileSpriteNode]] = [[]]
        
        for row in 0..<size {
            if row != 0 { tiles.append([]) }
            for _ in 0..<size {
                tiles[row].append(DFTileSpriteNode.randomTile())
            }
        }
        
        return Board.init(tiles)
    }
}

// MARK: Rotation

extension Board {
    enum Direction {
        case left
        case right
    }
    
    func rotate(_ direction: Direction) {
        transformation = []
        var intermediateBoard : [[DFTileSpriteNode]] = []
        switch direction {
        case .left:
            let numCols = spriteNodes[0].count - 1
            for colIdx in 0..<spriteNodes[0].count {
                var count = 0
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<spriteNodes.count {
                    column.insert(spriteNodes[rowIdx][colIdx], at: 0)
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (colIdx, numCols - count))
                    transformation.append(trans)
                    count += 1
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        case .right:
            let numRows = spriteNodes.count - 1
            let numCols = spriteNodes[0].count - 1
            for colIdx in (0..<spriteNodes[0].count).reversed() {
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<spriteNodes.count {
                    column.append(spriteNodes[rowIdx][colIdx])
                    let endCol = numRows - rowIdx
                    let endRow = numCols - colIdx
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (endRow, rowIdx))
                    transformation.append(trans)
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        }
        
        NotificationCenter.default.post(name: .rotated, object: nil, userInfo: ["transformation": transformation])
    
    }
}

////MARK: CGPoint Helper
//
//extension Board {
//    func convert(point: CGPoint) -> CGPoint {
//        //convert a point to the foreground using the bottomLeft property
//
//    }
//}
