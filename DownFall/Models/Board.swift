//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct Board: Equatable {
    private(set) var tiles: [[TileType]]
    private(set) var playerPosition : TileCoord?
    private(set) var exitPosition : TileCoord?
    var boardSize: Int { return tiles.count }
    
    subscript(index: TileCoord) -> TileType? {
        guard isWithinBounds(index) else { return nil }
        return tiles[index.x][index.y]
        
    }
    
    func isWithinBounds(_ tileCoord: TileCoord) -> Bool {
        let (tileRow, tileCol) = tileCoord.tuple
        return tileRow >= 0 && //lower bound
            tileCol >= 0 && // lower bound
            tileRow < boardSize && // upper bound
            tileCol < boardSize
    }
    
    func handle(input: Input) -> Transformation? {
        switch input.type {
        case .rotateLeft:
            return self.rotate(.left)
        case .rotateRight:
            return self.rotate(.right)
        case .touch(let tileCoord):
            return self.removeAndReplace(tileCoord)
        case .playerAttack:
            return self.playerAttack()
        case .monsterAttack(_):
            return Transformation(board: self)
        case .monsterDies(let tileCoord):
            //only remove a single tile when a monster dies
            return self.removeAndReplace(tileCoord, singleTile: true)
        case .gameWin:
            return gameWin()
        case .gameLose, .play, .pause:
            return Transformation(board: self)
        case .animationsFinished:
            return nil
        }
    }
    
    init(tiles: [[TileType]],
         playerPosition playerPos: TileCoord? = nil,
         exitPosition exitPos: TileCoord? = nil) {
        self.tiles = tiles
        playerPosition = playerPos ?? getTilePosition(TileType.player())
        exitPosition = exitPos ?? getTilePosition(.exit)
    }
    
    // MARK: - Helpers
    func getTilePosition(_ type: TileType) -> TileCoord? {
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
        let difference = abs(neighborSum - tileSum)
        guard difference <= 1 && ((tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0)) else { return false }
        return true
    }
    
    func validCardinalNeighbors(of coord: TileCoord) -> [TileCoord] {
        var neighbors : [TileCoord] = []
        let (tileRow, tileCol) = coord.tuple
        for i in tileRow-1...tileRow+1 {
            for j in tileCol-1...tileCol+1 {
                //check that it is within bounds
                if valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)) {
                    neighbors.append(TileCoord(i, j))
                }
            }
        }
        return neighbors
    }
    
    
    /// Find all contiguous neighbors of the same color as the tile that was tapped
    /// Return a new board with the selectedTiles updated
    
    func findNeighbors(_ x: Int, _ y: Int) -> [TileCoord] {
        guard x >= 0,
            x < boardSize,
            y >= 0,
            y < boardSize else { return [] }
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
    
    func removeAndReplace(_ tileCoord: TileCoord, singleTile: Bool = false) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        let (row, col) = tileCoord.tuple
        var selectedTiles: [TileCoord] = [tileCoord]
        if !singleTile {
            selectedTiles = self.findNeighbors(row, col)
            if selectedTiles.count < 3 { return Transformation(board: self, transformation: nil) }
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
        var shiftIndices = Array(repeating: 0, count: tiles.count)
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
                        if intermediateTiles[row][col] == TileType.player() {
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
            shiftIndices[col] = shift
        }
        
        // get new tiles from the Creator
        var newTileTypes = TileCreator.tiles(for: Board.init(tiles: intermediateTiles))
        guard newTileTypes.count == shiftIndices.reduce(0, +) else { assertionFailure("newTileTypes count must match the number of empty tiles in the board"); return Transformation.init(board: self) }
        
        //add new tiles here as we know shiftIdx for the columns
        for (col, shifts) in shiftIndices.enumerated() where shifts > 0 {
            for startIdx in 0..<shifts {
                let startRow = boardSize + startIdx
                let startCol = col
                let endRow = startRow - shifts
                let endCol = col
                
                //Add the first tile from TileCreator and remove it from the array
                let randomType = TileType.randomRock()
                intermediateTiles[endRow][endCol] = newTileTypes.removeFirst()
                
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
        }
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
    static func build(size: Int,
                      playerPosition: TileCoord? = nil,
                      exitPosition: TileCoord? = nil,
                      difficulty: Difficulty? = .normal) -> Board {
        
        
        /// Considerations:
        /// - not too many monsters, but at least 1?
        /// - can a monster start next to a player?
        /// - should this be in Board?
        ///
        /// Board should know what tiles it has.
        /// Board should know how to rotate the tiles
        /// Board should know how to remove and replace tiles
        /// Game should know if the player has won or lost
        /// Game should know if what difficulty the game is
        /// Game should know how to place a Tile in the Scene
        ///
        /// Who knows tile specific data? Player's health/attack? The monster's health/attack? Exit is lock or unlocked?
        /// Who knows how tiles interact with each other? eg. Player/Monster attack triggered.  Player can obtain key/artifact.
        /// Who knows what tile to create? Monsters/Rocks/Artifcats/Power-ups etc...
        ///
        
        
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
        tiles[playerRow][playerCol] = TileType.player(CombatTileData.player())
        
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
                    if tiles[rowIdx][colIdx] == TileType.player() {
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
                    if tiles[rowIdx][colIdx] == TileType.player() {
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


extension Board {
    func gameWin() -> Transformation {
        guard let playerPosition = self.playerPosition,
            let exitPosition = self.exitPosition else { return Transformation(board: self)  }
        return Transformation(board: self, transformation: [[TileTransformation(playerPosition, exitPosition)]])
    }
}

// MARK - Tile counts

extension Board {
    func tiles(of type: TileType) -> [TileCoord] {
        var tileCoords: [TileCoord] = []
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                tiles[i][j] == type ? tileCoords.append(TileCoord(i, j)) : ()
            }
        }
        return tileCoords
    }
    
}

// MARK: - Combat
extension Board {
    func playerAttack() -> Transformation {
        // Right now players only attack down, guard that we dont go out of bounds
        guard  let playerCol = playerPosition?.y,
                let playerRow = playerPosition?.x,
                playerPosition?.x ?? 0 - 1 >= 1 else { return Transformation(board: self) }
        var currBoard = self.tiles
        let player = currBoard[playerRow][playerCol]
        let targetRow = playerRow - 1
        let target =  currBoard[targetRow][playerCol]
        if case TileType.greenMonster(let monsterData) = target,
            case TileType.player(let playerData) = player {
            let data = CombatTileData(hp: monsterData.hp - playerData.attackDamage, attackDamage: monsterData.attackDamage)
            currBoard[targetRow][playerCol] = TileType.greenMonster(data)
        }

        return Transformation(board: Board.init(tiles: currBoard,
                                                playerPosition: self.playerPosition,
                                                exitPosition: self.exitPosition),
                              tiles: currBoard)
    }
    
    
    func monsterAttack(_ tileCoord: TileCoord) -> Transformation {
        let (monsterRow, monsterCol) = tileCoord.tuple
        guard monsterRow  >= 1 else { return Transformation(board: self) }
        var currBoard = self.tiles
        let player = currBoard[monsterRow-1][monsterCol]
        if case TileType.greenMonster(let monsterData) = currBoard[monsterRow][monsterCol],
            case TileType.player(let playerData) = player {
            let data = CombatTileData(hp: playerData.hp - monsterData.attackDamage, attackDamage: playerData.attackDamage)
            currBoard[monsterRow-1][monsterCol] = TileType.player(data)
        }
        
        return Transformation(board: Board.init(tiles: currBoard,
                                                playerPosition: self.playerPosition,
                                                exitPosition: self.exitPosition),
                              tiles: currBoard,
                              transformation: nil)
    }
}
