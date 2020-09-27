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
    private let level: Level
    var tileCreator: TileStrategy
    
    private var playerPosition : TileCoord? {
        return getTileStructPosition(.player(.zero))
    }
    
    var boardSize: Int { return tiles.count }
    
    
    subscript(index: TileCoord) -> TileType? {
        guard isWithinBounds(index) else { return nil }
        return tiles[index.x][index.y].type
        
    }
    
    init(tileCreator: TileStrategy,
         tiles: [[Tile]],
         level: Level) {
        self.tileCreator = tileCreator
        self.tiles = tiles
        self.level = level
        
        Dispatch.shared.register { [weak self] in self?.handle(input: $0) }
    }
    
    private func isWithinBounds(_ tileCoord: TileCoord) -> Bool {
        let (tileRow, tileCol) = tileCoord.tuple
        return tileRow >= 0 && //lower bound
            tileCol >= 0 && // lower bound
            tileRow < boardSize && // upper bound
            tileCol < boardSize
    }
    
    
    func handle(input: Input) {
        var transformation: Transformation?
        switch input.type {
        case .rotateCounterClockwise(let preview):
            InputQueue.append(Input(.transformation(rotate(.counterClockwise, preview: preview))))
            return
        case .rotateClockwise(let preview):
            InputQueue.append(Input(.transformation(rotate(.clockwise, preview: preview))))
            return
        case .touchBegan:
            transformation = Transformation(transformation: nil,
                                            inputType: input.type,
                                            endTiles: tiles)
        case .touch(let tileCoord, let type):
            switch type {
            case .monster(let data):
                let attacks = calculateAttacks(for: data, from: tileCoord)
                InputQueue.append(Input(.tileDetail(type, attacks)))
                return
            case .pillar, .item:
                InputQueue.append(Input(.tileDetail(type, [])))
                return
            default:
                transformation = removeAndReplace(from: tiles, tileCoord: tileCoord, input: input)
                
            }
        case .attack:
            transformation = attack(input)
        case .monsterDies(let tileCoord, _):
            //only remove a single tile when a monster dies
            transformation = monsterDied(at: tileCoord, input: input)
        case .gameWin:
            transformation = gameWin()
        case .collectItem(let tileCoord, _, _):
            transformation = collectItem(at: tileCoord, input: input)
        case .reffingFinished(let newTurn):
            transformation = resetAttacks(newTurn: newTurn)
        case .transformation(let trans):
            if let inputType = trans.first?.inputType,
                case .reffingFinished(_) = inputType,
                let tilesSruct = trans.first?.endTiles {
                let input = Input(.newTurn, tilesSruct)
                InputQueue.append(input)
                transformation = nil
            }
        case .itemUseSelected(let ability):
            InputQueue.append(
                Input(
                    InputType.transformation(
                        [Transformation(transformation: nil, inputType: .itemUseSelected(ability), endTiles: self.tiles)]
                    )
                )
            )
            
        case .itemUsed(let rune, let targets):
            let trans = useRune(rune, on: targets, input: input)
            
            InputQueue.append(
                Input(
                    InputType.transformation(
                        [trans]
                    )
                )
            )
        case .decrementDynamites(let dynamiteCoords):
            let trans = decrementDynamites(input: input, dynamiteCoords: dynamiteCoords)
            InputQueue.append(Input(.transformation(trans)))
        case .rotatePreviewFinish:
            let transformation = rotatePreviewFinish(input: input)
            InputQueue.append(Input(.transformation(transformation)))
        case .refillEmpty:
            InputQueue.append(Input(.transformation([refillEmpty(inputType: .refillEmpty)])))
        case .shuffleBoard:
            InputQueue.append(Input(.transformation([shuffleBoard(inputType: .shuffleBoard)])))
        case .unlockExit:
            InputQueue.append(Input(.transformation([unlockExit(inputType: input.type)])))
        case .runeProgressRecord(let runeProgress):
            guard let pp = playerPosition,
                case let .player(data) = tiles[pp].type else { return }
            tiles[pp.row][pp.column] = Tile(type: .player(data.recordRuneProgress(runeProgress)))
            transformation = playerDataUpdated(inputType: input.type)
        case .gameLose(_),
             .play,
             .pause,
             .animationsFinished,
             .playAgain,
             .boardBuilt,
             .selectLevel,
             .newTurn,
             .visitStore,
             .itemUseCanceled, .itemCanBeUsed, .rotatePreview, .tileDetail, .levelGoalDetail, .goalProgressRecord:
            transformation = nil
        }
        
        guard let trans = transformation else { return }
        InputQueue.append(Input(.transformation([trans])))
    }
    
    private func playerDataUpdated(inputType: InputType) -> Transformation {
        return Transformation(transformation: nil, inputType: inputType, endTiles: tiles)
    }
        
    private func unlockExit(inputType: InputType) -> Transformation {
        var newTiles = tiles
        
        if let exitCoord = typeCount(for: tiles, of: .exit(blocked: true)).first {
            newTiles[exitCoord.row][exitCoord.column] = Tile(type: .exit(blocked: false))
        }
        
        self.tiles = newTiles
        
        return Transformation(transformation: nil, inputType: inputType, endTiles: newTiles)
    }
    
    private func rotatePreviewFinish(input: Input) -> [Transformation] {
        
        // if we do not have a trans, then we are not rotating, creating an empty Transformation
        guard case InputType.rotatePreviewFinish(let spriteAction, let trans) = input.type,
            let tiles = trans?.endTiles else {
                let transformation = Transformation(transformation: nil, inputType: input.type, endTiles: self.tiles)
                return [transformation]
        }
        /// if we have a trans, that is because we are actually rotating
        self.tiles = tiles
        var allTransformations = [Transformation(transformation: nil, inputType: .rotatePreviewFinish(spriteAction, trans), endTiles: tiles)]
        
        if typeCount(for: self.tiles, of: .empty).count > 0 {
            // store tile transforamtions and shift information
            var newTiles : [TileTransformation] = []
            var intermediateTiles = self.tiles
            var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
            
            //add new tiles
            addNewTiles(shiftIndices: shiftIndices,
                        shiftDown: &shiftDown,
                        newTiles: &newTiles,
                        intermediateTiles: &intermediateTiles)
            
            // return our new board
            
            allTransformations.append(Transformation(transformation: [newTiles, shiftDown],
                                                     inputType: input.type,
                                                     endTiles: intermediateTiles))
        }
        
        return allTransformations
    }
    
    private func decrementDynamites(input: Input, dynamiteCoords: Set<TileCoord>) -> [Transformation] {
        
        var removedRocksAndPillars: [TileCoord] = []
        for coord in dynamiteCoords {
            if case let TileType.dynamite(data) = tiles[coord].type {
                let newFuse = data.count - 1
                
                if newFuse <= 0 {
                    /// EXPLODE
                    tiles[coord.row][coord.column] = Tile(type: .empty)
                    
                    let affectedNeighbors = coord.allNeighbors
                    for neighborCoord in affectedNeighbors {
                        guard isWithinBounds(neighborCoord) else { continue }
                        switch tiles[neighborCoord].type {
                        case .dynamite:
                            tiles[neighborCoord.row][neighborCoord.column] = Tile(type: .dynamite(DynamiteFuse(count: 3, hasBeenDecremented: false)))
                        case .player(let playerData):
                            tiles[neighborCoord.row][neighborCoord.column] = Tile(type: .player(playerData.wasAttacked(for: 1, from: neighborCoord.direction(relative: coord) ?? .east)))
                        case .rock, .pillar:
                            removedRocksAndPillars.append(neighborCoord)
                        case .empty, .exit, .monster, .gem, .gold, .emptyGem:
                            () // purposefully left blank
                        case .item:
                            ()
                        }
                    }
                } else {
                    tiles[coord.row][coord.column] = Tile(type: .dynamite(DynamiteFuse(count: newFuse, hasBeenDecremented: true)))
                }
            }
            
        }
        let removedAndReplaced = removeAndReplaces(from: tiles, specificCoord: removedRocksAndPillars, input: input)
        
        return [Transformation(transformation: nil, inputType: input.type, endTiles: tiles), removedAndReplaced]
    }
    
    
    func calculateAttacks(for entity: EntityModel, from position: TileCoord) -> [TileCoord] {
        return entity.attack.targets(from: position).compactMap { target in
            if isWithinBounds(target) {
                return target
            }
            return nil
        }
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
    
    private func transform(_ coords: [TileCoord], into type: TileType, input: Input) -> Transformation {
        
        var tileTransform : [TileTransformation] = []
        for tile in coords {
            tiles[tile.row][tile.column] = Tile(type: type)
            tileTransform.append(TileTransformation(tile, tile))
        }
        
        return Transformation(transformation: [tileTransform], inputType: input.type, endTiles: tiles)
        
    }
    
    
    private func swap(_ first: TileCoord, with second: TileCoord, input: Input) -> Transformation {
        
        let tempTile = tiles[first]
        tiles[first.row][first.column] = tiles[second.row][second.column]
        tiles[second.row][second.column] = tempTile
        let tileTransformation = [TileTransformation(first, second), TileTransformation(second, first)]
        return Transformation(transformation: [tileTransformation], inputType: input.type, endTiles: tiles)
        
    }
    
    private func bubbleUp(_ first: TileCoord, input: Input) -> Transformation {
        let tilesAbove = tiles.count - first.row - 1
        let tileCoords = (0..<tilesAbove).reduce([first], { prevArray, offset in
            var array = prevArray
            if let last = array.last {
                array.append(last.rowAbove)
            }
            return array
        })
        
        guard tileCoords.count > 1, let first = tileCoords.first, let last = tileCoords.last else {
            return .zero
        }
        
        var newTiles = self.tiles
        var transformation = [TileTransformation(first, last)]
        let playerTile = newTiles[first]
        
        /// Skip the first index because we primed that loop
        for coordIndex in 1..<tileCoords.count {
            transformation.append(TileTransformation(tileCoords[coordIndex], tileCoords[coordIndex-1]))
            
            let currentCoord = tileCoords[coordIndex]
            let targetCoord = tileCoords[coordIndex-1]
            newTiles[targetCoord.row][targetCoord.column] = tiles[currentCoord]
            
            /// for the last coord, set the tile to be the player
            if coordIndex == tileCoords.count - 1 {
                newTiles[currentCoord.row][currentCoord.column] = playerTile
            }
        }
        
        self.tiles = newTiles
        return Transformation(transformation: [transformation], inputType: input.type, endTiles: newTiles)
    }
    
    private func transmogrify(_ target: TileCoord, input: Input) -> Transformation {
        if case let TileType.monster(data) = tiles[target].type {
            let newMonster = tileCreator.randomMonster(not: data.type)
            tiles[target.row][target.column] = newMonster
            return Transformation(transformation: nil, inputType: input.type, endTiles: tiles)
        } else {
            preconditionFailure("We should never hit this code path")
        }
    }
    
    private func vortex(tiles:  [[Tile]], targets: [TileCoord], input: Input) -> Transformation {
        guard let playerData = playerData(in: tiles) else { return .zero }
        var newTiles = tiles
        for coord in targets {
            switch tiles[coord].type {
            case .rock:
                let newMonster = tileCreator.randomMonster()
                newTiles[coord.row][coord.column] = Tile(type: newMonster)
            case .monster:
                let newRock = tileCreator.randomRock([], playerData: playerData)
                newTiles[coord.row][coord.column] = Tile(type: newRock)
            default:
                break
            }
        }
        
        self.tiles = newTiles
        return Transformation(transformation: [[TileTransformation(.zero, .zero)]], inputType: input.type, endTiles: newTiles)
    }
    
    private func flameWall(tiles:  [[Tile]], targets: [TileCoord], input: Input) -> Transformation {
        var newTiles = tiles
        for monster in targets {
            if case TileType.monster(let data) = tiles[monster].type {
                newTiles[monster.row][monster.column] = Tile(type: .monster(data.wasAttacked(for: 1, from: .east)))
            }
        }
    
        self.tiles = newTiles
        
        /// create a "dummy" transformation because apparent;y we ignore things unless there is a
        return Transformation(transformation: [[TileTransformation(.zero, .zero)]], inputType: input.type, endTiles: newTiles)

    
    }
}

