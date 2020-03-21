//
//  BossController.swift
//  DownFall
//
//  Created by Katz, Billy on 2/27/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

class BossController: TargetViewModel {
    
    enum AttackState {
        case targetsWhatToEat
        case eats
        case targetsWhatToAttack
        case attacks
        case rests
        case dizzied
    }
    
    //view model conformance
    var _currentTargets: [TileCoord] = [] {
        didSet {
            targetingView.dataUpdated()
        }
    }
    var currentTargets: [TileCoord] {
        return _currentTargets
    }
    
    var attackTargets: [BossController.BossAttack] {
        return attacks
    }
    
    private let numRocksToEat = 6
    private var rocksToEat: [TileType] = []
    private var attacks: [BossAttack] = [] {
        didSet {
            targetingView.dataUpdated()
        }
    }
    
    private var tiles: [[Tile]]?
    private var stateBeforeDizzy = AttackState.rests
    private var state = AttackState.rests {
        didSet {
            guard let tiles = tiles else { return }
            switch state {
            case .targetsWhatToEat:
                let targets = targetRocksToEat(in: tiles)
                //create the input
                _currentTargets = targets
                InputQueue.append(Input(.bossTargetsWhatToEat(targets)))
            case .eats:
                var coordsTargetedToEat: [TileCoord] = []
                
                for row in 0..<tiles.count {
                    for col in 0..<tiles.count {
                        if _currentTargets.contains(TileCoord(row: row, column: col)) {
                            let tile = tiles[row][col]
                            rocksToEat.append(tile.type)
                            coordsTargetedToEat.append(TileCoord(row: row, column: col))
                        }
                    }
                }
                
                _currentTargets = []
                InputQueue.append(Input(.bossEatsRocks(coordsTargetedToEat)))
            case .targetsWhatToAttack:
                attacks = attack(basedOnRocks: rocksToEat)
                InputQueue.append(Input(.bossTargetsWhatToAttack(attacks)))
                rocksToEat = []
            case .attacks:
                InputQueue.append(Input(.bossAttacks(attacks)))
                attacks = []
            case .rests:
                attacks = []
                rocksToEat = []
            default:
                ()
            }
        }
    }
    
    private var targetingView: TargetingView
    private let boardSize: Int
    
