//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import CoreGraphics

class Board: Equatable {
    static func == (lhs: Board, rhs: Board) -> Bool {
        return false
    }
    
    func calculateNeighbors(for tiles: [[Tile]]) -> [[Tile]] {
        let neighbors = findNeighborsForBoard(in: tiles)
        var newTiles = tiles
        for row in 0..<newTiles.count {
            for col in 0..<newTiles.count {
                if case TileType.rock(let color, let hasGem, _) = newTiles[row][col].type {
                    let groupCount = neighbors[row][col]
                    newTiles[row][col] =
                    Tile(
                        type: TileType.rock(color: color, holdsGem: hasGem, groupCount: groupCount),
                        bossTargetedToEat: newTiles[row][col].bossTargetedToEat
                    )
                }
            }
        }
        
        return newTiles
        
    }
    
    private var _tiles : [[Tile]]
    private(set) var tiles: [[Tile]] {
        get {
            return _tiles
        } set {
            //            let neighnors = findNeighborsForBoard(in: newValue)
            _tiles = calculateNeighbors(for: newValue)
            //            for row in 0..<newTiles.count {
            //                for col in 0..<newTiles.count {
            //                    if case TileType.rock(let color, let hasGem, _) = newTiles[row][col].type {
            //                        let groupCount = neighnors[row][col]
            //                        newTiles[row][col] =
            //                            Tile(
            //                                type: TileType.rock(color: color, holdsGem: hasGem, groupCount: groupCount),
            //                                bossTargetedToEat: newTiles[row][col].bossTargetedToEat
            //                            )
            //                    }
            //                }
            //            }
            //
            //            _tiles = newTiles
        }
    }
    private(set) var level: Level
    var tileCreator: TileStrategy
    
    private var playerEntityData: EntityModel? {
        guard let playerPosition = playerPosition,
              case let TileType.player(data) = tiles[playerPosition].type else { return nil }
        return data
    }
    
    private var playerPosition : TileCoord? {
        return getTileStructPosition(.player(.zero))
    }
    
    private let tutorialConductor: TutorialConductor?
    private var hasAlreadySpawnedMonsterForTutorial = false
    private var shouldSpawnMonsterDuringTutorial: Bool {
        if tutorialConductor?.isTutorial ?? false {
            return !hasAlreadySpawnedMonsterForTutorial
        }
        return false
    }
    
    
    var boardSize: Int { return tiles.count }
    
    
    subscript(index: TileCoord) -> TileType? {
        guard isWithinBounds(index) else { return nil }
        return tiles[index.x][index.y].type
        
    }
    
    init(tileCreator: TileStrategy,
         tiles: [[Tile]],
         level: Level,
         boardLoaded: Bool,
         tutorialConductor: TutorialConductor?) {
        self.tileCreator = tileCreator
        self._tiles = tiles
        self.level = level
        self.tutorialConductor = tutorialConductor
        
        // trigger a neighbor count pass
        self.tiles = tiles
        
        if (boardLoaded) {
            // let the world know we loaded the board from a save
            InputQueue.append(.init(.boardLoaded, self.tiles))
        } else {
            //let the world know we built the board
            InputQueue.append(.init(.boardBuilt, self.tiles))
        }
        
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
            case .monster(let data), .player(let data):
                let attacks = calculateAttacks(for: data, from: tileCoord)
                InputQueue.append(Input(.tileDetail(type, attacks)))
                return
                
            case .pillar, .item, .offer, .exit, .dynamite:
                InputQueue.append(Input(.tileDetail(type, [])))
                return
                
            default:
                /// create the transformation for tapping on something.
                transformation = removeAndReplace(from: tiles, tileCoord: tileCoord, input: input)
                
                guard let playerData = playerEntityData,
                      let pp = playerPosition,
                      let count =  transformation?.removed?.count else {
                          /// no update for the player is needed
                          break
                      }
                
                /// by doing this we have recorded the progress of the runes.
                let updatedPlayer = playerData.progressRunes(tileType: type, count: count)
                tiles[pp.row][pp.column] = Tile(type: .player(updatedPlayer))
                
            }
            
        case .attack:
            transformation = attack(input)
            
        case .monsterDies(let tileCoord, _, let deathBy):
            guard var playerData = playerEntityData,
                  let pp = playerPosition else {
                      /// no update for the player is needed
                      break
                  }
            
            // only remove a single tile when a monster dies
            if deathBy == .player {
                playerData = playerData.progressRunes(tileType: TileType.monster(.zero), count: 1)
            }
            tiles[pp.row][pp.column] = Tile(type: .player(playerData))
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
            
        case .itemUsed(let rune, let allTarget):
            let trans = useRune(rune, on: allTarget, input: input)
            
            InputQueue.append(
                Input(
                    InputType.transformation(
                        trans
                    ),
                    tiles
                )
            )
            
        case .decrementDynamites(let dynamiteCoords):
            let trans = decrementDynamites(input: input, dynamiteCoords: dynamiteCoords)
            InputQueue.append(Input(.transformation(trans)))
            return
            
        case .rotatePreviewFinish:
            let transformation = rotatePreviewFinish(input: input)
            InputQueue.append(Input(.transformation(transformation)))
            return
            
        case .refillEmpty:
            InputQueue.append(Input(.transformation([refillEmpty(inputType: .refillEmpty)])))
            return
            
        case .noMoreMoves:
            // we need to send the player's data over to the Renderer
            let basicTransformation = Transformation(transformation: [TileTransformation(playerCoord, playerCoord)], inputType: input.type, endTiles: self.tiles)
            InputQueue.append(Input(.transformation([basicTransformation])))
            return
            
        case .noMoreMovesConfirm(let payTwoHearts, let pay25Percent):
            let shuffleBoard = shuffleBoard(input: input, pay2Hearts: payTwoHearts, pay25PercentGems: pay25Percent)
            InputQueue.append(Input(.transformation(shuffleBoard)))
            return
            
        case .unlockExit:
            InputQueue.append(Input(.transformation([unlockExit(inputType: input.type)])))
            return
            
        case let .goalCompleted(completedGoals, allGoalsCompleted: allGoalsCompleted):
            let completedGoals = self.completedGoals(completedGoals, inputType: input.type)
            let transformations: [Transformation]
            if allGoalsCompleted {
                let unlockExit = self.unlockExit(inputType: InputType.unlockExit)
                transformations = [completedGoals, unlockExit]
            } else {
                transformations = [completedGoals]
            }
            InputQueue.append(Input(.transformation(transformations)))
            return
            
            
            
        case let .collectOffer(offerCoord, storeOffer, _, _):
            
            /// return early here because this function returns an array of transformations
            let trans = self.collect(offer: storeOffer, at: offerCoord, input: input)
            InputQueue.append(Input(.transformation(trans)))
            return
            
        case let .collectChestOffer(offer: offer):
            let trans = self.collectChestOffer(offer, input: input)
            InputQueue.append(Input(.transformation(trans)))
            return
            
        case .runeReplaced(_, let replacedRune, let newRune, let promptedByChest):
            transformation = self.runeReplaced(replacedRune, withNewRune: newRune, promptedByChest: promptedByChest, inputType: input.type)
            
        case .foundRuneDiscarded(let rune):
            transformation = self.foundRuneDiscarded(rune, input: input)
            
            // handling boss input
        case .bossTurnStart(let phase):
            switch phase.bossState.stateType {
            case .targetEat:
                transformation = self.bossTargetsWhatToEat(input: input)
                
            case .eats:
                let trans = bossEatsRocks(input: input)
                InputQueue.append(Input(.transformation(trans)))
                return
                
            case .targetAttack:
                transformation = self.bossTargetsWhatToAttack(input: input)
                
            case let .attack(type: type):
                transformation = self.bossExecutesAttacks(input: input, attackType: type)
                
            case .intro, .rests, .phaseChange, .superAttack, .targetSuperAttack:
                transformation = self.resetBossFlags(input: input)
            }
            
        case .bossPhaseStart:
            transformation = bossPhaseChange(input: input)
            
