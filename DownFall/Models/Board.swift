//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import NotificationCenter

struct Transformation {
    let endBoard: Board
    let endTiles: [[TileType]]?
    var tileTransformation: [[TileTransformation]]?
    
    init(board endBoard: Board, tiles endTiles: [[TileType]]? = nil, transformation tileTransformation: [[TileTransformation]]? = nil) {
        self.endBoard = endBoard
        self.endTiles = endTiles
        self.tileTransformation = tileTransformation
    }
}

struct TileTransformation {
    let initial : TileCoord
    let end : TileCoord
    let endTileType: TileType?
    
    init(_ initial: TileCoord, _ end: TileCoord, _ endTileType: TileType? = nil) {
        self.initial = initial
        self.end = end
        self.endTileType = endTileType
    }
}

struct TileCoord: Hashable {
    let x, y: Int
    var tuple : (Int, Int) { return (x, y) }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct Board: Equatable {
    private(set) var tiles: [[TileType]]
    private(set) var playerPosition : TileCoord?
    private(set) var exitPosition : TileCoord?
    private var boardSize: Int { return tiles.count }
    
    
    func handle(input: Input) -> Transformation {
        switch input {
        case .rotateLeft:
            return self.rotate(.left)
        case .rotateRight:
            return self.rotate(.right)
        case .touch(let tileCoord):
            return self.removeAndReplace(row: tileCoord.x, col: tileCoord.y)
        }
    }
    
    init(tiles: [[TileType]],
         playerPosition playerPos: TileCoord?,
         exitPosition exitPos: TileCoord?) {
        self.tiles = tiles
        playerPosition = playerPos ?? getTilePosition(.player)
        exitPosition = exitPos ?? getTilePosition(.exit)
    }
    
    // MARK: - Helpers
    private func getTilePosition(_ type: TileType) -> TileCoord? {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                if tiles[i][j] == type {
                    return TileCoord(i,j)
                }
            }
        }
        return nil
    }
}

// MARK: - Find Neighbors Remove and Replace

extension Board {
    
    /// Return true if a neighbor coord is within the bounds of the board
    /// within one tile in a cardinal direction of the currCoord
    /// and not equal to the currCoord
    func valid(neighbor: TileCoord?, for currCoord: TileCoord?) -> Bool {
        guard let (neighborRow, neighborCol) = neighbor?.tuple,
            let (tileRow, tileCol) = currCoord?.tuple else { return false }
        guard neighborRow >= 0, //lower bound
            neighborCol >= 0, // lower bound
            neighborRow < boardSize, // upper bound
            neighborCol < boardSize, // upper bound
            neighbor != currCoord // not the same coord
            else { return false }
        let tileSum = tileRow + tileCol
        let neighborSum = neighborRow + neighborCol
        guard (tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0) else { return false }
        return true
    }
    
    
    /// Find all contiguous neighbors of the same color as the tile that was tapped
    /// Return a new board with the selectedTiles updated
    
    func findNeighbors(_ x: Int, _ y: Int) -> [TileCoord]? {
        guard x >= 0,
            x < boardSize,
            y >= 0,
            y < boardSize else { return nil }
        var queue = [TileCoord(x, y)]
        var tileCoordSet = Set(queue)
        var head = 0
        
        while head < queue.count {
            let tileRow = queue[head].x
            let tileCol = queue[head].y
            let currTile = tiles[tileRow][tileCol]
            head += 1
            //add neighbors to queue
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    //check that it is within bounds, that we havent visited it before, and it's the same type as us
                    guard valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)),
                        !tileCoordSet.contains(TileCoord(i,j)),
                        tiles[i][j] == currTile else { continue }
                    //valid neighbor within bounds
                    queue.append(TileCoord(i,j))
                    tileCoordSet.insert(TileCoord(i,j))
                }
            }
        }
        return queue
    }
    
    
    /*
     * Remove and refill tiles from the current board
     *
     *  - replaces each tile in the contiguous group of same-colored tiles with an Empty tile type
     *  - iterates through each column starting an at row 0 and ending at row n-1, and increments a shift counter by 1 when it encounters an Empty sprite placeholder
     *  - swaps the current empty tile at index i with the tile at index i+1, thusly all empty tiles end up near at the "top" of each column
     *  - returns a transformation with the tiles that have been removed, added, and shifted down
     */
    
    func removeAndReplace(row x: Int, col y: Int) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        guard let selectedTiles = self.findNeighbors(x, y),
            selectedTiles.count > 2 else {
            return Transformation(board: self, transformation: nil)
        }
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        for coord in selectedTiles {
            intermediateTiles[coord.x][coord.y] = TileType.empty
        }
        
        // keep track of the new player position and exit position after shifting
        // in case the positions don't shift, initiate to the current player and exit position
        var newPlayerPosition: TileCoord? = playerPosition
        var newExitPosition: TileCoord? = exitPosition
        
        var shiftDown : [TileTransformation] = []
        var newTiles : [TileTransformation] = []
        for col in 0..<boardSize {
            var shift = 0
            for row in 0..<boardSize {
                switch intermediateTiles[row][col] {
                case .empty:
                    shift += 1
                default:
                    if shift != 0 {
                        let endRow = row-shift
                        // keep track of player position and exit position so we don't have to later
                        if intermediateTiles[row][col] == .player {
                            newPlayerPosition = TileCoord(endRow, col)
                        } else if intermediateTiles[row][col] == .exit {
                            newExitPosition = TileCoord(endRow, col)
                        }
                        
                        let trans = TileTransformation.init(TileCoord(row, col), TileCoord(endRow, col))
                        shiftDown.append(trans)
                        
                        //update tile storage
                        let intermediateTile = intermediateTiles[row][col]
                        
                        // move the empty tile up
                        intermediateTiles[row][col] = intermediateTiles[row-shift][col]
                        // move the non-empty tile down
                        intermediateTiles[row-shift][col] = intermediateTile
                    }
                }
            }
            
            //create new tiles here as we know the shiftIdx for the columns
            for shiftIdx in 0..<shift {
                let startRow = boardSize + shiftIdx
                let startCol = col
                let endRow = boardSize - shiftIdx - 1
                let endCol = col
                
                //add a random rock to the Tile storage
                let randomType = TileType.randomRock()
                intermediateTiles[endRow][endCol] = randomType
                
                //append to shift dictionary
                var trans = TileTransformation(TileCoord(startRow, startCol),
                                               TileCoord(endRow, endCol))
                shiftDown.append(trans)
                
                //update new tiles
                trans = TileTransformation(TileCoord(startRow, startCol),
                                           TileCoord(endRow, endCol),
                                           randomType)
                newTiles.append(trans)
            }
        } // end column for loop
        let selectedTilesTransformation = selectedTiles.map { TileTransformation($0, $0) }
        return Transformation(board: Board.init(tiles: intermediateTiles,
                                                playerPosition: newPlayerPosition,
                                                exitPosition: newExitPosition),
                              tiles: intermediateTiles,
                              transformation: [selectedTilesTransformation, newTiles, shiftDown])
    }
}

