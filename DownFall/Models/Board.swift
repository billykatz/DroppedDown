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
    
    private(set) var tiles: [[Tile]]
    
    private var playerPosition : TileCoord? {
        return getTileStructPosition(.player(.zero))
    }
    var boardSize: Int { return tiles.count }
    var tileCreator: TileCreator
    
    subscript(index: TileCoord) -> TileType? {
        guard isWithinBounds(index) else { return nil }
        return tiles[index.x][index.y].type
        
    }
    
    init(tileCreator: TileCreator,
         tilesStruct: [[Tile]]) {
        self.tileCreator = tileCreator
        self.tiles = tilesStruct
        
        Dispatch.shared.register { [weak self] in self?.handle(input: $0) }
    }
    
    private func isWithinBounds(_ tileCoord: TileCoord) -> Bool {
        let (tileRow, tileCol) = tileCoord.tuple
        return tileRow >= 0 && //lower bound
            tileCol >= 0 && // lower bound
            tileRow < boardSize && // upper bound
            tileCol < boardSize
    }
    
    private func resetShouldHighlight() {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                tiles[i][j] = Tile(type: tiles[i][j].type, shouldHighlight: false)
            }
        }
    }
    
    func handle(input: Input) {
        var transformation: Transformation?
        resetShouldHighlight()
        switch input.type {
        case .rotateLeft:
            transformation = rotate(.left)
        case .rotateRight:
            transformation = rotate(.right)
        case .touchBegan:
            transformation = Transformation(transformation: nil,
                                            inputType: input.type,
                                            endTilesStructs: tiles)
        case .touch(let tileCoord, let type):
            if case TileType.monster = type {
                transformation = indicateAttackPattern(from: tileCoord, inputType: input.type)
            } else {
                transformation = removeAndReplace(tileCoord, input: input)
            }
        case .attack:
            transformation = attack(input)
        case .monsterDies(let tileCoord):
            //only remove a single tile when a monster dies
            transformation = monsterDied(at: tileCoord, input: input)
        case .gameWin:
            transformation = gameWin()
        case .collectItem(let tileCoord, _):
            transformation = collectItem(at: tileCoord, input: input)
        case .reffingFinished(let newTurn):
            transformation = resetAttacks(newTurn: newTurn)
        case .transformation(let trans):
            if let inputType = trans.inputType,
                case .reffingFinished(_) = inputType,
                let tilesSruct = trans.endTilesStructs {
                let input = Input(.newTurn, tilesSruct)
                InputQueue.append(input)
                transformation = nil
            }
        case .gameLose(_),
             .play,
             .pause,
             .animationsFinished,
             .playAgain,
             .boardBuilt,
             .selectLevel,
             .newTurn:
            transformation = nil
        }
        
        guard let trans = transformation else { return }
        InputQueue.append(Input(.transformation(trans)))
    }
    
    func indicateAttackPattern(from coord: TileCoord, inputType: InputType) -> Transformation {
        func attackedTiles(in tiles: [[Tile]], from position: TileCoord) -> [TileCoord] {
            guard isWithinBounds(position) else { return [] }
            let attacker = tiles[position]
            if case TileType.player(let player) = attacker.type  {
                return calculateAttacks(for: player, from: position)
            } else if case TileType.monster(let monster) = attacker.type {
                return calculateAttacks(for: monster, from: position)
            }
            return []
        }
        
        func calculateAttacks(for entity: EntityModel, from position: TileCoord) -> [TileCoord] {
            let attackDirections = entity.attack.directions
            let attackRange = entity.attack.range
            var affectedTiles: [TileCoord] = []
            for direction in attackDirections {
                for i in attackRange.lower...attackRange.upper {
                    // TODO: Let's add a property to attacks that says if the attack goes thru targets or not
                    let target = calculateTarget(in: direction, distance: i, from: position)
                    if isWithinBounds(target) {
                        affectedTiles.append(target)
                    }
                }
            }
            return affectedTiles
        }
        
        func calculateTarget(in direction: Direction, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            let targetRow: Int
            let targetCol: Int
            switch direction {
            case .north:
                targetRow = initialRow + i
                targetCol = initialCol
            case .south:
                targetRow = initialRow - i
                targetCol = initialCol
            case .east:
                targetCol = initialCol + i
                targetRow = initialRow
            case .west:
                targetCol = initialCol - i
                targetRow = initialRow
            case .northEast:
                targetRow = initialRow + i
                targetCol = initialCol + i
            case .southEast:
                targetRow = initialRow - i
                targetCol = initialCol + i
            case .northWest:
                targetRow = initialRow + i
                targetCol = initialCol - i
            case .southWest:
                targetRow = initialRow - i
                targetCol = initialCol - i
            }
            
            return TileCoord(targetRow, targetCol)
        }
        
        var newTiles = tiles
        let affectedTile = attackedTiles(in: tiles, from: coord)
        for coord in affectedTile {
            newTiles[coord.x][coord.y].shouldHighlight = true
        }
        tiles = newTiles
        
        return Transformation(transformation: .none,
                              inputType: inputType,
                              endTilesStructs: tiles)
    }
    
    
    // MARK: - Helpers
    private func getTileStructPosition(_ type: TileType) -> TileCoord? {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                if tiles[i][j].type == type {
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
    
    func findNeighbors(_ coord: TileCoord) -> [TileCoord] {
        let (x,y) = coord.tuple
        guard
            x >= 0,
            x < boardSize,
            y >= 0,
            y < boardSize else { return [] }
        
        if case TileType.monster(_) = tiles[x][y].type { return [] }
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
                        tiles[i][j].type == currTile.type,
                        tiles[i][j].type.isARock()
                        else { continue }
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
    
    func removeAndReplace(_ tileCoord: TileCoord,
                          singleTile: Bool = false,
                          input: Input) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        var selectedTiles: [TileCoord] = [tileCoord]
        if !singleTile {
            selectedTiles = findNeighbors(tileCoord)
            if selectedTiles.count < 3 {
                return Transformation(transformation: nil,
                                      inputType: input.type,
                                      endTilesStructs: tiles)
            }
        }
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        for coord in selectedTiles {
            intermediateTiles[coord.x][coord.y] = Tile.empty
        }
        
        // store tile transforamtions and shift information
        var newTiles : [TileTransformation] = []
        var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
        
        //add new tiles
        addNewTiles(shiftIndices: shiftIndices,
                    shiftDown: &shiftDown,
                    newTiles: &newTiles,
                    intermediateTiles: &intermediateTiles)
        
        //create selectedTilesTransformation array
        let selectedTilesTransformation = selectedTiles.map { TileTransformation($0, $0) }
        
        //update our store of tilesftiles
        self.tiles = intermediateTiles
        
        // return our new board
        return Transformation(transformation: [selectedTilesTransformation,
                                               newTiles,
                                               shiftDown],
                              inputType: input.type,
                              endTilesStructs: intermediateTiles
        )
    }
    
    private func resetAttacks(newTurn: Bool) -> Transformation? {
        func resetAttacks(in tiles: [[Tile]]) -> [[Tile]] {
            var newTiles = tiles
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if case .monster(let data) = tiles[i][j].type {
                        newTiles[i][j] = Tile(type: .monster(data.resetAttacks().incrementsAttackTurns()))
                    }
                    
                    if case .player(let data) = tiles[i][j].type {
                        newTiles[i][j] = Tile(type: .player(data.resetAttacks()))
                    }
                }
            }
            return newTiles
        }
        
        tiles = resetAttacks(in: tiles)
        
        return Transformation(transformation: nil,
                              inputType: .reffingFinished(newTurn: newTurn),
                              endTilesStructs: tiles
        )
        
        
    }
    
    private func collectItem(at coord: TileCoord, input: Input) -> Transformation {
        let selectedTile = tiles[coord]
        
        //remove and replace the single item tile
        let transformation = removeAndReplace(coord, singleTile: true, input: input)
        
        //save the item
        guard case let TileType.item(item) = selectedTile.type,
            var updatedTiles = transformation.endTilesStructs else { return Transformation.zero }
        
        if let pp = playerPosition,
            case let .player(data) = updatedTiles[pp].type {
            
            var items = data.carry.items
            items.append(item)
            let newCarryModel = CarryModel(items: items)
            let playerData = EntityModel(originalHp: data.originalHp,
                                         hp: data.hp,
                                         name: data.name,
                                         // Orend
                // we have to reset attack here because the player has moved but the turn may not be over
                // Eg: it is possible that there could be two or more monsters
                // under the player and the player should be able to attack
                attack: data.attack.resetAttack(),
                type: data.type,
                carry: newCarryModel,
                animations: data.animations,
                abilities: data.abilities)
            
            updatedTiles[pp.x][pp.y] = Tile(type: .player(playerData))
        }
        
//        tiles = tileEnums(from: updatedTiles)
        tiles = updatedTiles
        
        return Transformation(transformation: transformation.tileTransformation,
                              inputType: .collectItem(coord, item),
                              endTilesStructs: updatedTiles)
    }
    
    
    private func monsterDied(at coord: TileCoord, input: Input) -> Transformation {
        if case let .monster(monsterData) = tiles[coord].type,
            let item = monsterData.carry.items.first {
            let itemTile = TileType.item(item)
            tiles[coord.x][coord.y] = Tile(type: itemTile)
            return Transformation(transformation: nil,
                                  inputType: .monsterDies(coord),
                                  endTilesStructs: tiles)
        } else {
            //no item! remove and replace
            return removeAndReplace(coord, singleTile: true, input: input)
        }
        
    }
    
    private func addNewTiles(shiftIndices: [Int],
                             shiftDown: inout [TileTransformation],
                             newTiles: inout [TileTransformation],
                             intermediateTiles: inout [[Tile]]) {
        // Intermediate tiles is the "in-between" board that has shifted down
        // tiles into and replaced the shifted down tiles with empty tiles
        // the tile creator replaces empty tiles with new tiles
        var newTileTypes = tileCreator.tiles(for: intermediateTiles)
        guard newTileTypes.count == shiftIndices.reduce(0, +) else { assertionFailure("newTileTypes count must match the number of empty tiles in the board"); return }
        
        for (col, shifts) in shiftIndices.enumerated() where shifts > 0 {
            for startIdx in 0..<shifts {
                let startRow = boardSize + startIdx
                let startCol = col
                let endRow = startRow - shifts
                let endCol = col
                
                //Add the first tile from TileCreator and remove it from the array
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
    }
    
    private func calculateShiftIndices(for tiles: inout [[Tile]]) -> ([TileTransformation], [Int]) {
        var shiftIndices = Array(repeating: 0, count: tiles.count)
        var shiftDown: [TileTransformation] = []
        for col in 0..<tiles.count {
            var shift = 0
            for row in 0..<tiles.count {
                switch tiles[row][col].type {
                case .empty:
                    shift += 1
                default:
                    if shift != 0 {
                        let endRow = row-shift
                        let trans = TileTransformation(TileCoord(row, col), TileCoord(endRow, col))
                        shiftDown.append(trans)
                        
                        //update tile storage
                        let intermediateTile = tiles[row][col]
                        
                        // move the empty tile up
                        tiles[row][col] = tiles[row-shift][col]
                        // move the non-empty tile down
                        tiles[row-shift][col] = intermediateTile
                    }
                }
            }
            shiftIndices[col] = shift
        }
        return (shiftDown, shiftIndices)
    }
    
}

// MARK: - Factory

extension Board {
    static func build(size: Int,
                      tileCreator: TileCreator,
                      difficulty: Difficulty = .normal) -> Board {
        
        //create a boardful of tiles
        let tilesStruct: [[Tile]] = tileCreator.board(size, difficulty: difficulty)
        
        //let the world know we built the board
        InputQueue.append(Input(.boardBuilt, tilesStruct))
        
        //init new board
        return Board(tileCreator: tileCreator, tilesStruct: tilesStruct)
    }
}

// MARK: - Rotation

extension Board {
    
    enum RotationalDirection {
        case left
        case right
    }
    
    func rotate(_ direction: RotationalDirection) -> Transformation {
        var transformation: [TileTransformation] = []
        var intermediateTiles: [[Tile]] = []
        let numCols = boardSize - 1
        let inputType: InputType
        switch direction {
        case .left:
            for colIdx in 0..<boardSize {
                var column : [Tile] = []
                for rowIdx in 0..<boardSize {
                    let endRow = colIdx
                    let endCol = numCols - rowIdx
                    
                    column.insert(tiles[rowIdx][colIdx], at: 0)
                    
                    //Create a TileTransformation object, the Renderer will use this to animate the changes
                    let trans = TileTransformation(TileCoord(rowIdx, colIdx),
                                                   TileCoord(endRow, endCol))
                    transformation.append(trans)
                }
                intermediateTiles.append(column)
            }
            inputType = .rotateLeft
        case .right:
            for colIdx in (0..<boardSize).reversed() {
                var column : [Tile] = []
                for rowIdx in 0..<boardSize {
                    let endRow = numCols - colIdx
                    let endCol = rowIdx
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
        
        return Transformation(transformation: [transformation],
                              inputType: inputType,
                              endTilesStructs: tiles)
    }
}

// MARK: - CustomDebugStringConvertible

extension Board : CustomDebugStringConvertible {
    var debugDescription: String {
        var outs = "\ntop (of Tiles)"
        for tile in tiles.reversed() {
            outs += "\n\(tile)"
        }
        outs += "\nbottom"
        return outs
    }
    
}


extension Board {
    func gameWin() -> Transformation {
        guard let playerPosition = getTileStructPosition(TileType.player(.zero)),
            isWithinBounds(playerPosition.rowBelow) else { return Transformation.zero  }
        return Transformation(transformation: [[TileTransformation(playerPosition, playerPosition.rowBelow)]], inputType: .gameWin)
    }
}

// MARK - Tile counts

extension Board {
    func tiles(of type: TileType) -> [TileCoord] {
        var tileCoords: [TileCoord] = []
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                tiles[i][j].type == type ? tileCoords.append(TileCoord(i, j)) : ()
            }
        }
        return tileCoords
    }
}

extension Array where Element: Collection, Element.Index == Int {
    subscript(tileCoord: TileCoord) -> Element.Iterator.Element {
        return self[tileCoord.x][tileCoord.y]
    }
}


// MARK: - Combat
extension Board {
    
    func attack(_ input: Input) -> Transformation {
        guard case InputType.attack(_,
                                    let attackerPosition,
                                    let defenderPostion,
                                    _) = input.type else {
                                        return Transformation.zero
        }
        var attacker: EntityModel
        var defender: EntityModel
        
        
        //TODO: DRY, extract and shorten this code
        if let defenderPosition = defenderPostion,
            case let .player(playerModel) = tiles[attackerPosition].type,
            case let .monster(monsterModel) = tiles[defenderPosition].type,
            let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = playerModel
            defender = monsterModel
            
            let (newAttackerData, newDefenderData) = CombatSimulator.simulate(attacker: attacker,
                                                                              defender: defender,
                                                                              attacked: relativeAttackDirection)
            
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.player(newAttackerData))
            tiles[defenderPosition.x][defenderPosition.y] = Tile(type: TileType.monster(newDefenderData))
            
        } else if let defenderPosition = defenderPostion,
            case let .player(playerModel) = tiles[defenderPosition].type,
            case let .monster(monsterModel) = tiles[attackerPosition].type,
            let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = monsterModel
            defender = playerModel
            
            let (newAttackerData, newDefenderData) = CombatSimulator.simulate(attacker: attacker,
                                                                              defender: defender,
                                                                              attacked: relativeAttackDirection)
            
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(newAttackerData))
            tiles[defenderPosition.x][defenderPosition.y] = Tile(type: TileType.player(newDefenderData))
        } else if case let .player(playerModel) = tiles[attackerPosition].type,
            defenderPostion == nil {
            //just note that the player attacked
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.player(playerModel.didAttack()))
            
        } else if case let .monster(monsterModel) = tiles[attackerPosition].type,
            defenderPostion == nil {
            //just note that the monster attacked
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(monsterModel.didAttack()))
        }
        
        
        return Transformation(inputType: input.type,
                              endTilesStructs: tiles)
    }
}