        case .gameLose,
                .play,
                .pause,
                .animationsFinished,
                .playAgain,
                .boardBuilt,
                .boardLoaded,
                .selectLevel,
                .newTurn,
                .visitStore, .loseAndGoToStore,
                .itemUseCanceled, .itemCanBeUsed, .rotatePreview, .tileDetail, .levelGoalDetail, .runeReplacement,
                .tutorialPhaseStart, .tutorialPhaseEnd:
            transformation = nil
        }
        
        guard let trans = transformation else { return }
        InputQueue.append(Input(.transformation([trans])))
    }
    
    private func resetBossFlags(input: Input) -> Transformation {
        //        guard case let InputType.bossTurnStart(phase) = input.type else { return .zero }
        for row in 0..<tiles.count {
            for column in 0..<tiles[row].count {
                tiles[row][column].bossTargetedToEat = false
            }
        }
        return Transformation(transformation: nil, inputType: input.type, endTiles: self.tiles)
    }
    
    // Take the boss phase change targets and throw them into a transformation!
    private func bossPhaseChange(input: Input) -> Transformation {
        guard case let InputType.bossPhaseStart(phase) = input.type else { return .zero }
        var tileTransformation: [TileTransformation] = []
        if let spawnMonsterAttacks = phase.phaseChangeTagets.spawnMonsters {
            spawnMonsterAttacks.forEach { bossTileAttack in
                let coord = bossTileAttack.tileCoord
                if let type = bossTileAttack.tileType.entityType,
                   let newMonster = tileCreator.monsterWithType(type) {
                    tiles[coord.row][coord.col] = newMonster
                    tileTransformation.append(.init(coord, coord))
                }
            }
        }
        
        if let throwRocks = phase.phaseChangeTagets.throwRocks {
            throwRocks.forEach { bossTileAttack in
                let coord = bossTileAttack.tileCoord
                tiles[coord.row][coord.col] = Tile(type: bossTileAttack.tileType)
                tileTransformation.append(.init(coord, coord))
            }
        }
        
        // turns off flags for targeting to eat in the case that we phase change right as the boss is going to eat
        let _ = resetBossFlags(input: input)
        
        return Transformation(transformation: (tileTransformation.isEmpty ? nil : tileTransformation), inputType: input.type, endTiles: self.tiles)
    }
    
    private func bossTargetsWhatToEat(input: Input) -> Transformation {
        guard case let InputType.bossTurnStart(phase) = input.type else { return .zero }
        if let coords = phase.bossState.targets.whatToEat {
            coords.forEach { coord in
                tiles[coord.row][coord.column].bossTargetedToEat = true
            }
        }
        return Transformation(transformation: nil, inputType: .bossTurnStart(phase), endTiles: self.tiles)
        
    }
    
    private func bossEatsRocks(input: Input) -> [Transformation] {
        guard case let InputType.bossTurnStart(phase) = input.type else { return [.zero] }
        
        var tileTrans: [TileTransformation] = []
        
        if let coords = phase.bossState.targets.eats {
            coords.forEach { coord in
                tileTrans.append(.init(coord, coord))
            }
        }
        
        let eatRocksTrans = Transformation(transformation: tileTrans.isEmpty ? nil : tileTrans, inputType: input.type, endTiles: tiles)
        let targets = phase.bossState.targets.eats ?? []
        let removeAndReplaceTransformation = self.removeAndReplaces(from: tiles, specificCoord: targets, input: input)
        
        return [eatRocksTrans, removeAndReplaceTransformation]
        
    }
    
    private func bossTargetsWhatToAttack(input: Input) -> Transformation {
        guard case let InputType.bossTurnStart(phase) = input.type else { return .zero }
        return Transformation(transformation: nil, inputType: .bossTurnStart(phase), endTiles: self.tiles)
        
    }
    
    // Only excutes attacks for the single AttackType that is past in.
    private func bossExecutesAttacks(input: Input, attackType executeAttackType: BossAttackType) -> Transformation {
        guard case let InputType.bossTurnStart(phase) = input.type else { return .zero }
        var tileTransformations: [TileTransformation] = []
        
        // posion attack
        // dealt with separately because we need to understand the relationship of the tiles to the ones above it because pillars block the poison damage
        
        if let attackedColumns = phase.bossState.poisonAttackColumns,
           executeAttackType == .poison
        {
            for col in attackedColumns {
                var hitPillarShouldStop = false
                for row in (0..<tiles.count).reversed() {
                    if hitPillarShouldStop { break }
                    
                    let coord = TileCoord(row, col)
                    switch tiles[coord].type {
                    case .pillar:
                        tileTransformations.append(TileTransformation(coord, coord))
                        hitPillarShouldStop = true
                        
                    case .player(let playerData):
                        var newPlayer = playerData.wasAttacked(for: 1, from: .north)
                        if playerData.isDead {
                            newPlayer = newPlayer.update(killedBy: .lavaHorse)
                        }
                        
                        tiles[row][col] = Tile(type: .player(newPlayer))
                        tileTransformations.append(TileTransformation(coord, coord))
                        
                    default:
                        tileTransformations.append(TileTransformation(coord, coord))
                        break
                    }
                }
            }
            
        }
        
        // dynamite and spawning stuff
        if let bossAttackDict = phase.bossState.targets.attack {
            bossAttackDict.forEach { (attackType, coords) in
                coords.forEach { coord in
                    if attackType == .dynamite, executeAttackType == .dynamite {
                        tiles[coord.row][coord.column] = Tile(type: .dynamite(.init(count: 3, hasBeenDecremented: false)))
                        
                    } else if case BossAttackType.spawnMonster = executeAttackType,
                              case BossAttackType.spawnMonster(withType: let monsterType) = attackType,
                              let tile = tileCreator.monsterWithType(monsterType) {
                        tiles[coord.row][coord.column] = tile
                    }
                }
            }
        }
        
        return Transformation(transformation: tileTransformations.isEmpty ? nil : tileTransformations, inputType: .bossTurnStart(phase), endTiles: self.tiles)
        
    }
    
    
    private func foundRuneDiscarded(_ rune: Rune, input: Input) -> Transformation {
        guard let specificCoord = tiles(of: TileType.offer(StoreOffer(type: .rune(rune), tier: 1, textureName: "", title: "", body: "", startingPrice: 0))).first else {
            return Transformation(transformation: [], inputType: input.type, endTiles: self.tiles)
            
        }
        
        let removeAndReplace = removeAndReplaces(from: tiles, specificCoord: [specificCoord], input: input)
        
        return removeAndReplace
    }
    
    private func runeReplaced(_ replacedRune: Rune, withNewRune newRune: Rune, promptedByChest: Bool, inputType: InputType) -> Transformation {
        guard let pp = playerPosition,
            case let .player(data) = tiles[pp].type
        else {
            return Transformation(transformation: [], inputType: inputType, endTiles: self.tiles)
        }
        
        var newTiles = tiles
        
        let pickaxe: Pickaxe?
        
        // rune replacement can be prompted by the chest item or by a player collecting an offer
        // when prompted by the chest, the newRune is not "on the board", so we need to replace the rune in this transformation
        if promptedByChest {
            pickaxe = data.pickaxe?.replaceRune(replacedRune, withNewRune: newRune)
        }
        // if the rune new rune is being collected by the player, then we first make room in the pickaxe by removing the rune.
        // then the referee will allow us to collect the rune as normal
        else {
            pickaxe = data.pickaxe?.removeRune(replacedRune)
        }
        
        let newPlayer = data.update(pickaxe: pickaxe)
        
        newTiles[pp.x][pp.y] = Tile(type: .player(newPlayer))
        
        tiles = newTiles
        
        return Transformation(transformation: nil, inputType: inputType, endTiles: self.tiles)
        
    }
    
    /// Only to be used for collecting the chest offer
    private func collectChestOffer(_ offer: StoreOffer, input: Input) -> [Transformation] {
        
        // Get the item and the new end tiles from the remove and replace transformation
        guard let pp = playerPosition,
              case let .player(data) = tiles[pp].type
        else { return [Transformation(transformation: [], inputType: input.type, endTiles: self.tiles)] }
        
        var newTiles = tiles
        
        // grab the effect from the store offer for convenience
        let effect = offer.effect
        
        // we have to reset attack here because the player has moved but the turn may not be over
        // Eg: it is possible that there could be monster, item, monster in a row below the player and the player should be able to kill the second monster after collecting the offer/effect
        let playerData = data.update(attack: data.attack.resetAttack()).applyEffect(effect)
        
        /// store the update player data in the new updated tiles
        newTiles[pp.x][pp.y] = Tile(type: .player(playerData))
        
        /// update our tile stores
        tiles = newTiles
        
        let transformation = Transformation(transformation: [.init(pp, pp)], inputType: input.type, endTiles: self.tiles)
        
        /// If this is a one time use potion then we will tack on that trackformation after the remove and replace
        if effect.stat == .oneTimeUse {
            return useOneTimeUseEffect(offer: offer, input: input, previousTransformation: transformation)
        }
        /// otherwise just return the tranformation for remove and replace with the updated player
        else {
            return [transformation]
        }
    }
    
    /// This is for collecting runes or other things like max health
    private func collect(offer: StoreOffer, at offerCoord: TileCoord, input: Input) -> [Transformation] {
        
        // get the collected item's tile
        let collectedItemTile = tiles[offerCoord]
        
        // find the other offer of the same tier if it exist
        // it is possible for the other item not to exist in the case where a player discards a found rune when there pickaxe handle is full.  IN that case, the other offer from that tier is not discarded.
        var otherOfferTile: TileCoord?
        var otherOffer: StoreOffer?
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                if case TileType.offer(let tileOffer) = tiles[i][j].type,
                   tileOffer != offer,
                   tileOffer.tier == offer.tier {
                    otherOfferTile = TileCoord(i, j)
                    otherOffer = tileOffer
                }
            }
        }
        
        // create a transformation to return later
        var transformation: Transformation
        
        // if it does exists then remove both the collected offer and the other offer from the board
        if let otherOfferTile = otherOfferTile,
           let otherOffer = otherOffer,
           case InputType.collectOffer(let collectedCoord, let collectedStoreOffer, _, _) = input.type,
           // snake eye is a special case whre we dont want to remove the other offer from the same tier
           collectedStoreOffer.type != .snakeEyes
        {
            transformation = removeAndReplaces(from: tiles, specificCoord: [offerCoord, otherOfferTile], input: Input(.collectOffer(collectedCoord: collectedCoord, collectedOffer: collectedStoreOffer, discardedCoord: otherOfferTile, discardedOffer: otherOffer)), forceSpawnMonsters: shouldSpawnMonsterDuringTutorial)
            
            hasAlreadySpawnedMonsterForTutorial = true
        }
        // otherwise just remove and replace the single item tile
        else {
            transformation = removeAndReplace(from: tiles, tileCoord: offerCoord, singleTile: true, input: input, forceMonsterSpawn: shouldSpawnMonsterDuringTutorial)
            
            hasAlreadySpawnedMonsterForTutorial = true
        }
        
        // Get the item and the new end tiles from the remove and replace transformation
        guard case let TileType.offer(storeOffer) = collectedItemTile.type,
              var updatedTiles = transformation.endTiles,
              let pp = playerPosition,
              case let .player(data) = updatedTiles[pp].type
        else { return [transformation] }
        
        // grab the effect from the store offer for convenience
        let effect = storeOffer.effect
        
        // we have to reset attack here because the player has moved but the turn may not be over
        // Eg: it is possible that there could be monster, item, monster in a row below the player and the player should be able to kill the second monster after collecting the offer/effect
        let playerData = data.update(attack: data.attack.resetAttack()).applyEffect(effect)
        
        /// store the update player data in the new updated tiles
        updatedTiles[pp.x][pp.y] = Tile(type: .player(playerData))
        
        /// update our tile stores
        tiles = updatedTiles
        
        /// update the previos transformation with our new tiles (basically just with the applied effect and reset attacks on the player)
        transformation.endTiles = self.tiles
        
        
        /// If this is a one time use potion then we will tack on that trackformation after the remove and replace
        if effect.stat == .oneTimeUse {
            return useOneTimeUseEffect(offer: storeOffer, input: input, previousTransformation: transformation)
        }
        /// otherwise just return the tranformation for remove and replace with the updated player
        else {
            return [transformation]
        }
    }
    
    private func randomTilecoord(ofType: TileType) -> TileCoord? {
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if tiles[row][col].type == ofType {
                    return TileCoord(row, col)
                }
            }
        }
        
        return nil
    }
    
    private func reservedCoords() -> Set<TileCoord> {
        var tileCoords: [TileCoord] = []
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                switch tiles[i][j].type {
                case .exit, .offer, .pillar, .monster, .item, .rock(color: _, holdsGem: true, _), .player:
                    tileCoords.append(TileCoord(i, j))
                default:
                    continue
                }
            }
        }
        return Set<TileCoord>(tileCoords)
    }
    
    //    private func randomItem(in tier: Int, excludeRunesInPickaxe pickaxe: Pickaxe) -> StoreOffer {
    //        let offersInTier = self.level.potentialItems.filter { $0.tierIndex == tier }
    //        let randomNumber = Int.random(abs(tileCreator.randomSource.nextInt())) % offersInTier.count
    //        let randomItem = offersInTier[randomNumber]
    //
    //        if let rune = randomItem.rune, pickaxe.runes.contains(rune) {
    //            // repeat until we get one that the current pickaxe doesnt contain.
    //            return self.randomItem(in: tier, excludeRunesInPickaxe: pickaxe)
    //        } else {
    //            return randomItem
    //        }
    //    }
    
    private func randomTwoItem(in tier: Int, excludeRunesInPickaxe pickaxe: Pickaxe) -> [StoreOffer] {
        let offersInTier = self.level.potentialItems.filter { $0.tierIndex == tier }
        
        // store two unique random items
        var randomNumbersSet = Set<Int>()
        
        // grab two unique random numbers
        while randomNumbersSet.count < 2 {
            let randomNumber = Int.random(abs(tileCreator.randomSource.nextInt())) % offersInTier.count
            randomNumbersSet.insert(randomNumber)
        }
        
        let randomNumbers = Array(randomNumbersSet)
        
        // store two random items
        var randomItems : [StoreOffer] = []
        
        // get two random items
        var count = 0
        while randomItems.count < 2 {
            let index = randomNumbers[count]
            let randomItem = offersInTier[index]
            if let rune = randomItem.rune, pickaxe.runes.contains(rune) {
                // dont choose an item the player already has
                continue
            }
            count += 1
            randomItems.append(randomItem)
        }
        
        // finally return the random items.
        return randomItems
    }
    
    
    private func contains(offer: StoreOffer) -> Bool  {
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if case TileType.offer(let storeOffer) = tiles[row][col].type, storeOffer == offer {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    private func completedGoals(_ goals: [GoalTracking], inputType: InputType) -> Transformation {
        
        /// keep track of how many goals we have awarded so far.
        let awardedGoalsCount = self.level.goalProgress.filter({ $0.hasBeenRewarded} ).count
        
        // Lets keep track of the completed goals before we do anything else
        self.level.goalProgress.append(contentsOf: goals)
        
        // Create a transformation based on how many goals are completed and where the player is in the mine
        guard let pp = playerPosition, case TileType.player(let data) = tiles[pp].type, let pickaxe = data.pickaxe else { return .zero }
        let playerQuadrant = Quadrant.quadrant(of: pp, in: boardSize)
        var transformedTiles: [TileTransformation] = []
        var reservedCoords = self.reservedCoords()
        var offers: [StoreOffer] = []
        for (idx, _) in goals.enumerated() {
            // get a random coord not in the reserved set
            let randomCoordInAnotherQuadrant = playerQuadrant.other.randomCoord(for: boardSize, notIn: reservedCoords)
            
            /// dont overwrite this coord in the future
            reservedCoords.insert(randomCoordInAnotherQuadrant)
            
            // get another random coord not in the reserved set
            let anotherRandomCoordInAnotherQuadrant = playerQuadrant.other.randomCoord(for: boardSize, notIn: reservedCoords)
            
            /// dont overwrite this coord in the future
            reservedCoords.insert(anotherRandomCoordInAnotherQuadrant)
            
            
            /// record these tiles we are transforming
            transformedTiles.append(TileTransformation(randomCoordInAnotherQuadrant, randomCoordInAnotherQuadrant))
            
            transformedTiles.append(TileTransformation(anotherRandomCoordInAnotherQuadrant, anotherRandomCoordInAnotherQuadrant))
            
            
            /// get a random offer
            let tier = awardedGoalsCount + idx
            let randomOffers = randomTwoItem(in: tier, excludeRunesInPickaxe: pickaxe)
            
            /// transform the tile
            tiles[randomCoordInAnotherQuadrant.row][randomCoordInAnotherQuadrant.column] = Tile(type: .offer(randomOffers[0]))
            
            tiles[anotherRandomCoordInAnotherQuadrant.row][anotherRandomCoordInAnotherQuadrant.column] = Tile(type: .offer(randomOffers[1]))
            
            offers = randomOffers
        }
        
        self.tiles = tiles
        return Transformation(transformation: transformedTiles, inputType: inputType, endTiles: tiles, offers: offers)
    }
    
    private func playerDataUpdated(inputType: InputType) -> Transformation {
        self.tiles = tiles
        return Transformation(transformation: nil, inputType: inputType, endTiles: tiles)
    }
    
    private func unlockExit(inputType: InputType) -> Transformation {
        var newTiles = tiles
        
        guard let exitCoord = tileCoords(for: tiles, of: .exit(blocked: true)).first else {
            return Transformation(transformation: nil, inputType: inputType, endTiles: self.tiles)
        }
        
        newTiles[exitCoord.row][exitCoord.column] = Tile(type: .exit(blocked: false))
        
        self.tiles = newTiles
        
        return Transformation(transformation: [TileTransformation(exitCoord, exitCoord)], inputType: inputType, endTiles: self.tiles)
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
        return [Transformation(transformation: nil, inputType: .rotatePreviewFinish(spriteAction, trans), endTiles: tiles)]
    }
    
    private func decrementDynamites(input: Input, dynamiteCoords: Set<TileCoord>) -> [Transformation] {
        
        var removedRocksAndPillars: [TileCoord] = []
        var explodedDynamiteCoords: [TileCoord] = []
        
        let orderedDynamite = Array(dynamiteCoords)
            .map { coord -> (TileCoord, DynamiteFuse) in
                if case TileType.dynamite(let fuse) = tiles[coord].type {
                    return (coord, fuse)
                } else {
                    fatalError()
                }
                
            }.sorted { first, second in
                return first.1.count <= second.1.count
            }.map { $0.0 }
        
        
        for coord in orderedDynamite {
            if case let TileType.dynamite(data) = tiles[coord].type {
                let newFuse = data.count - 1
                
                if newFuse <= 0 {
                    /// EXPLODE
                    tiles[coord.row][coord.column] = Tile(type: .dynamite(DynamiteFuse(count: newFuse, hasBeenDecremented: true)))
                    explodedDynamiteCoords.append(coord)
                    removedRocksAndPillars.append(coord)
                    
                    let affectedNeighbors = coord.orthogonalNeighbors
                    for neighborCoord in affectedNeighbors {
                        guard isWithinBounds(neighborCoord) else { continue }
                        switch tiles[neighborCoord].type {
                        case .dynamite:
                            // blow up your neighbors, but dont do it if they are already gonna blow up
                            tiles[neighborCoord.row][neighborCoord.column] = Tile(type: .dynamite(DynamiteFuse(count: 0, hasBeenDecremented: false)))
                        case .player(let playerData):
                            tiles[neighborCoord.row][neighborCoord.column] = Tile(type: .player(playerData.wasAttacked(for: 1, from: neighborCoord.direction(relative: coord) ?? .east)))
                        case .monster(let monsterData):
                            tiles[neighborCoord.row][neighborCoord.column] = Tile(type: .monster(monsterData.wasAttacked(for: 1, from: neighborCoord.direction(relative: coord) ?? .east)))
                        case .rock, .pillar, .gem:
                            removedRocksAndPillars.append(neighborCoord)
                        case .empty, .exit, .emptyGem:
                            () // purposefully left blank
                        case .item, .offer:
                            ()
                        }
                    }
                } else {
                    tiles[coord.row][coord.column] = Tile(type: .dynamite(DynamiteFuse(count: newFuse, hasBeenDecremented: true)))
                    
                    let affectedNeighbors = coord.orthogonalNeighbors
                    for neighborCoord in affectedNeighbors {
                        guard isWithinBounds(neighborCoord) else { continue }
                        switch tiles[neighborCoord].type {
                        case .dynamite(let fuse):
                            if fuse.count <= 0 {
                                // my neighbor exploded so I should explode.
                                tiles[coord.row][coord.column] = Tile(type: .dynamite(DynamiteFuse(count: 0, hasBeenDecremented: true)))
                                removedRocksAndPillars.append(coord)
                                explodedDynamiteCoords.append(coord)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
        }
        let explodedDyanmiteTileTrans = explodedDynamiteCoords.map { TileTransformation($0, $0) }
        let dynamiteTransformation = Transformation(transformation: explodedDyanmiteTileTrans, inputType: input.type, endTiles: tiles)
        
        if explodedDyanmiteTileTrans.isEmpty {
            return [dynamiteTransformation]
        } else {
            
            let removedAndReplaced = removeAndReplaces(from: tiles, specificCoord: removedRocksAndPillars, input: input, destroysGemsInRocks: true, monsterDeathType: .dynamite)
            return [dynamiteTransformation, removedAndReplaced]
        }
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
}

//MARK: - Items
extension Board {
    
    private func useOneTimeUseEffect(offer: StoreOffer, input: Input, previousTransformation: Transformation) -> [Transformation] {
        
        var trans: Transformation?
        
        switch offer.effect.kind {
        case .killMonster:
            trans = useDeathPotion(input: input)
            
        case .transmogrify:
            trans = useTransmogrify(offer: offer, input: input)

        case .gemMagnet:
            trans = useGemMagnet(input: input)
            
        case .infusion:
            trans = useInfusion(input: input)
            
        case .snakeEyes:
            trans = useSnakeEyes(input: input)
            
        case .liquifyMonsters:
            trans = useLiquifyMonsters(input: input, offer: offer)
            
        case .chest:
            trans = useChest(input: input)
            
        case .escape:
            trans = useEscape(input: input)
            
            
        default:
            preconditionFailure("Currently only killMonster and transmogrify are set up for this code path")
        }
        
        return (trans != nil) ? [previousTransformation, trans!] : [previousTransformation]
    }
    
    func useEscape(input: Input) -> Transformation {
        let exitPosition = tiles { tileType in
            if case TileType.exit = tileType {
                return true
            } else {
                return false
            }
        }
        
        
        guard let exitPosition = exitPosition.first else {
            return Transformation(transformation: [], inputType: input.type, endTiles: self.tiles)
        }
        
        var newTiles = self.tiles
        
        newTiles[exitPosition.row][exitPosition.col] = Tile(type: .exit(blocked: false))
        let tileTransformation: [TileTransformation] = [.init(exitPosition, exitPosition)]
        
        
        self.tiles = newTiles
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles)
        
    }
    
    func useChest(input: Input) -> Transformation? {
        guard let pp = playerPosition else { return nil }
        var tileTransformation: [TileTransformation] = []
        
        let otherOffers: [StoreOffer] = tiles(where: { tileType in
            if case TileType.offer = tileType {
                return true
            }
            return false
        }).compactMap {
            tiles[$0].type.offer
        }
        
        // get the random item or rune
        let randomItemOrRune = level.randomItemOrRune(offersOnBoard: otherOffers)
        tileTransformation.append(.init(pp, pp))
        
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles, offers: [randomItemOrRune])
    }
    
    func useLiquifyMonsters(input: Input, offer: StoreOffer) -> Transformation {
        var newTiles = tiles
        var tileTransformation: [TileTransformation] = []
        
        /// find all monsters
        let monsterTilecoords = tiles(where: { tileType in
            if case TileType.monster = tileType {
                return true
            }
            return false
        })
        
        // choose x randomly
        let chosenCoords = monsterTilecoords.choose(random: offer.type.numberOfTargets)
        
        for coord in chosenCoords {
            let randomColor = ShiftShaft_Color.randomColor
            let newItem = Item(type: .gem, amount: offer.type.effectAmount, color: randomColor)
            let newTile = Tile(type: .item(newItem))
            
            newTiles[coord.row][coord.col] = newTile
            tileTransformation.append(.init(coord, coord))
        }
        
        
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles)
    }
    
    func useSnakeEyes(input: Input) -> Transformation {
        guard let pp = playerPosition, case TileType.player(let playerData) = tiles[pp].type else {
            return Transformation(transformation: [], inputType: input.type, endTiles: self.tiles)
        }
        
        var newTiles = tiles
        var tileTransformations: [TileTransformation] = []
        
        // get the other coords
        let otherOfferTiles: [(Tile, TileCoord)] = tiles(where: { tileType in
            if case TileType.offer = tileType {
                return true
            }
            return false
        }).map { [tiles] in
            (tiles[$0.row][$0.col], $0)
        }
        
        // if there are other offer tiles (I cant think of asituation where there wouldnt be)
        // then replace them
        if !otherOfferTiles.isEmpty {
            let newOffers = level.rerollOffersForLevel(level, playerData: playerData)
            
            for tierIndex in 1...2 {
                let tierOffers = newOffers.filter({ $0.tier == tierIndex })
                let currentTierOfferings = otherOfferTiles.filter({ offerTile in
                    if case TileType.offer(let offer) = offerTile.0.type {
                        return offer.tier == tierIndex
                    }
                    return false
                    
                })
                
                // replace first tier offers
                if tierOffers.count == currentTierOfferings.count {
                    for idx in 0..<tierOffers.count {
                        let currentOfferingCoord = currentTierOfferings[idx].1
                        newTiles[currentOfferingCoord.row][currentOfferingCoord.col] = Tile(type: .offer(tierOffers[idx]))
                        tileTransformations.append(.init(currentOfferingCoord, currentOfferingCoord))
                    }
                }
            }
        }
        
        
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformations, inputType: input.type, endTiles: self.tiles)
        
    }
    
    func useInfusion(input: Input) -> Transformation {
        guard let pp = playerPosition else {
            fatalError()
        }
        var newTiles = tiles
        var tileTransformation: [TileTransformation] = []
        
        
        
        // TODO: model this somewhere
        let infusionRange: ClosedRange<CGFloat> = 0...2
        
        let reservedCoords = reservedCoords()
        
        // grab a random rock nearby
        let nearbyTargetCoord = randomCoord(in: tiles, notIn: reservedCoords, nearby: pp, in: infusionRange, specificTypeChecker: { $0.isARock })
        
        let oldTile = tiles[nearbyTargetCoord]
        // safely ignore holdsGem because reserved coords doesnt allow us to target a rock with a gem in it
        if case TileType.rock(color: let color, holdsGem: _, groupCount: let groupCount) = oldTile.type {
            newTiles[nearbyTargetCoord.row][nearbyTargetCoord.col] = Tile(type: .rock(color: color, holdsGem: true, groupCount: groupCount))
            
            tileTransformation.append(.init(nearbyTargetCoord, nearbyTargetCoord))
        } else {
            preconditionFailure("The chosen coord must be a rock!")
        }
        
        
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles)
        
    }
    
    
    func useGemMagnet(input: Input) -> Transformation {
        var newTiles = tiles
        var tileTransformation: [TileTransformation] = []
        var collectGemCount: Int = 0
        
        
        /// move all gems to the player
        for coord in tileCoords(for: tiles, of: [.gem]) {
            if case TileType.item(let item) = tiles[coord].type {
                let startCoord = coord
                let endCoord = playerCoord
                
                tileTransformation.append(TileTransformation(startCoord, endCoord))
                
                newTiles[startCoord.row][startCoord.col] = .empty
                
                collectGemCount += item.amount
            }
        }
        
        // update the player carry to reflec thte new gems
        if case TileType.player(let playerData) = newTiles[playerCoord].type {
            newTiles[playerCoord.row][playerCoord.col] = Tile(type: .player(playerData.earn(amount: collectGemCount)))
        }
        
        
        // update our tile storage
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: newTiles)
        
    }
    
    private func useDeathPotion(input: Input) -> Transformation {
        var newTiles = tiles
        var tileTransformation: [TileTransformation] = []
        var monstersKilled: [MonsterDies] = []
        
        let monsterCoords = tiles { tileType in
            if case TileType.monster = tileType {
                return true
            } else {
                return false
            }
        }
        
        for coord in monsterCoords {
            newTiles[coord.row][coord.col] = .empty
            tileTransformation.append(.init(coord, coord))
            monstersKilled.append(.init(tileType: tiles[coord].type, tileCoord: coord, deathType: .player))
        }
        
        
        self.tiles = newTiles
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles, monstersDies: monstersKilled)
    }

    
    private func useTransmogrify(offer: StoreOffer, input: Input) -> Transformation {
        guard let pp = playerPosition else {
            return Transformation(transformation: [], inputType: input.type, endTiles: self.tiles)
        }
        var newTiles = tiles
        var tileTransformation: [TileTransformation] = []
        
        // TODO: model this somewhere
        let transmogrifyRange: ClosedRange<CGFloat> = 0...2
        
        let reservedCoords = reservedCoords()
        
        // grab a random rock nearby
        let nearbyTargetCoord = randomCoord(in: tiles, notIn: reservedCoords, nearby: pp, in: transmogrifyRange, specificTypeChecker: { $0.isARock })
        
        /// they got lucky - get gems
        if (Bool.random()) {
            let randomColor = ShiftShaft_Color.randomColor
            let item = Item(type: .gem, amount: offer.type.effectAmount, color: randomColor)
            
            // update the tile storage
            newTiles[nearbyTargetCoord.row][nearbyTargetCoord.col] = Tile(type: .item(item))
            tileTransformation.append(.init(nearbyTargetCoord, nearbyTargetCoord))
        }
        /// the got unlucky, random monster
        else {
            let newMonster = tileCreator.randomMonster()
            
            // update the tile storage
            newTiles[nearbyTargetCoord.row][nearbyTargetCoord.column] = Tile(type: newMonster)
            tileTransformation.append(.init(nearbyTargetCoord, nearbyTargetCoord))
        }
        
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: self.tiles)
    }

    
}

