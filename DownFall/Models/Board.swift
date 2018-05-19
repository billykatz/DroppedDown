//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//


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

struct Transformation {
    let initial : (Int, Int)
    let end : (Int, Int)
}

class Board {
    
    private var spriteNodes : [[DFTileSpriteNode]]
    private var selectedTiles : [(Int, Int)]
    private var newTiles : [(Int, Int)]
    private var transformation : [Transformation]
    
    private var bottomLeft : (Int, Int) = (0,0)
    private var boardSize: Int = 0
    
    private var tileSize = 75
    
    init(_ tiles: [[DFTileSpriteNode]], size : Int) {
        spriteNodes = tiles
        selectedTiles = []
        newTiles = []
        transformation = []
        boardSize = size
        bottomLeft = (-1 * tileSize/2 * boardSize, -1 * tileSize/2 * boardSize )
    }
    
    func findNeighbors(_ x: Int, _ y: Int){
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
                            if neighbor == tileSpriteNode {
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
        guard neighborRow >= 0 && neighborRow < boardSize && neighborCol >= 0 && neighborCol < spriteNodes[neighborRow].count else {
            return false
        }
        let tileSum = tileRow + tileCol
        let neighborSum = neighborRow + neighborCol
        guard neighbor != DFTileSpriteNode else { return false }
        guard (tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0) else { return false }
        return true
    }
    
    func resetVisited() {
        for (row, col) in selectedTiles {
            spriteNodes[row][col].search = .white
        }
        selectedTiles = []
    }

    
    func reset(size: Int) {
        for row in 0..<size {
            for col in 0..<size {
                spriteNodes[row][col] = DFTileSpriteNode.randomRock()
            }
        }
    }
    
    func removeTiles() {
        for (row, col) in selectedTiles {
            spriteNodes[row][col] = DFTileSpriteNode.init(type: .empty)
        }
        NotificationCenter.default.post(name: .removeTiles, object: nil)
        selectedTiles = []
    }
    
    func shiftDown() {
        transformation = []
        newTiles = []
        for col in 0..<boardSize {
            var shift = 0
            for row in 0..<spriteNodes[col].count {
                switch spriteNodes[row][col].type {
                case .empty:
                    shift += 1
                default:
                    if shift != 0 {
                        let trans = Transformation.init(initial: (row, col), end: (row-shift, col))
                        transformation.append(trans)
                        let intermediateTile = spriteNodes[row][col]
                        spriteNodes[row][col] = spriteNodes[row-shift][col]
                        spriteNodes[row-shift][col] = intermediateTile
                    }
                }
            }
            //create new tiles here as we know the most we can about the columns
            for i in 0..<shift {
                newTiles.append(((spriteNodes[col].count-i-1, col)))
            }
        }
        NotificationCenter.default.post(name: .shiftDown, object: nil, userInfo: ["transformation": transformation])
    }
    
    func fillEmpty() {
        for (row, col) in newTiles {
            spriteNodes[row][col] = DFTileSpriteNode.randomRock()
        }
        NotificationCenter.default.post(name: .newTiles, object: nil, userInfo: ["newTiles": newTiles])
    }
    
}

extension Board {
    
    func removeActions() {
        for i in 0..<boardSize {
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

//MARK: Factory
extension Board {

    class func build(size: Int) -> Board {
        var tiles : [[DFTileSpriteNode]] = []
        for row in 0..<size {
            tiles.append([])
            for _ in 0..<size {
                tiles[row].append(DFTileSpriteNode.randomRock())
            }
        }
        let row = Int.random(size)
        let col = Int.random(size)
        tiles[row][col] = DFTileSpriteNode.init(type: .player)
        return Board.init(tiles, size: size)
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
            let numCols = boardSize - 1
            for colIdx in 0..<boardSize {
                var count = 0
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<boardSize {
                    column.insert(spriteNodes[rowIdx][colIdx], at: 0)
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (colIdx, numCols - count))
                    transformation.append(trans)
                    count += 1
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        case .right:
            let numCols = boardSize - 1
            for colIdx in (0..<boardSize).reversed() {
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<boardSize {
                    column.append(spriteNodes[rowIdx][colIdx])
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


//MARK: Private Getters
extension Board {
    func sprites() -> [[DFTileSpriteNode]] {
        return self.spriteNodes
    }
    
    func getTileSize() -> Int {
        return self.tileSize
    }
    
    func getBottomLeft() -> (Int, Int) {
        return self.bottomLeft
    }
    
    func getSelectedTiles() -> [(Int, Int)] {
        return self.selectedTiles
    }
}