// MARK: - Factory

extension Board {
    static func build(size: Int, playerPosition: TileCoord? = nil, exitPosition: TileCoord? = nil) -> Board {
        var tiles: [[TileType]] = []
        for row in 0..<size {
            tiles.append([])
            for _ in 0..<size {
                tiles[row].append(TileType.randomRock())
            }
        }
        let playerRow: Int
        let playerCol: Int
        if let playerPos = playerPosition {
            playerRow = playerPos.x
            playerCol = playerPos.y
        } else {
            playerRow = Int.random(size)
            playerCol = Int.random(size)
        }
        tiles[playerRow][playerCol] = TileType.player
        
        let exitRow: Int
        let exitCol: Int
        if let exitPos = exitPosition {
            exitRow = exitPos.x
            exitCol = exitPos.y
        } else {
            exitRow = Int.random(size, not: playerRow)
            exitCol = Int.random(size, not: playerCol)
        }
        tiles[exitRow][exitCol] = TileType.exit
        
        return Board.init(tiles: tiles,
                          playerPosition: TileCoord(playerRow, playerCol),
                          exitPosition: TileCoord(exitRow, exitCol))
    }
}

// MARK: - Rotation

extension Board {
    
    enum Direction {
        case left
        case right
    }
    
    func rotate(_ direction: Direction) -> Transformation {
        var transformation: [TileTransformation] = []
        var intermediateTiles: [[TileType]] = []
        
        var newPlayerPosition: TileCoord? = playerPosition
        var newExitPosition: TileCoord? = exitPosition
        let numCols = boardSize - 1
        switch direction {
        case .left:
            for colIdx in 0..<boardSize {
                var column : [TileType] = []
                for rowIdx in 0..<boardSize {
                    let endRow = colIdx
                    let endCol = numCols - rowIdx
                    if tiles[rowIdx][colIdx] == .player {
                        newPlayerPosition = TileCoord(endRow, endCol)
                    } else if tiles[rowIdx][colIdx] == .exit {
                        newExitPosition = TileCoord(endRow, endCol)
                    }
                    column.insert(tiles[rowIdx][colIdx], at: 0)
                    let trans = TileTransformation(TileCoord(rowIdx, colIdx),
                                                   TileCoord(endRow, endCol))
                    transformation.append(trans)
                }
                intermediateTiles.append(column)
            }
        case .right:
            for colIdx in (0..<boardSize).reversed() {
                var column : [TileType] = []
                for rowIdx in 0..<boardSize {
                    let endRow = numCols - colIdx
                    let endCol = rowIdx
                    if tiles[rowIdx][colIdx] == .player {
                        newPlayerPosition = TileCoord(endRow, endCol)
                    } else if tiles[rowIdx][colIdx] == .exit {
                        newExitPosition = TileCoord(endRow, endCol)
                    }
                    column.append(tiles[rowIdx][colIdx])
                    let trans = TileTransformation(TileCoord(rowIdx, colIdx),
                                                   TileCoord(endRow, endCol))
                    transformation.append(trans)
                }
                intermediateTiles.append(column)
            }
        }
        return Transformation(board: Board.init(tiles: intermediateTiles,
                                                playerPosition: newPlayerPosition,
                                                exitPosition: newExitPosition),
                              tiles: intermediateTiles,
                              transformation: [transformation])
    }
}

// MARK: - CustomDebugStringConvertible

extension Board : CustomDebugStringConvertible {
    var debugDescription: String {
        var outs = "\ntop (of Tiles)"
        for (i, _) in tiles.enumerated().reversed() {
            outs += "\n\(tiles[i])"
        }
        outs += "\nbottom"
        return outs
    }
    
}