//MARK: - Use Rune

extension Board {
    
    private func useRune(_ rune: Rune, on allTargets: AllTarget, input: Input) -> [Transformation] {
        guard let playerData = playerEntityData,
              let pp = playerPosition else {
                  /// no update for the player is needed
                  preconditionFailure("Failed")
              }
        
        /// by doing this we have recorded the progress of the runes.
        let updatedPlayer = playerData.useRune(rune)
        tiles[pp.row][pp.column] = Tile(type: .player(updatedPlayer))
        
        let targets = allTargets.allTargetAssociatedCoords
        switch rune.type {
        case .rainEmbers, .fireball:
            return [removeAndReplaces(from: tiles, specificCoord: targets, input: input, monsterDeathType: .rune)]
            
        case .getSwifty:
            guard let firstTarget = targets.first, targets.count == 2 else {
                return [Transformation(transformation: nil, inputType: input.type, endTiles: tiles)]
            }
            return [swap(firstTarget, with: targets.last!, input: input)]
            
        case .transformRock:
            return [transform(targets, into: TileType.rock(color: .purple, holdsGem: false, groupCount: 0), input: input)]
        case .bubbleUp:
            return [bubbleUp(targets.first!, input: input)]
        case .flameWall, .flameColumn:
            return [flameLine(tiles: tiles, targets: targets, input: input)]
        case .vortex:
            return [vortex(tiles: tiles, targets: targets, input: input)]
            
        case .drillDown:
            return drillDown(allTarget: allTargets, input: input)
            
        case .fieryRage:
            return fieryRage(allTarget: allTargets, input: input)
            
        case .teleportation, .debugTeleport:
            return [teleportation(tiles: tiles, allTargets: allTargets, input: input)]
            
        case .moveEarth:
            return [moveEarth(tiles: tiles, allTargets: allTargets, input: input)]
            
        case .monsterCrush:
            return [monsterCrush(tiles: tiles, allTarget: allTargets, input: input)]
            
        default: fatalError()
        }
        
    }
    
