//
//  TargetingViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics


class TargetingViewModel: Targeting {
    
    // MARK: - Outputs that the Backpack hooks up to
    public var updateCallback: (() -> Void)?
    public var runeSlotsUpdated: ((Int, [Rune]) -> Void)?
    
    /// publishers that the Backpack hooks up to
    private var foundRuneDiscardedSubject = PassthroughSubject<(), Never>()
    var foundRuneDiscardedPublisher: AnyPublisher<(), Never> {
        return foundRuneDiscardedSubject.eraseToAnyPublisher()
    }
    
    var runeReplacementSubject = PassthroughSubject<(Pickaxe, Rune, Bool), Never>()
    var runeReplacementPublisher: AnyPublisher<(Pickaxe, Rune, Bool), Never> {
        return runeReplacementSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Normal variables
    
    private var runeSlots: Int = 0
    var inventory: [Rune] = []
    var boardSize: Int = 0
    
    
    // MARK: - Computer variables
    var rune: Rune? {
        didSet {
            currentTargets = AllTarget(targets: [], areLegal: false)
            if let rune = rune {
                InputQueue.append(Input(InputType.runeUseSelected(rune)))
                autoTarget()
            }
            else {
                InputQueue.append(Input(InputType.runeUseCanceled))
            }
        }
    }
    
    var needsToTargetPlayer: Bool {
        rune?.targetTypes?.contains(.player(.playerZero)) ?? false
    }
    
    var playerCoord: TileCoord? {
        return tileCoords(for: tiles ?? [], of: .player(.playerZero)).first
    }
    
    var numberOfTargets: Int {
        return rune?.targets ?? 0
    }
    
    var typesOfTargets: [TileType] {
        return rune?.targetTypes ?? []
    }
    
    var nameMessage: String? {
        return rune?.type.humanReadable
    }
    
    var toastMessage: String {
        if rune == nil {
            return ""
        }
        let baseString = "Choose "
        
        //remove duplicates of human readable strings
        let typesOfTargetString = typesOfTargets.reduce([]) { (result, tileType) -> [String] in
            var newResult = result
            if !result.contains(tileType.humanReadable) {
                if case .monster = tileType {
                    newResult.append("monster")
                } else {
                    newResult.append(tileType.humanReadable)
                }
            }
            return newResult
        }
        
        // build the string of the types
        let types: String
        if typesOfTargetString.count == 0 {
            types = ""
        }
        else if typesOfTargetString.count == 1 {
            types = typesOfTargetString.first ?? ""
        } else if typesOfTargetString.count == 2 {
            types = "\(typesOfTargetString.first ?? "") and/or \(typesOfTargetString.last ?? "")"
        } else {
            var allButLastString = typesOfTargetString.dropLast().joined(separator: ", ")
            
            allButLastString.append(" and/or \(typesOfTargetString.last ?? "")")
            types = allButLastString
        }
        return baseString + "\(self.numberOfTargets) " + types + "\(self.numberOfTargets > 1 ? "s" : "")"
    }
    
    var currentTargets: AllTarget = AllTarget(targets: [], areLegal: false) {
        didSet {
            updateCallback?()
        }
    }
    
    
    var legallyTargeted: Bool {
        guard let rune = rune else { return false }
        return self.currentTargets.targets.allSatisfy({
            return $0.isLegal
        })
        && (self.currentTargets.targets.count == self.numberOfTargets || rune.targetAmountType == .upToAmount)
        && self.currentTargets.areLegal
    }
    
    
    private var tiles: [[Tile]]? = nil {
        didSet {
            autoTarget()
            updateCallback?()
        }
    }
    
    // MARK: - Init and public methods
    init() {
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input)
        }
    }
    
    public func didUse(_ rune: Rune?) {
        guard let rune = rune, legallyTargeted else {
            self.rune = nil
            return
        }
        
        InputQueue.append(
            Input(.runeUsed(rune, currentTargets))
        )
        
        self.rune = nil
        currentTargets = AllTarget(targets: [], areLegal: false)
        
    }
    
    public func didDeselect() {
        self.rune = nil
        currentTargets = AllTarget(targets: [], areLegal: false)
    }
    
    public func didSelect(_ rune: Rune?) {
        self.rune = rune
        if rune == nil {
            currentTargets = AllTarget(targets: [], areLegal: false)
        }
    }
    
    
    // MARK: - Private methods, mostly targeting logic
    private func handle(_ input: Input) {
        switch input.type {
        case .runeReplaced(let pickaxe, let replacedRune, _, _):
            let runes = pickaxe.runes.filter { $0.type != replacedRune.type }
            runeSlotsUpdated?(pickaxe.runeSlots, runes)
            
        case .foundRuneDiscarded:
            foundRuneDiscardedSubject.send(())
            
        case .runeReplacement(let pickaxe, let rune, let promptedByChest):
            runeReplacementSubject.send((pickaxe, rune, promptedByChest))
            
        case .transformation(let trans):
            if let inputType = trans.first?.inputType,
               case InputType.runeUsed = inputType,
               let endTiles = trans.first?.endTiles {
                if let playerData = playerData(in: endTiles),
                   let runes = playerData.runes,
                   let endTiles = input.endTilesStruct {
                    self.tiles = endTiles
                    let runeSlots = playerData.runeSlots ?? 0
                    self.runeSlots = runeSlots
                    inventory = playerData.runes ?? []
                    runeSlotsUpdated?(runeSlots, runes)
                }
                
            } else if let inputType = trans.first?.inputType,
                      case InputType.runeUseSelected = inputType {
                // skip these as well
            }
            else {
                /// clear out targets after any transformation
                currentTargets = AllTarget(targets: [], areLegal: false)
            }
        case .animationsFinished:
            if let endTiles = input.endTilesStruct {
                if let playerData = playerData(in: endTiles),
                   let runes = playerData.runes {
                    let runeSlots = playerData.runeSlots ?? 0
                    self.runeSlots = runeSlots
                    inventory = playerData.runes ?? []
                    runeSlotsUpdated?(runeSlots, runes)
                    
                }
            }
            
        case .newTurn:
            guard let tiles = input.endTilesStruct else { return }
            self.tiles = tiles
            
            if let playerData = playerData(in: tiles),
               let runes = playerData.runes {
                let runeSlots = playerData.runeSlots ?? 0
                self.runeSlots = runeSlots
                inventory = playerData.runes ?? []
                runeSlotsUpdated?(runeSlots, runes)
            }
            
            // this makes sure that the view looks right if the player taps on a rune during an animation
            self.didDeselect()
            
        case .boardBuilt, .boardLoaded:
            guard let tiles = input.endTilesStruct else { return }
            self.tiles = tiles
            boardSize = tiles.count
            
            if let playerData = playerData(in: tiles),
               let runes = playerData.runes {
                let runeSlots = playerData.runeSlots ?? 0
                self.runeSlots = runeSlots
                inventory = playerData.runes ?? []
                runeSlotsUpdated?(runeSlots, runes)
            }
            
        default:
            break
        }
        
    }
    
    private func areAllTargetsLegal(in allTarget: AllTarget) -> Bool {
        return areTargetsLegal(inCoords: allTarget.allTargetCoords)
    }
    
    private func areTargetsLegal(inTargets targets: [Target]) -> Bool {
        return areTargetsLegal(inCoords: targets.compactMap { $0.coord })
    }
    
    private func areTargetsLegal(inCoords coords: [TileCoord]) -> Bool {
        var hasPlayerTargeted = false
        for coord in coords {
            if !isTargetLegal(coord) {
                return false
            }
            if  coord == playerCoord {
                hasPlayerTargeted = true
            }
        }
        
        /// For some items we MUST target the player.
        /// If needsToTargetPlayer == false, then the player is not a legal target and we will continue past the guard
        /// If needsToTargetPlayer == true, then we need to check if we have the player targeted in set of targets
        guard needsToTargetPlayer == hasPlayerTargeted else { return false }
        
        
        if let constrainedTargets = rune?.constrainedTargets,
           let tiles = tiles {
            var legality = true
            for coord in coords {
                if !legality { return false }
                let targetType = tiles[coord].type
                if constrainedTargets.constraintedTypes.contains(where: { TileType.fuzzyEquals($0, targetType) }) {
                    // check to see if this is within the max distance to the near by type
                    let maxDistance = constrainedTargets.maxDistance
                    if let mustBeNearbyCoord = tileCoords(for: tiles, of: constrainedTargets.nearByType).first {
                        let distance = coord.distance(to: mustBeNearbyCoord)
                        legality = distance <= maxDistance
                    }
                }
                
            }
            return legality
        }
        else {
            /// ensure that the targets are within the correct distance of each other
            let targetDistance = rune?.maxDistanceBetweenTargets ?? CGFloat.greatestFiniteMagnitude
            
            /// we may never append anything to this but thats okay.
            var results: [Bool] = []
            
            for (outIdx, outerElement) in coords.enumerated() {
                for (inIdx, innerElement) in coords.enumerated() {
                    if outIdx == inIdx { continue }
                    results.append(outerElement.distance(to: innerElement) <= targetDistance)
                }
            }
            
            /// If every single target is within the targetDistance then every entry in results will be true
            /// Return false when results contains 1 or more elements of `false`
            return !results.contains(false)
            
        }
        
    }
    
    private func isTargetLegal(_ coord: TileCoord) -> Bool {
        guard let tiles = tiles else { return false }
        if typesOfTargets.isEmpty || typesOfTargets.contains(where: { TileType.fuzzyEquals(tiles[coord].type, $0) }) {
            return true
        }
        return false
    }
    
    private func affectedTiles(affectSlope: [AttackSlope], range: RangeModel, from position: TileCoord, tiles: [[Tile]]?, stopsTileTypes: EndEffectTile?) -> [TileCoord] {
        func calculateTargetSlope(in slopedDirection: AttackSlope, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            
            // Take the initial position and calculate the target
            // Add the slope's "up" value multiplied by the distance to the row
            // Add the slope's "over" value multipled by the distane to the column
            return TileCoord(initialRow + (i * slopedDirection.up), initialCol + (i * slopedDirection.over))
        }
        
        func tileStopsEffect(coord: TileCoord) -> (TileCoord?, Bool) {
            guard let stopsEffect = stopsTileTypes,
                  let tiles = tiles else { return (nil, false) }
            let contains = stopsEffect.tileTypes.contains(where: { tileType in
                TileType.fuzzyEquals(tiles[coord].type, tileType)
            })
            if contains && stopsEffect.inclusive {
                return (coord, true)
            } else if contains && !stopsEffect.inclusive {
                return (nil, true)
            } else { return (nil, false) }
        }
        
        var effectedTileCoords: [TileCoord] = []
        
        for slope in affectSlope {
            var effectCancelled = false
            for distance in range.lower...range.upper {
                if !effectCancelled {
                    let coord = calculateTargetSlope(in: slope, distance: distance, from: position)
                    guard isWithinBounds(coord, within: boardSize) else { continue }
                    
                    let (endTileCoord, stopsEffect) = tileStopsEffect(coord: coord)
                    let shouldReturnValue = !stopsEffect
                    
                    if shouldReturnValue {
                        effectedTileCoords.append(coord)
                    } else {
                        
                        // if the stop range is inclusive then add the last tile
                        if let endTileCoord = endTileCoord {
                            effectedTileCoords.append(endTileCoord)
                        }
                        effectCancelled = true
                    }
                }
                
            }
        }
        return effectedTileCoords
    }
    
    private func targets(given coord: TileCoord, withRune rune: Rune) -> AllTarget {
        var allTarget: AllTarget = .init(targets: [], areLegal: false)
        if currentTargets.allTargetAssociatedCoords.contains(coord) {
            if needsToTargetPlayer{
                if rune.targets == 1 { return currentTargets }
                
                
                if let playerCoord = playerCoord,
                   let playerTarget = currentTargets.targetContaining(playerCoord: playerCoord),
                   playerTarget.all.contains(where: {$0 == coord}) {
                    return currentTargets
                }
            }
            
            var newTargets: [Target] = []
            for target in currentTargets.targets {
                if target.all.contains(where: { return $0 == coord } ) {
                    // skip the target from currentTargets
                    continue
                } else {
                    // add to the list of targets
                    newTargets.append(target)
                    
                }
                // update the list of targets
                let areLegal = areTargetsLegal(inTargets: newTargets)
                allTarget = AllTarget(targets: newTargets, areLegal: areLegal)
            }
        } else {
            
            /// remove the illegally placed target if need
            if currentTargets.targets.count >= self.numberOfTargets {
                
                // first try to move a target that doesnt not contain the player
                if needsToTargetPlayer {
                    
                    if rune.targets == 1 {
                        let areLegal = areAllTargetsLegal(in: currentTargets)
                        allTarget = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
                        return allTarget
                    } else {
                        currentTargets.targets.removeFirst(where: { $0.coord != playerCoord })
                    }
                    
                }
                
                // then try to move an illegally placed target
                if currentTargets.targets.count >= self.numberOfTargets {
                    // remove the first if they are illegally placed
                    currentTargets.targets.removeFirst(where: { !$0.isLegal })
                }
                
                // finally just remove the first target
                if currentTargets.targets.count >= self.numberOfTargets {
                    // remove the first if they are illegally placed
                    currentTargets.targets.removeFirst()
                }
                
            }
            
            
            /// grab the existing targets
            var targets = currentTargets.targets
            
            let range = min(boardSize-1, rune.affectRange)
            
            /// calculate the associated coords
            let associatedCoords: [TileCoord]
            if rune.targetsGroupOfMonsters,
               let tiles = tiles {
                associatedCoords = findNeighbors(in: tiles, of: coord, boardSize: tiles.count, killMonsters: true).0
            } else {
                associatedCoords = affectedTiles(affectSlope: rune.affectSlopes,
                                                 range: RangeModel(lower: 1, upper: range),
                                                 from: coord,
                                                 tiles: tiles,
                                                 stopsTileTypes: rune.stopsEffectTypes)
            }
            
            /// add the new target
            targets.append(Target(coord: coord,
                                  associatedCoord: associatedCoords,
                                  isLegal: isTargetLegal(coord),
                                  isPotentialTarget: false))
            var areLegal: Bool = areTargetsLegal(inTargets: targets)
            if rune.targetsGroupOfMonsters {
                areLegal = areLegal && associatedCoords.count >= 3
            }
            allTarget = AllTarget(targets: targets, areLegal: areLegal)
        }
        return allTarget
    }
    
    /**
     Toggles targeted-ness of a tile.  If a tile is not targeted it becomes targeted.  The opposite is true.
     
     - Note: If the max number of targets for an ability is reached and a unique coord is passed in. The most recently placed target is un-targeted. And the passed in coord becomes targeted.
     - Parameters coord: The coord that is being targetted
     - Returns: Nothing
     */
    public func didTarget(_ coord: TileCoord) {
        guard let rune = rune else { return }
        
        if rune.targetInput == .random {
            return
        }
        
        /// This type of rune affects multiple targets at once
        if !rune.affectSlopes.isEmpty {
            currentTargets = targets(given: coord, withRune: rune)
        } else {
            // the player has tapped on a tile that is already targeted. So remove the tile coord
            if currentTargets.targets.contains(where: { return $0.coord == coord } ) {
                
                // dont let them unhighlight the player when a rune needs to target the player
                if needsToTargetPlayer,
                   let playerCoord = playerCoord,
                   playerCoord == coord {
                    return
                }
                
                // otherwise, remove the targeting
                currentTargets.targets.removeAll(where: { return $0.coord == coord })
                let areLegal = areAllTargetsLegal(in: currentTargets)
                currentTargets = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
            }
            // the number of targets is less than the max number of targets. So just add it to list of tile coords
            else if currentTargets.targets.count < self.numberOfTargets {
                //add the new target
                currentTargets.targets.append(
                    Target(coord: coord, associatedCoord: [], isLegal: isTargetLegal(coord), isPotentialTarget: false)
                )
                let areLegal = areAllTargetsLegal(in: currentTargets)
                currentTargets = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
                
            }
            // we need to remove on target becaue the max number is reached
            else {
                // move the most recently placed unless there is one that is "illegal" then move that one.
                let count = currentTargets.targets.count
                // remove the first if they are illegally placed
                currentTargets.targets.removeFirst(where: { !$0.isLegal })
                
                // if nothing has been removed then remove the first one placed
                if !currentTargets.targets.isEmpty,
                   currentTargets.targets.count == count {
                    
                    if needsToTargetPlayer {
                        currentTargets.targets.removeFirst { target in
                            let coord = target.coord
                            let tiles = tiles ?? []
                            return tiles[coord].type != TileType.player(.playerZero)
                        }
                    }
                    else {
                        currentTargets.targets.removeFirst()
                    }
                }
                //add the new target
                currentTargets.targets.append(Target(coord: coord, associatedCoord: [], isLegal: isTargetLegal(coord), isPotentialTarget: false))
                let areLegal = areAllTargetsLegal(in: currentTargets)
                currentTargets = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
            }
        }
    }
    
    private func autoTarget() {
        guard let tiles = tiles, let rune = rune else { return }
        var targetCoords: [TileCoord] = []
        
        for type in typesOfTargets {
            targetCoords.append(contentsOf: tileCoords(for: tiles, of: type))
        }
        
        // auto target the player
        if needsToTargetPlayer, let playerCoord = playerCoord {
            currentTargets = targets(given: playerCoord, withRune: rune)
        }
        // else try to auto target targets the player might want
        else if rune.targetInput == .playerInput {
            
            // if the number of legal targets it less than or equal to the number of total possible targets for this rune then auto target them.
            if targetCoords.count <= numberOfTargets {
                let targets = targetCoords.map { Target(coord: $0, associatedCoord: [], isLegal: true, isPotentialTarget: false) }
                var areLegal = areTargetsLegal(inTargets: targets)
                if rune.targetsGroupOfMonsters {
                    areLegal = false
                }
                
                currentTargets = AllTarget(targets: targets, areLegal: areLegal)
            }
        }
        // else show all the possible targets with the question mark reticle
        else if rune.targetInput == .random {
            let targets = targetCoords.map { Target(coord: $0, associatedCoord: [], isLegal: true, isPotentialTarget: true) }
            currentTargets = AllTarget(targets: targets, areLegal: true)
        }
        
        
    }
}