//MARK: shuffle board

extension Board {
    func shuffleBoard(inputType: InputType) -> Transformation {
        let newTiles = tileCreator.shuffle(tiles: self.tiles)
        self.tiles = newTiles
        return Transformation(transformation: nil, inputType: inputType, endTiles: newTiles)
    }
}



//MARK: - use ability

extension Board {
    
    private func useRune(_ rune: Rune, on targets: [TileCoord], input: Input) -> Transformation {
        switch rune.type {
        case .rainEmbers:
            //TODO: we have to rethink how we keep track of rune's progress.  Right now it is not part of the entity's model which mean we will lose the progress between levels-- I think that would feel bad
            //            use(ability)
            return removeAndReplaces(from: tiles, specificCoord: targets, input: input)
            
        case .getSwifty:
            guard let firstTarget = targets.first, targets.count == 2 else {
                return .zero
            }
            return swap(firstTarget, with: targets.last!, input: input)
            
        case .transformRock:
            return transform(targets, into: TileType.rock(color: .purple, holdsGem: false), input: input)
        case .bubbleUp:
            return bubbleUp(targets.first!, input: input)
        case .flameWall:
            let monsterCoords = targets.compactMap { coord -> TileCoord? in
                if case TileType.monster = tiles[coord].type {
                    return coord
                } else {
                    return nil
                }
            }
            return flameWall(tiles: tiles, targets: monsterCoords, input: input)
        case .vortex:
            return vortex(tiles: tiles, targets: targets, input: input)
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
    
    func findNeighbors(_ coord: TileCoord, killMonsters: Bool = false) -> ([TileCoord], [TileCoord]) {
        let (x,y) = coord.tuple
        guard
            x >= 0,
            x < boardSize,
            y >= 0,
            y < boardSize else { return ([], []) }
        
        if case TileType.monster(_) = tiles[x][y].type, !killMonsters { return ([],[]) }
        if case TileType.pillar = tiles[x][y].type { return ([],[]) }
        var queue = [TileCoord(x, y)]
        var tileCoordSet = Set(queue)
        var head = 0
        var pillars = Set<TileCoord>()
        
        while head < queue.count {
            let tileRow = queue[head].x
            let tileCol = queue[head].y
            let currTile = tiles[tileRow][tileCol]
            head += 1
            //add neighbors to queue
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    //check that it is within bounds, that we havent visited it before, and it's the same type as us
                    if killMonsters {
                        guard
                            valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)),
                            !tileCoordSet.contains(TileCoord(i,j)) else { continue }
                        if case .monster = tiles[i][j].type {
                            queue.append(TileCoord(i,j))
                            tileCoordSet.insert(TileCoord(row: i, column: j))
                        }
                    } else {
                        guard
                            valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol)),
                            !tileCoordSet.contains(TileCoord(i,j)),
                            let myColor = tiles[i][j].type.color,
                            let theirColor = currTile.type.color,
                            myColor == theirColor else { continue }
                        //valid neighbor within bounds
                        if case .pillar = tiles[i][j].type {
                            pillars.insert(TileCoord(i,j))
                        } else {
                            queue.append(TileCoord(i,j))
                            tileCoordSet.insert(TileCoord(i,j))
                        }
                    }
                }
            }
        }
        return (queue, Array(pillars))
    }
    
    func massMine(tiles: [[Tile]], color: Color, input: Input) -> Transformation {
        var selectedCoords: [TileCoord] = []
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if case TileType.rock(let tileColor, _) = tiles[row][col].type,
                    tileColor == color {
                    selectedCoords.append(TileCoord(row: row, column: col))
                }
            }
        }
        
        return mine(selectedCoords: selectedCoords, from: tiles, input: input)
    }
    
    func mine(selectedCoords: [TileCoord], from tiles: [[Tile]], input: Input) -> Transformation {
        
        var intermediateTiles = tiles
        for coord in selectedCoords {
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
        let selectedTilesTransformation = selectedCoords.map { TileTransformation($0, $0) }
        
        //update our store of tilesftiles
        self.tiles = intermediateTiles
        
        // return our new board
        return Transformation(transformation: [selectedTilesTransformation,
                                               newTiles,
                                               shiftDown],
                              inputType: input.type,
                              endTiles: intermediateTiles)
    }
    
    /*
     * Remove and refill tiles from the current board
     *
     *  - replaces each tile in the contiguous group of same-colored tiles with an Empty tile type
     *  - iterates through each column starting an at row 0 and ending at row n-1, and increments a shift counter by 1 when it encounters an Empty sprite placeholder
     *  - swaps the current empty tile at index i with the tile at index i+1, thusly all empty tiles end up near at the "top" of each column
     *  - returns a transformation with the tiles that have been removed, added, and shifted down
     */
    
    func removeAndReplace(from tiles: [[Tile]],
                          tileCoord: TileCoord,
                          singleTile: Bool = false,
                          input: Input,
                          killMonsters: Bool = false) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        var selectedTiles: [TileCoord] = [tileCoord]
        var selectedPillars: [TileCoord] = []
        if !singleTile {
            (selectedTiles, selectedPillars) = findNeighbors(tileCoord, killMonsters: killMonsters)
            if selectedTiles.count < 3 {
                return Transformation(transformation: nil,
                                      inputType: input.type,
                                      endTiles: tiles)
            }
        }
        
        var newTiles : [TileTransformation] = []
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        
        var finalSelectedTiles: [TileCoord] = []
        for coord in selectedTiles {
            // turn the tile into a gem or into an empty
            if case TileType.rock(let color, let holdsGem) = tiles[coord].type, holdsGem {
                intermediateTiles[coord.x][coord.y] = Tile(type: .emptyGem(color))
                finalSelectedTiles.append(coord)
            } else {
                intermediateTiles[coord.x][coord.y] = .empty
                /// keep track of the emptied tiles
                finalSelectedTiles.append(coord)
            }
        }
        
        // decrement the health of each pillar
        for pillarCoord in selectedPillars {
            if case let .pillar(data) = intermediateTiles[pillarCoord.x][pillarCoord.y].type {
                if data.health == 1 {
                    // remove the pillar from the board
                    intermediateTiles[pillarCoord.x][pillarCoord.y] = .empty
                } else {
                    //decrement the pillar's health
                    intermediateTiles[pillarCoord.x][pillarCoord.y] = Tile(type: .pillar(PillarData(color: data.color, health: data.health-1)))
                }
            }
        }
        
        // store tile transforamtions and shift information

        var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
        
        //add new tiles
        addNewTiles(shiftIndices: shiftIndices,
                    shiftDown: &shiftDown,
                    newTiles: &newTiles,
                    intermediateTiles: &intermediateTiles)
        
        //create selectedTilesTransformation array
        let selectedTilesTransformation = finalSelectedTiles.map { TileTransformation($0, $0) }
        
        //update our store of tilesftiles
        self.tiles = intermediateTiles
        
        // return our new board
        return Transformation(transformation: [selectedTilesTransformation,
                                               newTiles,
                                               shiftDown],
                              inputType: input.type,
                              endTiles: intermediateTiles
        )
    }
    
    func removeAndReplaces(from tiles: [[Tile]],
                           specificCoord: [TileCoord],
                           singleTile: Bool = false,
                           input: Input) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        let selectedTiles: [TileCoord] = specificCoord
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        for coord in selectedTiles {
            switch tiles[coord].type {
            case let .pillar(data):
                if data.health == 1 {
                    // remove the pillar from the board
                    intermediateTiles[coord.x][coord.y] = Tile.empty
                } else {
                    //decrement the pillar's health
                    intermediateTiles[coord.x][coord.y] = Tile(type: .pillar(PillarData(color: data.color, health: data.health-1)))
                }
                
            case .rock:
                intermediateTiles[coord.x][coord.y] = Tile.empty
            case .monster:
                intermediateTiles[coord.x][coord.y] = Tile.empty
            default:
                preconditionFailure("We should only use this for rocks, pillars and monsters")
            }
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
                              endTiles: intermediateTiles
        )
    }
    
    
    private func resetAttacks(newTurn: Bool) -> Transformation? {
        func resetAttacks(in tiles: [[Tile]]) -> [[Tile]] {
            var newTiles = tiles
            for (i, row) in tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if case .monster(let data) = tiles[i][j].type, newTurn {
                        newTiles[i][j] = Tile(type: .monster(data.resetAttacks().incrementsAttackTurns()))
                    }
                    
                    if case .player(let data) = tiles[i][j].type {
                        newTiles[i][j] = Tile(type: .player(data.resetAttacks()))
                    }
                    
                    if case let .dynamite(data) = tiles[i][j].type {
                        newTiles[i][j] = Tile(type: .dynamite(DynamiteFuse(count: data.count, hasBeenDecremented: false)))
                    }
                }
            }
            return newTiles
        }
        
        tiles = resetAttacks(in: tiles)
        
        return Transformation(transformation: nil,
                              inputType: .reffingFinished(newTurn: newTurn),
                              endTiles: tiles
        )
        
        
    }
    
    private func collectItem(at coord: TileCoord, input: Input) -> Transformation {
        let selectedTile = tiles[coord]
        
        //remove and replace the single item tile
        let transformation = removeAndReplace(from: tiles, tileCoord: coord, singleTile: true, input: input)
        
        //save the item
        guard case let TileType.item(item) = selectedTile.type,
            var updatedTiles = transformation.endTiles,
            let pp = playerPosition,
            case let .player(data) = updatedTiles[pp].type
            else { return Transformation.zero }
        
        let newCarryModel = data.carry.earn(item.amount, inCurrency: item.type.currencyType)
        // we have to reset attack here because the player has moved but the turn may not be over
        // Eg: it is possible that there could be two or more monsters
        // under the player and the player should be able to attack
        let playerData = data.update(attack: data.attack.resetAttack(), carry: newCarryModel)
        
        updatedTiles[pp.x][pp.y] = Tile(type: .player(playerData))
        
        tiles = updatedTiles
        
        return Transformation(transformation: transformation.tileTransformation,
                              inputType: .collectItem(coord, item, playerData.carry.total(in: item.type.currencyType)),
                              endTiles: updatedTiles)
    }
    
    
    private func monsterDied(at coord: TileCoord, input: Input) -> Transformation {
        // When a monster dies, the player should reset the attack
        // This isnt fool proof if we , but for the most part this will work
        // This may lead to bugs if we introduce another way that players can attack
        // But basically we should only reset attacks if the monster died directly from a player attack
        
        guard let pp = playerPosition,
            case let .player(data) = tiles[pp].type
            else { return Transformation.zero }

        var newTiles = tiles
        newTiles[pp.row][pp.column] = Tile(type: .player(data.update(attack: data.attack.resetAttack())))
        return removeAndReplace(from: newTiles, tileCoord: coord, singleTile: true, input: input)
        //        }
        
    }
    
    private func addNewTiles(shiftIndices: [Int],
                             shiftDown: inout [TileTransformation],
                             newTiles: inout [TileTransformation],
                             intermediateTiles: inout [[Tile]]) {
        // Intermediate tiles is the "in-between" board that has shifted down
        // tiles into and replaced the shifted down tiles with empty tiles
        // the tile creator replaces empty tiles with new tiles
        let createdTiles: [[Tile]] = tileCreator.tiles(for: intermediateTiles)
        
        for (col, shifts) in shiftIndices.enumerated() where shifts > 0 {
            for startIdx in 0..<shifts {
                let startRow = boardSize + startIdx
                let startCol = col
                let endRow = startRow - shifts
                let endCol = col
                
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
        
        intermediateTiles = createdTiles
    }
    
    private func calculateShiftIndices(for tiles: inout [[Tile]]) -> ([TileTransformation], [Int]) {
        var shiftIndices = Array(repeating: 0, count: tiles.count)
        var shiftDown: [TileTransformation] = []
        for col in 0..<tiles.count {
            var shift = 0
            for row in 0..<tiles.count {
                switch tiles[row][col].type {
                case .pillar:
                    shift = 0
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
    static func build(tileCreator: TileStrategy,
                      difficulty: Difficulty,
                      level: Level) -> Board {
        //create a boardful of tiles
        let tilesStruct: [[Tile]] = tileCreator.board(difficulty: difficulty)
        
        //let the world know we built the board
        InputQueue.append(Input(.boardBuilt, tilesStruct))
        
        //init new board
        return Board(tileCreator: tileCreator, tiles: tilesStruct, level: level)
    }
}

// MARK: - Rotation

extension Board {
    
    enum RotationalDirection {
        case counterClockwise
        case clockwise
    }
    func refillEmpty(inputType: InputType) -> Transformation {
        /// Pillars can create voids of .empty tiles, therefore on rotate we may need to create and shift down tiles
        var intermediateTiles: [[Tile]] = self.tiles
        
        if typeCount(for: self.tiles, of: .empty).count > 0 {
            // store tile transforamtions and shift information
            var newTiles : [TileTransformation] = []
            var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
            
            //add new tiles
            addNewTiles(shiftIndices: shiftIndices,
                        shiftDown: &shiftDown,
                        newTiles: &newTiles,
                        intermediateTiles: &intermediateTiles)
            
            // return our new board
            self.tiles = intermediateTiles
            return Transformation(transformation: [newTiles, shiftDown],
                                  inputType: inputType,
                                  endTiles: intermediateTiles)
        }
        return Transformation(transformation: nil, inputType: .refillEmpty, endTiles: self.tiles)
    }
    
    func rotate(_ direction: RotationalDirection, preview: Bool) -> [Transformation] {
        var transformation: [TileTransformation] = []
        var allTransformations: [Transformation] = []
        var intermediateTiles: [[Tile]] = []
        let numCols = boardSize - 1
        let inputType: InputType
        switch direction {
        case .counterClockwise:
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
            inputType = .rotateCounterClockwise(preview: preview)
        case .clockwise:
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
            inputType = .rotateClockwise(preview: preview)
        }
        
        allTransformations.append(Transformation(transformation: [transformation],
                                                 inputType: inputType,
                                                 endTiles: intermediateTiles))
        
        
        /// Pillars can create voids of .empty tiles, therefore on rotate we may need to create and shift down tiles
        if typeCount(for: self.tiles, of: .empty).count > 0 {
            // store tile transforamtions and shift information
            var newTiles : [TileTransformation] = []
            var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
            
            //add new tiles
            addNewTiles(shiftIndices: shiftIndices,
                        shiftDown: &shiftDown,
                        newTiles: &newTiles,
                        intermediateTiles: &intermediateTiles)
            
            // return our new board
            
            allTransformations.append(Transformation(transformation: [newTiles, shiftDown],
                                                     inputType: inputType,
                                                     endTiles: intermediateTiles))
        }
        
        /// We support previewing the rotate transformation.  In that case, dont update our tiles to the rotated tiles just yet.  Wait for rotatePreviewFinish to do that.
        if !preview {
            self.tiles = intermediateTiles
        }
        
        return allTransformations
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
            isWithinBounds(playerPosition.rowBelow) else {
                return Transformation(transformation: [], inputType: .gameWin)
        }
        
        return Transformation(transformation: [[TileTransformation(playerPosition, playerPosition.rowBelow)]],
                              inputType: .gameWin,
                              endTiles: tiles)
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


// MARK: - Combat
extension Board {
    
    func attack(_ input: Input) -> Transformation {
        guard case InputType.attack(let type,
                                    let attackerPosition,
                                    let defenderPostion,
                                    let affectedTiles,
                                    _) = input.type else {
                                        return Transformation.zero
        }
        var attacker: EntityModel
        var defender: EntityModel
        var dodged = false
        
        
        //TODO: DRY, extract and shorten this code
        if let defenderPosition = defenderPostion,
            case let .player(playerModel) = tiles[attackerPosition].type,
            case let .monster(monsterModel) = tiles[defenderPosition].type,
            let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = playerModel
            defender = monsterModel
            
            let (newAttackerData, newDefenderData, defenderDodged) = CombatSimulator.simulate(attacker: attacker,
                                                                              defender: defender,
                                                                              attacked: relativeAttackDirection)
            
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.player(newAttackerData))
            tiles[defenderPosition.x][defenderPosition.y] = Tile(type: TileType.monster(newDefenderData))
            
            dodged = defenderDodged
            
        } else if let defenderPosition = defenderPostion,
            case let .player(playerModel) = tiles[defenderPosition].type,
            case let .monster(monsterModel) = tiles[attackerPosition].type,
            let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = monsterModel
            defender = playerModel
            
            let (newAttackerData, newDefenderData, defenderDodged) = CombatSimulator.simulate(attacker: attacker,
                                                                              defender: defender,
                                                                              attacked: relativeAttackDirection)
            
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(newAttackerData))
            tiles[defenderPosition.x][defenderPosition.y] = Tile(type: TileType.player(newDefenderData))
            
            dodged = defenderDodged
        } else if case let .player(playerModel) = tiles[attackerPosition].type,
            defenderPostion == nil {
            //just note that the player attacked
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.player(playerModel.didAttack()))
            
        } else if case let .monster(monsterModel) = tiles[attackerPosition].type,
            let defenderPosition = defenderPostion,
            case .pillar (let data) = tiles[defenderPosition].type {
            //just note that the monster attacked
            // and the pillar takes one damage
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(monsterModel.didAttack()))
            if data.health == 1 {
                tiles[defenderPosition.x][defenderPosition.y] = Tile.empty
            } else {
                tiles[defenderPosition.x][defenderPosition.y] = Tile(type: .pillar(PillarData(color: data.color, health: data.health - 1)))
                
            }
        } else if case let .monster(monsterModel) = tiles[attackerPosition].type,
            defenderPostion == nil {
            //just note that the monster attacked
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(monsterModel.didAttack()))
        }
        
        return Transformation(inputType: InputType.attack(attackType: type,
                                                          attacker: attackerPosition,
                                                          defender: defenderPostion,
                                                          affectedTiles: affectedTiles,
                                                          dodged: dodged),
                              endTiles: tiles)
    }
}