    private func transform(_ coords: [TileCoord], into type: TileType, input: Input) -> Transformation {
        
        var tileTransform : [TileTransformation] = []
        for tile in coords {
            tiles[tile.row][tile.column] = Tile(type: type)
            tileTransform.append(TileTransformation(tile, tile))
        }
        
        return Transformation(transformation: tileTransform, inputType: input.type, endTiles: tiles)
        
    }
    
    
    private func swap(_ first: TileCoord, with second: TileCoord, input: Input) -> Transformation {
        
        let tempTile = tiles[first]
        tiles[first.row][first.column] = tiles[second.row][second.column]
        tiles[second.row][second.column] = tempTile
        let tileTransformation = [TileTransformation(first, second), TileTransformation(second, first)]
        return Transformation(transformation: tileTransformation, inputType: input.type, endTiles: tiles)
        
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
            return Transformation(transformation: nil, inputType: input.type, endTiles: tiles)
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
        return Transformation(transformation: transformation, inputType: input.type, endTiles: newTiles)
    }
    
        
    private func fieryRage(allTarget: AllTarget, input: Input) -> [Transformation] {
        // destroy any monsters that are within the the effected tile coords
        
        var newTiles = tiles
        let playerCoord = playerCoord
        
        var minLeftCoord: TileCoord = playerCoord
        var maxRightCoord: TileCoord = playerCoord
        var maxTopCoord: TileCoord = playerCoord
        var minBottomCoord: TileCoord = playerCoord
        var monstersKilled: [MonsterDies] = []
        
        // gets the most left, right, top and bottom coords
        // also kills each monster
        for tileCoord in allTarget.allTargetAssociatedCoords {
            if tileCoord.row == playerCoord.row {
                // set the min left or max right potential
                if tileCoord.col < minLeftCoord.col {
                    minLeftCoord = tileCoord
                } else if tileCoord.col > maxRightCoord.col {
                    maxRightCoord = tileCoord
                }
            } else if tileCoord.col == playerCoord.col {
                if tileCoord.row < minBottomCoord.row {
                    minBottomCoord = tileCoord
                } else if tileCoord.row > maxTopCoord.row {
                    maxTopCoord = tileCoord
                }
            }
            
            if case TileType.monster = tiles[tileCoord].type {
                monstersKilled.append(.init(tileType: tiles[tileCoord].type, tileCoord: tileCoord, deathType: .rune))
                newTiles[tileCoord.row][tileCoord.col] = .empty
            }
        }
        
        self.tiles = newTiles
        
        let tileTransformations = [minLeftCoord, maxRightCoord, minBottomCoord, maxTopCoord]
            .filter { $0 != playerCoord }
            .map { TileTransformation($0, $0) }
        
        let trans = Transformation(transformation: tileTransformations, inputType: input.type, endTiles: self.tiles, monstersDies: monstersKilled.isEmpty ? nil : monstersKilled)
        
        return [trans]
        
    }
    
