//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

class Board: Equatable {
    static func == (lhs: Board, rhs: Board) -> Bool {
        return false
    }
    
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
    
    func handle(input: Input) {
        let transformation: Transformation?
        switch input.type {
        case .rotateLeft:
            transformation = self.rotate(.left)
        case .rotateRight:
            transformation = self.rotate(.right)
        case .touch(let tileCoord, _):
            transformation = self.removeAndReplace(tileCoord)
        case .attack(let attacker, let defender):
            transformation = self.attack(attacker, defender)
        case .monsterDies(let tileCoord):
            //only remove a single tile when a monster dies
            transformation = self.removeAndReplace(tileCoord, singleTile: true)
        case .gameWin:
            transformation = gameWin()
        case .collectGem(let tileCoord):
            transformation = self.removeAndReplace(tileCoord, singleTile: true, collectedGem: true)
        @unknown default:
            // We dont care about these inputs, intentionally do nothing
            transformation = nil
        }
        
        guard let trans = transformation else { return }
        InputQueue.append(Input(.transformation(trans)))
    }
    
    init(tiles: [[TileType]],
         playerPosition playerPos: TileCoord? = nil,
         exitPosition exitPos: TileCoord? = nil) {
        self.tiles = tiles
        playerPosition = playerPos ?? getTilePosition(TileType.player())
        exitPosition = exitPos ?? getTilePosition(.exit)
        
        Dispatch.shared.register { [weak self] in self?.handle(input: $0) }
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

extension Board {
    func resetPlayerAttacks() {
        guard let playerPosition = playerPosition else { return }
        if case .player(let data) = tiles[playerPosition] {
            tiles[playerPosition.x][playerPosition.y] = .player(data.resetAttacksThisTurn())
        }
    }
    
    func resetMonsterAttacks() {
        for (i, row) in tiles.enumerated() {
            for (j, _) in row.enumerated() {
                if case .greenMonster(let data) = tiles[i][j] {
                    tiles[i][j] = .greenMonster(data.resetAttacksThisTurn())
                }
            }

        }
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
        guard difference <= 1 //tiles are within one of eachother
                && ((tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0)) // they are not diagonally touching
            else { return false }
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
        
        if case TileType.greenMonster(_) = tiles[x][y] { return [] }
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
    
    func removeAndReplace(_ tileCoord: TileCoord, singleTile: Bool = false, collectedGem: Bool = false) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        let (row, col) = tileCoord.tuple
        var selectedTiles: [TileCoord] = [tileCoord]
        if !singleTile {
            selectedTiles = self.findNeighbors(row, col)
            if selectedTiles.count < 3 { return Transformation.zero }
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
        
        // Intermediate tiles is the "in-between" board that has shifted down
        // tiles into and replaced the shifted down tiles with empty tiles
        // the tile creator replaces empty tiles with new tiles
        var newTileTypes = TileCreator.tiles(for: Board(tiles: intermediateTiles))
        guard newTileTypes.count == shiftIndices.reduce(0, +) else { assertionFailure("newTileTypes count must match the number of empty tiles in the board"); return Transformation.zero }
        
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
                                           TileCoord(endRow, endCol))
                newTiles.append(trans)
            }
        }
        let selectedTilesTransformation = selectedTiles.map { TileTransformation($0, $0) }

        self.tiles = intermediateTiles
        self.playerPosition = newPlayerPosition
        self.exitPosition = newExitPosition
        if collectedGem,
            let pp = playerPosition,
            case let TileType.player(data) = tiles[pp] {
            tiles[pp.x][pp.y] = TileType.player(data.collectsGem())
        }
        self.resetPlayerAttacks()
        self.resetMonsterAttacks()
        return Transformation(tiles: tiles,
                              transformation: [selectedTilesTransformation, newTiles, shiftDown],
                              inputType: .touch(tileCoord, tiles[tileCoord]))
    }
    
}

// MARK: - Factory

extension Board {
    static func build(size: Int,
                      playerPosition: TileCoord? = nil,
                      exitPosition: TileCoord? = nil,
                      difficulty: Difficulty = .normal) -> Board {
        let tiles = TileCreator.board(size, difficulty: difficulty)
        InputQueue.append(Input(.boardBuilt, tiles))
        return Board.init(tiles: tiles)
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
        let inputType: InputType
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
            inputType = .rotateLeft
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
            inputType = .rotateRight
        }
        self.tiles = intermediateTiles
        self.playerPosition = newPlayerPosition
        self.exitPosition = newExitPosition
        self.resetPlayerAttacks()
        self.resetMonsterAttacks()
        return Transformation(tiles: tiles,
                              transformation: [transformation],
                              inputType: inputType)
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
            let exitPosition = self.exitPosition else { return Transformation.zero  }
        return Transformation(transformation: [[TileTransformation(playerPosition, exitPosition)]], inputType: .gameWin)
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

extension Array where Element : Collection, Element.Index == Int {
    subscript(tileCoord: TileCoord) -> Element.Iterator.Element {
        return self[tileCoord.x][tileCoord.y]
    }
}


// MARK: - Combat
extension Board {
    
    func attack(_ attackerPosition: TileCoord, _ defenderPosition: TileCoord) -> Transformation {
        // Right now players only attack down, guard that we dont go out of bounds
        //retrieve the player and target types
        let attacker = tiles[attackerPosition]
        let defender =  tiles[defenderPosition]
        
        //unwrap CombatTileData associated with tiles
        if let attackerData = attacker.combatData,
            let defenderData = defender.combatData {
            
            let (newAttackerData, newDefenderData) = CombatSimulator.simulate(attacker: attackerData,
                                                                              defender: defenderData)
            tiles[attackerPosition.x][attackerPosition.y] = attacker.updateCombat(newAttackerData)
            tiles[defenderPosition.x][defenderPosition.y] = defender.updateCombat(newDefenderData)
            
        } else {
            fatalError("Failed to unwrap combat data associated with tiles")
        }
        return Transformation(tiles: tiles, inputType: .attack(attackerPosition, defenderPosition))
    }
}
