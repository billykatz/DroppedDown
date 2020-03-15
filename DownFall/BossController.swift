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
    
    var attackTargets: [BossController.BossAttack: Set<TileCoord>] {
        return attackDictionary
    }
    
    private let numRocksToEat = 6
    private var rocksToEat: [TileType] = []
    private var attackDictionary: [BossAttack: Set<TileCoord>] = [:] {
        didSet {
            targetingView.dataUpdated()
        }
    }
    
    private var tiles: [[Tile]]?
    private var stateBeforeDizzy = AttackState.rests
    private(set) var state = AttackState.rests {
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
                let attacks = attack(basedOnRocks: rocksToEat)
                attackDictionary = attacked(tiles: tiles, by: attacks)
                InputQueue.append(Input(.bossTargetsWhatToAttack(attackDictionary)))
                rocksToEat = []
            case .attacks:
                InputQueue.append(Input(.bossAttacks(attackDictionary)))
                attackDictionary = [:]
            case .rests:
                attackDictionary = [:]
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
        default: ()
        }
    }
    
    enum BossAttack: Hashable {
        case hair(Int, Bool)
        case destroy(Int, Bool)
        case spawn
        case bomb
    }
    
    func attack(basedOnRocks rocksEaten: [TileType]) -> [BossAttack] {
        
        var attackedColumns = Set<Int>()
        var attackedRows = Set<Int>()
        
        var attacksRow: Bool {
            return Int.random(2) == 0
        }
        
        func rowColumnAttack(_ attack: BossAttack) -> BossAttack {
            let attacksRowOrColumn = attacksRow
            let attackIndex: Int
            if attacksRowOrColumn {
                attackIndex = Int.random(boardSize, notInSet: attackedRows)
                attackedRows.insert(attackIndex)
            } else {
                attackIndex = Int.random(boardSize, notInSet: attackedColumns)
                attackedColumns.insert(attackIndex)
            }
            
            switch attack {
            case .hair:
                return .hair(attackIndex, attacksRowOrColumn)
            case .destroy:
                return .destroy(attackIndex, attacksRowOrColumn)
            default:
                return attack
            }
        }
        
        return rocksEaten.map {
            if case TileType.rock(let color) = $0 {
                switch color {
                case .blue:
                    return rowColumnAttack(.hair(0, false))
                case .red:
                    return .bomb
                case .purple:
                    return .spawn
                case .brown:
                    return rowColumnAttack(.destroy(0, false))
                case .green:
                    preconditionFailure("How did you eat a green rock???")
                }
            } else {
                preconditionFailure("These eaten rocks should only have type rock")
            }
        }
        
    }
    
    func attacked(tiles: [[Tile]], by attacks: [BossController.BossAttack]) -> [BossController.BossAttack: Set<TileCoord>] {
        //TODO: can be optimized
        var columnsAtwtacked = Set<Int>()
        var rowsAttacked = Set<Int>()
        var monstersSpawned = Set<TileCoord>()
        var bombsSpawned = Set<TileCoord>()
        var hairRowsAttacked = Set<Int>()
        var hairColumnsAttacked = Set<Int>()
        var destroyRowsAttacked = Set<Int>()
        var destroyColumnsAttacked = Set<Int>()
        
        var attacksRow: Bool {
            return Int.random(2) == 0
        }
        
        /// Deteremine which rows and/or columns will be attacked
        for attack in attacks {
            switch attack {
            case let .hair(attackIndex, isARow):
                if isARow {
                    hairRowsAttacked.insert(attackIndex)
                } else {
                    hairColumnsAttacked.insert(attackIndex)
                }
            case let .destroy(attackIndex, isARow):
                if isARow {
                    destroyRowsAttacked.insert(attackIndex)
                } else {
                    destroyColumnsAttacked.insert(attackIndex)
                }
            default: ()
            }
        }
        
        /// Determine the actual tile coords that will be hair attacked or destroyed
        var hairAttackColumnCoords = Set<TileCoord>()
        var hairAttackRowCoords = Set<TileCoord>()
        var destoryAttackColumnCoords = Set<TileCoord>()
        var destoryAttackRowCoords = Set<TileCoord>()
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if hairColumnsAttacked.contains(col) {
                    hairAttackColumnCoords.insert(TileCoord(row, col))
                }
                if hairRowsAttacked.contains(row) {
                    hairAttackRowCoords.insert(TileCoord(row, col))
                }
                if destroyColumnsAttacked.contains(col) {
                    destoryAttackColumnCoords.insert(TileCoord(row, col))
                }
                if destroyRowsAttacked.contains(row) {
                    destoryAttackRowCoords.insert(TileCoord(row, col))
                }
            }
        }
        
        let columnRowCoords = hairAttackRowCoords.union(hairAttackColumnCoords).union(destoryAttackRowCoords).union(destoryAttackColumnCoords)
        
        for attack in attacks {
            switch attack {
            case .bomb:
                bombsSpawned.insert(randomCoord(notIn: bombsSpawned.union(columnRowCoords)))
            case .spawn:
                monstersSpawned.insert(randomCoord(notIn: monstersSpawned.union(columnRowCoords)))
            default: ()
            }
        }

        var result: [BossAttack: Set<TileCoord>] = [:]
        if !hairAttackColumnCoords.isEmpty {
            result[.hair(0, false)] = hairAttackColumnCoords
        }
        if !hairAttackRowCoords.isEmpty {
            result[.hair(0, true)] = hairAttackRowCoords
        }
        if !destoryAttackColumnCoords.isEmpty {
            result[.destroy(0, false)] = destoryAttackColumnCoords
        }
        if !destoryAttackRowCoords.isEmpty {
            result[.destroy(0, true)] = destoryAttackRowCoords
        }
        if !bombsSpawned.isEmpty {
            result[.bomb] = bombsSpawned
        }
        if !monstersSpawned.isEmpty {
            result[.spawn] = monstersSpawned
        }
        return result
        
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