    private func drillDown(allTarget: AllTarget, input: Input) -> [Transformation] {
        guard let playerData = playerData(in: tiles) else { return [Transformation(transformation: nil, inputType: input.type, endTiles: tiles)] }
        var tileTransformation: [TileTransformation] = []
        var newTiles = tiles
        
        // get the affected tile coords
        let affectedTiles = allTarget
            .targets
            .flatMap { $0.associatedCoord }
            .sorted { firstCoord, secondCoord in
                return firstCoord.row > secondCoord.row
            }
        // keep track of which tiles have been transformed upon
        // only destroy monsters and rocks
        var tilesToBeDestroyed: [TileCoord] = []
        var monstersKilled: [MonsterDies] = []
        var stoppedByNonDestructible = false
        for coord in affectedTiles {
            if !stoppedByNonDestructible {
                switch tiles[coord].type {
                case .monster:
                    monstersKilled.append(.init(tileType: tiles[coord].type, tileCoord: coord, deathType: .rune))
                    tilesToBeDestroyed.append(coord)
                    newTiles[coord.row][coord.col] = .empty
                case .rock:
                    tilesToBeDestroyed.append(coord)
                    newTiles[coord.row][coord.col] = .empty
                case .gem, .dynamite, .exit, .item, .pillar, .offer:
                    stoppedByNonDestructible = true
                default:
                    break
                }
            }
        }
        
        guard !tilesToBeDestroyed.isEmpty,
              let minCoord = tilesToBeDestroyed.min(by: { $0.row < $1.row }) else {
                  return [Transformation(transformation: nil, inputType: input.type, endTiles: tiles)]
              }
        
        
        // the player will fall from their original coord to the lowest coord of the tiles that were destroyed
        tileTransformation.append(TileTransformation(playerCoord, minCoord))
        
        newTiles[playerCoord.row][playerCoord.col] = Tile(type: .empty)
        newTiles[minCoord.row][minCoord.col] = Tile(type: .player(playerData))
        self.tiles = newTiles
        
        let trans = Transformation(transformation: tileTransformation, inputType: input.type, endTiles: tiles, monstersDies: monstersKilled.isEmpty ? nil : monstersKilled)
        
        
        // return an array of transformations
        return [
            trans
        ]
    }
    