    init(foreground: SKNode, playableRect: CGRect, levelSize: Int, boardSize: Int) {
        self.boardSize = boardSize
        self.targetingView = TargetView(foreground: foreground,
                                        playableRect: playableRect,
                                        levelSize: levelSize,
                                        boardSize: CGFloat(boardSize))
        targetingView.viewModel = self
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input)
        }
    }
    
    private func handle(_ input: Input) {
        switch input.type {
        case .newTurn:
            tiles = input.endTilesStruct
            advanceState()
        case .transformation(let trans):
            if let initialTrans = trans.first, case InputType.touch? = initialTrans.inputType,
                let removed = initialTrans.tileTransformation?.first?.map({ $0.initial }) {
                let removedColumns = removed.map { $0.column }
                var newTargets: [TileCoord] = []
                for coord in _currentTargets {
                    if !removed.contains(coord) {
                        var newCoord: TileCoord?
                        for column in removedColumns {
                            if coord.column == column {
                                newCoord = TileCoord(row: (newCoord ?? coord).row - 1, column: coord.column)
                            }
                        }
                        
                        newTargets.append(newCoord ?? coord)
                    }
                }
                _currentTargets = newTargets
            }
            if let initialTrans = trans.first,
                let tileTrans = initialTrans.tileTransformation?.first {
                switch initialTrans.inputType {
                case .rotateClockwise, .rotateCounterClockwise:
                    var newTargets: [TileCoord] = []
                    for tileTransformation in tileTrans {
                        if _currentTargets.contains(tileTransformation.initial) {
                            newTargets.append(tileTransformation.end)
                        }
                    }
                    
                    _currentTargets = newTargets
                default:
                    () // purposefully left blank
                }
            }
        default: ()
        }
    }
    
    enum BossAttack: Hashable {
        case hair(Set<TileCoord>)
        case destroy(Set<TileCoord>)
        case spawn(TileCoord)
        case bomb(TileCoord)
    }
    
    func attack(basedOnRocks rocksEaten: [TileType]) -> [BossAttack] {
        guard let tiles = tiles else { return [] }
        var attackedColumns = Set<Int>()
        var attackedRows = Set<Int>()
        var monstersSpawned = Set<TileCoord>()
        var bombsSpawned = Set<TileCoord>()
        
        var attacksRow: Bool {
            return Int.random(2) == 0
        }
        
        func rowColumnAttack(_ attack: BossAttack) -> (BossAttack, Set<TileCoord>) {
            let attackedRow = attacksRow
            let attackIndex: Int
            if attackedRow {
                attackIndex = Int.random(boardSize, notInSet: attackedRows)
                attackedRows.insert(attackIndex)
            } else {
                attackIndex = Int.random(boardSize, notInSet: attackedColumns)
                attackedColumns.insert(attackIndex)
            }
            
            var attackedIndices = Set<TileCoord>()
            for row in 0..<tiles.count {
                for col in 0..<tiles.count {
                    if attackedRow, attackIndex == row {
                        attackedIndices.insert(TileCoord(row, col))
                    }
                    else if !attackedRow, attackIndex == col {
                        attackedIndices.insert(TileCoord(row, col))
                    }
                }
            }
            
            switch attack {
            case .hair:
                return (.hair(attackedIndices), attackedIndices)
            case .destroy:
                return (.destroy(attackedIndices), attackedIndices)
            default:
                preconditionFailure("Do not call this for spawn or bombs")
            }
        }
        
        var doNotAttackCoords = pillarCoords.union([playerCoord])
    
        return rocksEaten.map {
            if case TileType.rock(let color) = $0 {
                switch color {
                case .blue:
                    let (attack, coords) = rowColumnAttack(.hair(Set<TileCoord>()))
                    doNotAttackCoords = doNotAttackCoords.union(coords)
                    return attack
                case .red:
                    let bombCoord = randomCoord(notIn: doNotAttackCoords)
                    doNotAttackCoords.insert(bombCoord)
                    return .bomb(bombCoord)
                case .purple:
                    let spawnCoord = randomCoord(notIn: doNotAttackCoords)
                    doNotAttackCoords.insert(spawnCoord)
                    return .spawn(spawnCoord)
                case .brown:
                    let (attack, coords) = rowColumnAttack(.destroy(Set<TileCoord>()))
                    doNotAttackCoords = doNotAttackCoords.union(coords)
                    return attack
                case .green:
                    preconditionFailure("How did you eat a green rock???")
                }
            } else {
                preconditionFailure("These eaten rocks should only have type rock")
            }
        }
        
    }
    
    private var pillarCoords: Set<TileCoord> {
        guard let tiles = tiles else { return Set<TileCoord>() }
        var temp = Set<TileCoord>()
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if case TileType.pillar = tiles[row][col].type {
                    temp.insert(TileCoord(row: row, column: col))
                }
            }
        }
        return temp
    }
    
    private var playerCoord: TileCoord {
        guard let tiles = tiles, let position = getTilePosition(.player(.zero), tiles: tiles) else { preconditionFailure("Where is the player??") }
        return position
    }
    
    func targetRocksToEat(in tiles: [[Tile]]) -> [TileCoord] {
        var targets: [TileCoord] = []
        var notTargetable = notTargetableTiles(in: tiles)
        for _ in 0..<numRocksToEat {
            let newTarget = randomCoord(notIn: notTargetable)
            notTargetable.insert(newTarget)
            targets.append(newTarget)
        }
        return targets
    }
    
    private func notTargetableTiles(in tiles: [[Tile]]) -> Set<TileCoord> {
        var set = Set<TileCoord>()
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                switch tiles[row][col].type {
                case .rock:
                    // purposefully left blank
                    ()
                default:
                    set.insert(TileCoord(row: row, column: col))
                }
            }
        }
        return set
    }
    
    private func randomCoord(notIn set: Set<TileCoord>) -> TileCoord {
        guard let boardSize = tiles?.count else { preconditionFailure("We need a board size to continue") }
        let upperbound = boardSize
        
        var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        while set.contains(tileCoord) {
            tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        }
        return tileCoord
    }
    
    
    func advanceState() {
        switch state {
        case .targetsWhatToEat:
            state = .eats
        case .eats:
            state = .targetsWhatToAttack
        case .targetsWhatToAttack:
            state = .attacks
        case .attacks:
            state = .rests
        case .rests:
            state = .targetsWhatToEat
        case .dizzied:
            state = stateBeforeDizzy
        }
    }
}

