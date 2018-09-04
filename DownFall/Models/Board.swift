//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//


import SpriteKit

extension Notification.Name {
    static let neighborsFound = Notification.Name("neighborsFound")
    static let rotated = Notification.Name("rotated")
    static let computeNewBoard = Notification.Name("computeNewBoard")
    static let lessThanThreeNeighborsFound = Notification.Name("lessThanThreeNeighborsFound")
}

struct Transformation {
    let initial : (Int, Int)
    let end : (Int, Int)
}

typealias TileCoord = (Int, Int)

class Board {
    
    private var spriteNodes : [[DFTileSpriteNode]]
    private var selectedTiles : [(Int, Int)]
    private var newTiles : [(Int, Int)]
    
    private var boardSize: Int = 0
    
    private var tileSize = 75
    
    private var playerPosition : TileCoord
    private var exitPosition : TileCoord
    
    init(_ tiles: [[DFTileSpriteNode]], size : Int, playerPosition: TileCoord, exitPosition: TileCoord) {
        spriteNodes = tiles
        selectedTiles = []
        newTiles = []
        boardSize = size
        self.playerPosition = playerPosition
        self.exitPosition = exitPosition
    }
    
    func findNeighbors(_ x: Int, _ y: Int){
        resetVisited()
        var queue : [(Int, Int)] = [(x, y)]
        var head = 0
        
        while head < queue.count {
            let (tileRow, tileCol) = queue[head]
            spriteNodes[tileRow][tileCol].selected = true
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
                                spriteNodes[i][j].selected = true
                                neighbor.search = .gray
                                queue.append((i,j))
                            }
                        }
                    }
                }
            }
        }
        selectedTiles = queue
        if queue.count >= 3 {
            let note = Notification.init(name: .neighborsFound, object: nil, userInfo: ["tiles":selectedTiles])
            NotificationCenter.default.post(note)
        } else {
            //clear selectedTiles so that tiles in groups of 1 or 2 do not think they are selected
            for (row, col) in selectedTiles {
                spriteNodes[row][col].selected = false
            }
            
            //let anyone listening know that we did not find enough neighbors
            let note = Notification.init(name: .lessThanThreeNeighborsFound, object: nil, userInfo: nil)
            NotificationCenter.default.post(note)
            
        }
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
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                spriteNodes[row][col].selected = false
                spriteNodes[row][col].search = .white
            }
        }
        
    }

    func removeAndRefill() {
        let selectedTiles = getSelectedTiles()
        for (row, col) in selectedTiles {
            spriteNodes[row][col] = DFTileSpriteNode.init(type: .empty)
        }

        
        var shiftDown : [Transformation] = []
        var newTiles : [Transformation] = []
        for col in 0..<boardSize {
            var shift = 0
            for row in 0..<boardSize {
                switch spriteNodes[row][col].type {
                case .empty:
                    shift += 1
                default:
                    if shift != 0 {
                        let endRow = row-shift
                        let endCol = col
                        if spriteNodes[row][col].type == .player {
                            playerPosition = (endRow, endCol)
                        } else if spriteNodes[row][col].type == .exit {
                            exitPosition = (endRow, endCol)
                        }
                        let trans = Transformation.init(initial: (row, col), end: (endRow, endCol))
                        shiftDown.append(trans)

                        //update sprite storage
                        let intermediateTile = spriteNodes[row][col]
                        spriteNodes[row][col] = spriteNodes[row-shift][col]
                        spriteNodes[row-shift][col] = intermediateTile
                    }
                }
            }
            
            //create new tiles here as we know the most we can about the columns
            for shiftIdx in 0..<shift {
                let startRow = boardSize + shiftIdx
                let startCol = col
                let endRow = boardSize - shiftIdx - 1
                let endCol = col
                
                //update sprite storage
                //remove empty one
                spriteNodes[endRow][endCol].removeFromParent()
                //add random one
                spriteNodes[endRow][endCol] = DFTileSpriteNode.randomRock()
                
                //append to shift dictionary
                var trans = Transformation.init(initial: (startRow, startCol),
                                                end: (endRow, endCol))
                shiftDown.append(trans)
                
                //update new tiles
                trans = Transformation.init(initial: (startRow, startCol),
                                            end: (endRow, endCol))
                newTiles.append(trans)
            }
        }
        
        //build notification dictionary
        let newBoardDictionary = ["removed": selectedTiles,
                                  "newTiles": newTiles,
                                  "shiftDown": shiftDown] as [String : Any]
        NotificationCenter.default.post(name:.computeNewBoard, object: nil, userInfo: newBoardDictionary)
    }
    
    func getSelectedTiles() -> [TileCoord] {
        var selected : [TileCoord] = []
        for col in 0..<boardSize {
            for row in 0..<boardSize {
                if spriteNodes[row][col].selected {
                    selected.append((row, col))
                }
            }
        }
        return selected
    }
}