    private func flameLine(tiles:  [[Tile]], targets: [TileCoord], input: Input) -> Transformation {
        var newTiles = tiles
        
        var affectedTiles: [TileTransformation] = []
        var monstersKilled: [MonsterDies] = []
        for coord in targets {
            if case TileType.monster = tiles[coord].type {
                newTiles[coord.row][coord.column] = .empty
                monstersKilled.append(.init(tileType: tiles[coord].type, tileCoord: coord, deathType: .rune))
            }
            affectedTiles.append(TileTransformation(coord, coord))
        }
        
        self.tiles = newTiles
        
        /// create a "dummy" transformation because apparently we ignore things unless there is a
        return Transformation(transformation: affectedTiles, inputType: input.type, endTiles: newTiles, monstersDies: monstersKilled.isEmpty ? nil: monstersKilled)
        
    }
    
    private func vortex(tiles:  [[Tile]], targets: [TileCoord], input: Input) -> Transformation {
        guard let playerData = playerData(in: tiles) else { return Transformation(transformation: nil, inputType: input.type, endTiles: tiles) }
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
        return Transformation(transformation: [TileTransformation(.zero, .zero)], inputType: input.type, endTiles: newTiles)
    }
    
    private func teleportation(tiles: [[Tile]], allTargets: AllTarget, input: Input) -> Transformation {
        guard allTargets.allTargetCoords.count == 2, let first = allTargets.allTargetCoords.first, let second = allTargets.allTargetCoords.last else {
            return Transformation(transformation: nil, inputType: input.type, endTiles: tiles)
        }
        var newTiles = tiles
        
        let tempTile = tiles[first]
        newTiles[first.x][first.y] = newTiles[second.x][second.y]
        newTiles[second.x][second.y] = tempTile
        
        let tileTrans = [TileTransformation(first, second), TileTransformation(second, first)]
        
        self.tiles = newTiles
        return Transformation(transformation: tileTrans, inputType: input.type, endTiles: self.tiles)
    }
    
    private func moveEarth(tiles: [[Tile]], allTargets: AllTarget, input: Input) -> Transformation {
        guard allTargets.allTargetCoords.count == 2,
              let firstRow = allTargets.allTargetCoords.first,
              let secondRow = allTargets.allTargetCoords.last else {
                  return Transformation(transformation: nil, inputType: input.type, endTiles: tiles)
              }
        var newTiles = tiles
        var tileTransformations: [TileTransformation] = []
        
        let tempRow = tiles[firstRow.x]
        
        // move all tiles from the second row to the first row
        for (column, tile) in tiles[secondRow.row].enumerated() {
            newTiles[firstRow.x][column] = tile
            tileTransformations.append(.init(.init(secondRow.row, column), .init(firstRow.row, column)))
        }
        
        // move the tempTiles from the firstrow to the second row
        for (column, tile) in tempRow.enumerated() {
            newTiles[secondRow.x][column] = tile
            tileTransformations.append(.init(.init(firstRow.row, column), .init(secondRow.row, column)))
        }
        
        self.tiles = newTiles
        
        return Transformation(transformation: tileTransformations, inputType: input.type, endTiles: self.tiles)
    }
    
    private func monsterCrush(tiles: [[Tile]], allTarget: AllTarget, input: Input) -> Transformation {
        let transformation = removeAndReplace(from: tiles, tileCoord: allTarget.targets.first!.coord, input: input, killMonsters: true, monsterDeathType: .rune)
        return transformation
    }
    
    private func monsterBrawl(tiles: [[Tile]], allTarget: AllTarget, input: Input) -> Transformation {
        fatalError("Implement")
    }
}

// MARK: - Find Neighbors Remove and Replace

extension Board {
    
    /// Return true if a neighbor coord is within the bounds of the board
    /// within one tile in a cardinal direction of the currCoord
    /// and not equal to the currCoord
    func valid(neighbor: TileCoord?, for currCoord: TileCoord?) -> Bool {
        return Shift_Shaft.valid(neighbor: neighbor, for: currCoord, boardSize: boardSize)
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
    
    
    func findNeighborsForBoard(in tiles: [[Tile]]) -> [[Int]] {
        // special value -1 to indicate we havent checked this spot yet
        let innerNeighbors = Array(repeating: -1, count: tiles.count)
        var neighbors = Array(repeating: innerNeighbors, count: tiles.count)
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                // skip coords we have already tested
                if (neighbors[row][col] == -1) {
                    let foundNeighbors = findNeighbors(in: tiles, of: TileCoord(row, col)).0
                    for coord in foundNeighbors {
                        neighbors[coord.row][coord.column] = foundNeighbors.count
                    }
                }
            }
        }
        
