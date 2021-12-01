//
//  TargetingViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import Combine


class TargetingViewModel: Targeting {
    
    public var updateCallback: (() -> Void)?
    public var runeSlotsUpdated: ((Int, [Rune]) -> Void)?
    
    private var runeSlots: Int = 0
    var inventory: [Rune] = []
    var boardSize: Int = 0
    
    /// publishers
    private var foundRuneDiscardedSubject = PassthroughSubject<(), Never>()
    var foundRuneDiscardedPublisher: AnyPublisher<(), Never> {
        return foundRuneDiscardedSubject.eraseToAnyPublisher()
    }
    
    var runeReplacementSubject = PassthroughSubject<(Pickaxe, Rune), Never>()
    var runeReplacementPublisher: AnyPublisher<(Pickaxe, Rune), Never> {
        return runeReplacementSubject.eraseToAnyPublisher()
    }
    
    var rune: Rune? {
        didSet {
            currentTargets = AllTarget(targets: [], areLegal: false)
            if let rune = rune {
                InputQueue.append(Input(InputType.itemUseSelected(rune)))
                autoTarget()
            }
            else {
                InputQueue.append(Input(InputType.itemUseCanceled))
            }
        }
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
        return self.currentTargets.targets.allSatisfy({
            return $0.isLegal
        }) && self.currentTargets.targets.count == self.numberOfTargets
        && self.currentTargets.areLegal
    }
    
    
    private var tiles: [[Tile]]? = nil {
        didSet {
            autoTarget()
            updateCallback?()
        }
    }
    