extension Board {
    
    func removeActions(_ completion: (()-> Void)? = nil) {
        for i in 0..<boardSize {
            for j in 0..<spriteNodes[i].count {
                spriteNodes[i][j].removeAllActions()
                spriteNodes[i][j].run(SKAction.fadeIn(withDuration: 0.2)) {
                    completion?()
                }
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
        let playerRow = Int.random(size)
        let playerCol = Int.random(size)
        tiles[playerRow][playerCol] = DFTileSpriteNode.init(type: .player)
        
        let exitRow = Int.random(size, not: playerRow)
        let exitCol = Int.random(size, not: playerCol)
        tiles[exitRow][exitCol] = DFTileSpriteNode.init(type: .exit)
        
        return Board.init(tiles,
                          size: size,
                          playerPosition: (playerRow, playerCol),
                          exitPosition: (exitRow, exitCol) )
    }
}

// MARK: Rotation

extension Board {
    enum Direction {
        case left
        case right
    }
    
    func rotate(_ direction: Direction) {
        var transformation : [Transformation] = []
        var intermediateBoard : [[DFTileSpriteNode]] = []
        switch direction {
        case .left:
            let numCols = boardSize - 1
            for colIdx in 0..<boardSize {
                var count = 0
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<boardSize {
                    let endRow = colIdx
                    let endCol = numCols - count
                    if spriteNodes[rowIdx][colIdx].type == .player {
                        playerPosition = (endRow, endCol)
                    } else if spriteNodes[rowIdx][colIdx].type == .exit {
                        exitPosition = (endRow, endCol)
                    }
                    column.insert(spriteNodes[rowIdx][colIdx], at: 0)
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (endRow, endCol))
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
                    let endRow = numCols - colIdx
                    let endCol = rowIdx
                    if spriteNodes[rowIdx][colIdx].type == .player {
                        playerPosition = (endRow, endCol)
                    } else if spriteNodes[rowIdx][colIdx].type == .exit {
                        exitPosition = (endRow, endCol)
                    }
                    column.append(spriteNodes[rowIdx][colIdx])
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (endRow, endCol))
                    transformation.append(trans)
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        }
        NotificationCenter.default.post(name: .rotated, object: nil, userInfo: ["transformation": transformation])
    }

}

//MARK: check for win

extension Board {
    func checkWinCondition() -> Bool {
        let (playerRow, playerCol) = playerPosition
        let (exitRow, exitCol) = exitPosition
        return playerRow == exitRow + 1 && playerCol == exitCol
    }
}


//MARK: Getters for private instance members
extension Board {
    func sprites() -> [[DFTileSpriteNode]] {
        return self.spriteNodes
    }
    
    func getTileSize() -> Int {
        return self.tileSize
    }
    
//    func getSelectedTiles() -> [(Int, Int)] {
//        return self.selectedTiles
//    }
    
    func getExitPosition() -> TileCoord {
        return self.exitPosition
    }
}