        return neighbors
    }
    
    /// Find all contiguous neighbors of the same color as the tile that was tapped
    func findNeighbors(in tiles: [[Tile]], of coord: TileCoord, killMonsters: Bool = false) -> ([TileCoord], [TileCoord]) {
        return Shift_Shaft.findNeighbors(in: tiles, of: coord, boardSize: boardSize, killMonsters: killMonsters)
    }
    
    /// Find all contiguous neighbors of the same color as the tile that was tapped
    /// Calls another function that finds neighbors on our current set of tiles.
    func findNeighbors(_ coord: TileCoord, killMonsters: Bool = false) -> ([TileCoord], [TileCoord]) {
        return findNeighbors(in: self.tiles, of: coord, killMonsters: killMonsters)
    }
    
    // MARK: Destroy all rocks of one color
    func massMine(tiles: [[Tile]], color: ShiftShaft_Color, input: Input) -> Transformation {
        var selectedCoords: [TileCoord] = []
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if case TileType.rock(let tileColor, _, _) = tiles[row][col].type,
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
        return Transformation(transformation: selectedTilesTransformation,
                              inputType: input.type,
                              endTiles: intermediateTiles,
                              removed: selectedTilesTransformation,
                              newTiles: newTiles,
                              shiftDown: shiftDown
        )
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
                          killMonsters: Bool = false,
                          forceMonsterSpawn: Bool = false,
                          monsterWasKilled: Bool = false,
                          monsterDeathType: MonsterDeathType? = nil
    ) -> Transformation {
        // Check that the tile group at row, col has more than 3 tiles
        var selectedTiles: [TileCoord] = [tileCoord]
        var selectedPillars: [TileCoord] = []
        if !singleTile {
            (selectedTiles, selectedPillars) = findNeighbors(tileCoord, killMonsters: killMonsters)
            if selectedTiles.count < 3 {
                return Transformation(transformation: selectedTiles.map { TileTransformation($0, $0) },
                                      inputType: input.type,
                                      endTiles: tiles)
            }
        }
        
        var newTiles : [TileTransformation] = []
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        var monstersKilled: [MonsterDies] = []
        
        var finalSelectedTiles: [TileCoord] = []
        var removedTilesContainGem = false
        for coord in selectedTiles {
            // turn the tile into a gem or into an empty
            if case TileType.rock(let color, let holdsGem, _) = tiles[coord].type, holdsGem {
                intermediateTiles[coord.x][coord.y] = Tile(type: .emptyGem(color, amount: numberOfGemsForGroup(size: selectedTiles.count)))
                removedTilesContainGem = holdsGem
            } else if case TileType.monster = tiles[coord].type,
                      let deathType = monsterDeathType {
                // remove the tile
                intermediateTiles[coord.x][coord.y] = .empty
                // keep track of monsters killed
                monstersKilled.append(.init(tileType: tiles[coord].type, tileCoord: coord, deathType: deathType))
            }
            else {
                intermediateTiles[coord.x][coord.y] = .empty
            }
            
            finalSelectedTiles.append(coord)
        }
        
        // decrement the health of each pillar
        var pillarsThatTakeDamage: [PillarTakesDamage] = []
        for pillarCoord in selectedPillars {
            if case let .pillar(data) = intermediateTiles[pillarCoord.x][pillarCoord.y].type {
                pillarsThatTakeDamage.append(.init(tileType: TileType.pillar(data), tileCoord: pillarCoord))
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
                    intermediateTiles: &intermediateTiles,
                    forceMonsterSpawn: forceMonsterSpawn,
                    monsterWasKilled: monsterWasKilled
        )
        
        //create selectedTilesTransformation array
        let selectedTilesTransformation = finalSelectedTiles.map { TileTransformation($0, $0) }
        
        //update our store of tilesftiles
        self.tiles = intermediateTiles
        
        // return our new board
        return Transformation(transformation: selectedTilesTransformation,
                              inputType: input.type,
                              endTiles: self.tiles,
                              removed: selectedTilesTransformation,
                              newTiles: newTiles,
                              shiftDown: shiftDown,
                              removedTilesContainGem: removedTilesContainGem,
                              monstersDies: monstersKilled.isEmpty ? nil : monstersKilled,
                              pillarsTakeDamage: pillarsThatTakeDamage.isEmpty ? nil : pillarsThatTakeDamage
        )
    }
    
    func removeAndReplaces(from tiles: [[Tile]],
                           specificCoord: [TileCoord],
                           singleTile: Bool = false,
                           input: Input,
                           forceSpawnMonsters: Bool = false,
                           destroysGemsInRocks: Bool = false,
                           monsterDeathType: MonsterDeathType? = nil) -> Transformation {
        
        let selectedTiles: [TileCoord] = specificCoord
        
        // set the tiles to be removed as Empty placeholder
        var intermediateTiles = tiles
        var monstersKilled: [MonsterDies] = []
        var pillarsThatTakeDamage: [PillarTakesDamage] = []
        var removedTilesContainGem = false
        for coord in selectedTiles {
            switch tiles[coord].type {
            case let .pillar(data):
                pillarsThatTakeDamage.append(.init(tileType: .pillar(data), tileCoord: coord))
                if data.health == 1 {
                    // remove the pillar from the board
                    intermediateTiles[coord.x][coord.y] = Tile.empty
                } else {
                    //decrement the pillar's health
                    intermediateTiles[coord.x][coord.y] = Tile(type: .pillar(PillarData(color: data.color, health: data.health-1)))
                }
                
            case .rock(color: _, holdsGem: let holdsGem, _):
                intermediateTiles[coord.x][coord.y] = Tile.empty
                if !removedTilesContainGem && !destroysGemsInRocks {
                    removedTilesContainGem = holdsGem
                }
            case .dynamite(let fuse):
                if fuse.count <= 0 {
                    intermediateTiles[coord.x][coord.y] = Tile.empty
                }
            case .monster:
                if let monsterDeathType = monsterDeathType {
                    monstersKilled.append(.init(tileType: tiles[coord].type, tileCoord: coord, deathType: monsterDeathType))
                }
                intermediateTiles[coord.x][coord.y] = Tile.empty
                
            case .offer, .gem, .empty:
                intermediateTiles[coord.x][coord.y] = Tile.empty
            default:
                preconditionFailure("We should only use this for rocks, pillars and monsters. Dynamite adds a few more items to the list including gems.")
            }
        }
        
        // store tile transforamtions and shift information
        var newTiles : [TileTransformation] = []
        var (shiftDown, shiftIndices) = calculateShiftIndices(for: &intermediateTiles)
        
        //add new tiles
        addNewTiles(shiftIndices: shiftIndices,
                    shiftDown: &shiftDown,
                    newTiles: &newTiles,
                    intermediateTiles: &intermediateTiles,
                    forceMonsterSpawn: forceSpawnMonsters)
        
        //create selectedTilesTransformation array
        let selectedTilesTransformation = selectedTiles.map { TileTransformation($0, $0) }
        
        
        //update our store of tilesftiles
        self.tiles = intermediateTiles
        
        // return our new board
        return Transformation(transformation: selectedTilesTransformation,
                              inputType: input.type,
                              endTiles: self.tiles,
                              removed: selectedTilesTransformation,
                              newTiles: newTiles,
                              shiftDown: shiftDown,
                              removedTilesContainGem: removedTilesContainGem,
                              monstersDies: monstersKilled.isEmpty ? nil : monstersKilled,
                              pillarsTakeDamage: pillarsThatTakeDamage.isEmpty ? nil : pillarsThatTakeDamage
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
                    
                    if case let .dynamite(data) = tiles[i][j].type, newTurn {
                        newTiles[i][j] = Tile(type: .dynamite(DynamiteFuse(count: data.count, hasBeenDecremented: false)))
                    }
                }
            }
            return newTiles
        }
        
        
        GameLogger.shared.log(prefix: "Board", message: "Resetting attacks.  New turn? \(newTurn)")
        
        tiles = resetAttacks(in: tiles)
        
        return Transformation(transformation: nil,
                              inputType: .reffingFinished(newTurn: newTurn),
                              endTiles: tiles
        )
        
        
    }
    
    /// This is for collectin gems
    private func collectItem(at coord: TileCoord, input: Input) -> Transformation {
        let selectedTile = tiles[coord]
        
        //remove and replace the single item tile
        let transformation = removeAndReplace(from: tiles, tileCoord: coord, singleTile: true, input: input, forceMonsterSpawn: shouldSpawnMonsterDuringTutorial)
        hasAlreadySpawnedMonsterForTutorial = true
        
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
                              endTiles: tiles,
                              removed: transformation.tileTransformation,
                              newTiles: transformation.newTiles,
                              shiftDown: transformation.shiftDown)
    }
    
    
    private func monsterDied(at coord: TileCoord, input: Input) -> Transformation {
        // When a monster dies, the player should reset the attack
        // This isnt fool proof if we , but for the most part this will work
        // This may lead to bugs if we introduce another way that players can attack
        // But basically we should only reset attacks if the monster died directly from a player attack
        
        guard let pp = playerPosition,
              case let .player(data) = tiles[pp].type,
              case let InputType.monsterDies(_, _, deathType: deathType) = input.type
        else { return Transformation.zero }
        
        var newTiles = tiles
        newTiles[pp.row][pp.column] = Tile(type: .player(data.update(attack: data.attack.resetAttack())))
        return removeAndReplace(from: newTiles, tileCoord: coord, singleTile: true, input: input, monsterWasKilled: true, monsterDeathType: deathType)
        
    }
    
    private func addNewTiles(shiftIndices: [Int],
                             shiftDown: inout [TileTransformation],
                             newTiles: inout [TileTransformation],
                             intermediateTiles: inout [[Tile]],
                             forceMonsterSpawn: Bool = false,
                             monsterWasKilled: Bool = false
    ) {
        // Intermediate tiles is the "in-between" board that has shifted down
        // tiles into and replaced the shifted down tiles with empty tiles
        // the tile creator replaces empty tiles with new tiles
        let createdTiles: [[Tile]] = tileCreator.tiles(for: intermediateTiles, forceMonster: forceMonsterSpawn, monsterWasKilled: monsterWasKilled)
        
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

// MARK: - Shuffle

extension Board {
    var playerCoord: TileCoord {
        return tileCoords(for: tiles, of: .player(.zero)).first!
    }
    
    func shuffleBoard(input: Input, pay2Hearts: Bool, pay25PercentGems: Bool) -> [Transformation] {
        
        // Move rocks around
        // Do not move the player
        // Do not move pillars
        // Do not move the exit
        // Move offers closer to the player?
        // Move gems closer to the player
        // Kill 33% of the monsters on the board, rounded up
        // Remove and replace those tiles
        
        
        var boardHasMoves = false
        var intermediateTiles = self.tiles
        var tileTransformations: [TileTransformation] = []
        var count = 0
        var randomMonsterCoords: [TileCoord] = []
        
        while !boardHasMoves {
            print("$$$ Board has more moves checking loop: \(count)")
            count += 1
            /// this is a loop so we need to set or reset local variables to properly find a solution
            let playerCoord = playerCoord
            var monsterCoords: [TileCoord] = []
            var reserved = shuffleReserved()
            tileTransformations.removeAll()
            
            for row in 0..<self.tiles.count {
                for col in 0..<self.tiles[row].count {
                    let tileCoord = TileCoord(row, col)
                    let tile = tiles[tileCoord]
                    
                    switch tile.type {
                    case .rock:
                        let newCoord = randomCoord(in: tiles, notIn: reserved)
                        intermediateTiles[newCoord.row][newCoord.col] = tile
                        reserved.insert(newCoord)
                        tileTransformations.append(TileTransformation(tileCoord, newCoord))
                        
                    case .monster:
                        monsterCoords.append(tileCoord)
                        
                    case .item, .offer:
                        let range = (CGFloat(1)...CGFloat(3))
                        let newCoord = randomCoord(in: tiles, notIn: reserved, nearby: playerCoord, in: range)
                        intermediateTiles[newCoord.row][newCoord.col] = tile
                        reserved.insert(newCoord)
                        tileTransformations.append(TileTransformation(tileCoord, newCoord))
                        
                    case .player(let data):
                        let newData: EntityModel
                        if pay2Hearts {
                            newData = data.wasAttacked(for: 2, from: .east)
                        } else {
                            let twentyFivePercent = Double(data.carry.totalGem) * 0.25
                            newData = data.spend(amount: Int(twentyFivePercent))
                        }
                        
                        let newTile = Tile(type: .player(newData))
                        intermediateTiles[tileCoord.row][tileCoord.col] = newTile
                        
                    case .pillar, .exit, .empty, .emptyGem, .dynamite:
                        break
                    }
                    
                }
            }
            
            randomMonsterCoords = monsterCoords.choose(random: monsterCoords.count/2)
            intermediateTiles = calculateNeighbors(for: intermediateTiles)
            boardHasMoves = boardHasMoreMoves(tiles: intermediateTiles)
        }
        
        self.tiles = intermediateTiles
        
        let shuffleTransformation = Transformation(transformation: tileTransformations, inputType: input.type, endTiles: self.tiles)
        
        let removeMonstersAndReplace = removeAndReplaces(from: self.tiles, specificCoord: randomMonsterCoords, input: input, monsterDeathType: .mineralSpirits)
        
        return [shuffleTransformation, removeMonstersAndReplace]
        
    }
    
    private func shuffleReserved() -> Set<TileCoord> {
        var tileCoords: [TileCoord] = []
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                switch tiles[i][j].type {
                case .exit, .pillar, .player, .monster:
                    tileCoords.append(TileCoord(i, j))
                default:
                    continue
                }
            }
        }
        return Set<TileCoord>(tileCoords)
    }
}