    init() {
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input)
        }
    }
    
    func handle(_ input: Input) {
        switch input.type {
        case .runeReplaced(let pickaxe, let rune):
            let runes = pickaxe.runes.filter { $0.type != rune.type }
            runeSlotsUpdated?(pickaxe.runeSlots, runes)
        case .foundRuneDiscarded:
            foundRuneDiscardedSubject.send(())
        case .runeReplacement(let pickaxe, let rune):
            runeReplacementSubject.send((pickaxe, rune))
        case .transformation(let trans):
            if let inputType = trans.first?.inputType,
                case InputType.itemUsed = inputType,
                let endTiles = trans.first?.endTiles {
                if let playerData = playerData(in: endTiles),
                   let runes = playerData.runes {
                    let runeSlots = playerData.runeSlots ?? 0
                    self.runeSlots = runeSlots
                    inventory = playerData.runes ?? []
                    runeSlotsUpdated?(runeSlots, runes)
                }

            } else if let inputType = trans.first?.inputType,
                 case InputType.itemUseSelected = inputType {
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
        case .itemUseCanceled:
            ()
        default:
            ()
        }
        
    }

    
    private func areTargetsLegal(_ coords: [TileCoord]) -> Bool {
        guard let tiles = tiles else { return false }
        let needsToTargetPlayer: Bool = rune?.targetTypes?.contains(.player(.playerZero)) ?? false
        var hasPlayerTargeted = false
        for coord in coords {
            if !isTargetLegal(coord) {
                return false
            }
            if  tiles[coord].type == TileType.player(.zero) {
                hasPlayerTargeted = true
            }
        }
        
        /// For some items we MUST target the player.
        /// If needsToTargetPlayer == false, then the palyer is not a legal target and we will continue past the guard
        /// If needsToTargetPlayer == true, then we need to check if we have the player targeted in set of targets
        guard needsToTargetPlayer == hasPlayerTargeted else { return false }
        
        /// ensure that the targets are within the correct distance of each other
        let targetDistance = rune?.maxDistanceBetweenTargets ?? Int.max
        
        /// we may never append anything to this but thats okay.
        var results: [Bool] = []
        
        for (outIdx, outerElement) in coords.enumerated() {
            for (inIdx, innerElement) in coords.enumerated() {
                if outIdx == inIdx { continue }
                results.append(outerElement.distance(to: innerElement, along: .vertical) <= targetDistance)
                results.append(outerElement.distance(to: innerElement, along: .horizontal) <= targetDistance)
            }
        }
        
        /// If every single target is within the targetDistance then every entry in results will be true
        /// Return false when results contains 1 or more elements of `false`
        return !results.contains(false)
        
    }
    
    private func isTargetLegal(_ coord: TileCoord) -> Bool {
        guard let tiles = tiles else { return false }
        if typesOfTargets.isEmpty || typesOfTargets.contains(tiles[coord].type) {
            return true
        }
        return false
    }
    
    public func affectedTiles(affectSlope: [AttackSlope], range: RangeModel, from position: TileCoord) -> [TileCoord] {
        func calculateTargetSlope(in slopedDirection: AttackSlope, distance i: Int, from position: TileCoord) -> TileCoord {
            let (initialRow, initialCol) = position.tuple
            
            // Take the initial position and calculate the target
            // Add the slope's "up" value multiplied by the distance to the row
            // Add the slope's "over" value multipled by the distane to the column
            return TileCoord(initialRow + (i * slopedDirection.up), initialCol + (i * slopedDirection.over))
        }
        
        return affectSlope.flatMap { attackSlope in
            return (range.lower...range.upper).compactMap { range in
                let coord = calculateTargetSlope(in: attackSlope, distance: range, from: position)
                return isWithinBounds(coord, within: boardSize) ? coord : nil
            }
        }
    }
    
    /**
     Toggles targeted-ness of a tile.  If a tile is not targeted it becomes targeted.  The opposite is true.
     
     - Note: If the max number of targets for an ability is reached and a unique coord is passed in. The most recently placed target is un-targeted. And the passed in coord becomes targeted.
     - Parameters coord: The coord that is being targetted
     - Returns: Nothing
     */
    func didTarget(_ coord: TileCoord) {
        guard let rune = rune else { preconditionFailure("We cant target if we dont have an ability set") }
        
        /// This type of rune affects multiple targets at once
        if !rune.affectSlopes.isEmpty {
            if currentTargets.all.contains(coord) {
                var newTargets: [Target] = []
                for target in currentTargets.targets {
                    if target.all.contains(where: { return $0 == coord } ) {
                        // skip the target from currentTargets
                    } else {
                        // rebuild the list of targets
                        newTargets.append(target)
                    }
                    //update the list of targets
                    currentTargets = AllTarget(targets: newTargets, areLegal: areTargetsLegal(newTargets.map { $0.coord }))
                }
            } else {
                /// remove the illegally placed target if need
                if currentTargets.targets.count >= self.numberOfTargets {
                    // remove the first if they are illegally placed
                    currentTargets.targets.removeFirst(where: { !$0.isLegal })
                }
                
                // remove the target placed first if needed
                if currentTargets.targets.count >= self.numberOfTargets {
                    // remove the first if they are illegally placed
                    currentTargets.targets.removeFirst()
                }
                
                /// grab the existing targets
                var targets = currentTargets.targets
                
                let range = min(boardSize-1, rune.affectRange)
                
                /// calculate the associated coords
                let associatedCoords: [TileCoord] = affectedTiles(affectSlope: rune.affectSlopes,
                                                                  range: RangeModel(lower: 1, upper: range),
                                                                  from: coord)
                
                /// add the new target
                targets.append(Target(coord: coord,
                                      associatedCoord: associatedCoords,
                                      isLegal: isTargetLegal(coord)))
                let areLegal = areTargetsLegal(currentTargets.all)
                currentTargets = AllTarget(targets: targets, areLegal: areLegal)
                
            }
        } else {
            if currentTargets.targets.contains(where: { return $0.coord == coord } ) {
                // remove the targeting
                currentTargets.targets.removeAll(where: { return $0.coord == coord })
                let newTargets = currentTargets.targets
                let areLegal = areTargetsLegal(newTargets.map { $0.coord })
                currentTargets = AllTarget(targets: newTargets, areLegal: areLegal)
            } else if currentTargets.targets.count < self.numberOfTargets {
                //add the new target
                currentTargets.targets.append(Target(coord: coord, associatedCoord: [], isLegal: isTargetLegal(coord)))
                let areLegal = areTargetsLegal(currentTargets.targets.map { $0.coord })
                currentTargets = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
                
            } else {
                // move the most recently placed unless there is one that is "illegal" then move that one.
                let count = currentTargets.targets.count
                // remove the first if they are illegally placed
                currentTargets.targets.removeFirst(where: { !$0.isLegal })
                
                // if nothing has been removed then remove the first one placed
                if !currentTargets.targets.isEmpty,
                   currentTargets.targets.count == count {
                    currentTargets.targets.removeFirst()
                }
                //add the new target
                currentTargets.targets.append(Target(coord: coord, associatedCoord: [], isLegal: isTargetLegal(coord)))
                let areLegal = areTargetsLegal(currentTargets.targets.map { $0.coord })
                currentTargets = AllTarget(targets: currentTargets.targets, areLegal: areLegal)
            }
        }
    }
    
    func didUse(_ rune: Rune?) {
        guard let rune = rune else { return }
        guard legallyTargeted else {
            self.rune = nil
            return
        }
        InputQueue.append(
            Input(.itemUsed(rune, currentTargets.all))
        )
        self.rune = nil
        currentTargets = AllTarget(targets: [], areLegal: false)
        
    }
    
    func didDeselect() {
        self.rune = nil
        currentTargets = AllTarget(targets: [], areLegal: false)
    }
    
    func didSelect(_ rune: Rune?) {
        self.rune = rune
        if rune == nil {
            currentTargets = AllTarget(targets: [], areLegal: false)
        }
    }
    
    private func autoTarget() {
        guard let tiles = tiles else { return }
        var targetCoords: [TileCoord] = []
        for type in typesOfTargets {
            targetCoords.append(contentsOf: typeCount(for: tiles, of: type))
        }
        if targetCoords.count <= numberOfTargets {
            // targets are necessarily legal because we looped over types of targets
            let targets = targetCoords.map { Target(coord: $0, associatedCoord: [], isLegal: true) }
            let areLegal = areTargetsLegal(targets.map { $0.coord })
            currentTargets = AllTarget(targets: targets, areLegal: areLegal)
        }
    }
}