// MARK: - Factory

extension Board {
    static func build(tileCreator: TileStrategy,
                      difficulty: Difficulty,
                      level: Level,
                      tutorialConductor: TutorialConductor?) -> Board {
        //create a boardful of tiles
        let (tiles, newLevel) = tileCreator.board(difficulty: difficulty)
        
        //init new board
        return Board(tileCreator: tileCreator, tiles: tiles, level: level, boardLoaded: !newLevel, tutorialConductor: tutorialConductor)
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
        
        if tileCoords(for: self.tiles, of: .empty).count > 0 {
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
            return Transformation(transformation: newTiles,
                                  inputType: inputType,
                                  endTiles: self.tiles,
                                  newTiles: newTiles,
                                  shiftDown: shiftDown)
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
        
        allTransformations.append(Transformation(transformation: transformation,
                                                 inputType: inputType,
                                                 endTiles: intermediateTiles))
        
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
              isWithinBounds(playerPosition.rowBelow), case TileType.player(let data) = tiles[playerPosition].type else {
                  return Transformation(transformation: [], inputType: .gameWin(0))
              }
        
        var newTiles = tiles
        newTiles[playerPosition.row][playerPosition.column] = Tile(type: .player(data))
        
        self.tiles = newTiles
        
        
        return Transformation(transformation: [TileTransformation(playerPosition, playerPosition.rowBelow)],
                              inputType: .gameWin(self.level.goalProgress.count),
                              endTiles: self.tiles)
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
    
    func tiles(where comparator: (TileType) -> Bool) -> [TileCoord] {
        var tileCoords: [TileCoord] = []
        for (i, _) in tiles.enumerated() {
            for (j, _) in tiles[i].enumerated() {
                comparator(tiles[i][j].type) ? tileCoords.append(TileCoord(i, j)) : ()
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
                                    _, _) = input.type else {
            return Transformation.zero
        }
        var attacker: EntityModel
        var defender: EntityModel
        var dodged = false
        var attackerIsPlayer = false
        var pillarsThatTakeDamage: [PillarTakesDamage] = []
        
        
        //TODO: DRY, extract and shorten this code
        if let defenderPosition = defenderPostion,
           case let .player(playerModel) = tiles[attackerPosition].type,
           case let .monster(monsterModel) = tiles[defenderPosition].type,
           let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = playerModel
            defender = monsterModel
            
            var (newAttackerData, newDefenderData, defenderDodged) = CombatSimulator.simulate(attacker: attacker,
                                                                                              defender: defender,
                                                                                              attacked: relativeAttackDirection)
            
            // keep track of what killed us
            if newDefenderData.isDead {
                newDefenderData = newDefenderData.update(killedBy: attacker.type)
            }
            
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.player(newAttackerData))
            tiles[defenderPosition.x][defenderPosition.y] = Tile(type: TileType.monster(newDefenderData))
            
            dodged = defenderDodged
            attackerIsPlayer = true
            
            
        } else if let defenderPosition = defenderPostion,
                  case let .player(playerModel) = tiles[defenderPosition].type,
                  case let .monster(monsterModel) = tiles[attackerPosition].type,
                  let relativeAttackDirection = defenderPosition.direction(relative: attackerPosition) {
            
            attacker = monsterModel
            defender = playerModel
            
            var (newAttackerData, newDefenderData, defenderDodged) = CombatSimulator.simulate(attacker: attacker,
                                                                                              defender: defender,
                                                                                              attacked: relativeAttackDirection)
            
            // keep track of what killed us
            if newDefenderData.isDead {
                newDefenderData = newDefenderData.update(killedBy: monsterModel.type)
            }
            
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
            pillarsThatTakeDamage.append(.init(tileType: .pillar(data), tileCoord: defenderPosition))
            
            /// I purposefully hid some monsters in the Pillars in the boss level.  I think it better if they dont destroy the pillars they are trapped in
            /// I have been a mistake so ill just leave this code in here
            //            if data.health == 1 {
            //                tiles[defenderPosition.x][defenderPosition.y] = Tile.empty
            //            } else {
            //                tiles[defenderPosition.x][defenderPosition.y] = Tile(type: .pillar(PillarData(color: data.color, health: data.health - 1)))
            //
            //            }
        } else if case let .monster(monsterModel) = tiles[attackerPosition].type,
                  defenderPostion == nil {
            //just note that the monster attacked
            tiles[attackerPosition.x][attackerPosition.y] = Tile(type: TileType.monster(monsterModel.didAttack()))
        }
        self.tiles = tiles
        return Transformation(inputType: InputType.attack(attackType: type,
                                                          attacker: attackerPosition,
                                                          defender: defenderPostion,
                                                          affectedTiles: affectedTiles,
                                                          dodged: dodged,
                                                          attackerIsPlayer: attackerIsPlayer
                                                         ),
                              endTiles: self.tiles,
                              pillarsTakeDamage: pillarsThatTakeDamage.isEmpty ? nil : pillarsThatTakeDamage )
    }
}


fileprivate func numberOfGemsForGroup(size: Int) -> Int {
    let numberPerRock = numberOfGemsPerRockForGroup(size: size)
    return numberPerRock * size
}

func numberOfGemsPerRockForGroup(size: Int) -> Int {
    if (1...9).contains(size) {
        return 1
    } else if (10...29).contains(size) {
        return 2
    } else if (30...Int.max).contains(size) {
        return 3
    }
    return 0
}

