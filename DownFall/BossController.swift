//
//  BossController.swift
//  DownFall
//
//  Created by Katz, Billy on 2/27/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

class BossController {
    
    enum AttackState {
        case targetsWhatToEat
        case eats
        case targetsWhatToAttack
        case attacks
        case rests
        case dizzied
    }
    private let numRocksToEat = 4
    private var rocksToEat: [TileType] = []
    private var attackDictionary: [BossAttack: Set<TileCoord>] = [:]
    
    private var tiles: [[Tile]]?
    private var stateBeforeDizzy = AttackState.rests
    private var state = AttackState.rests {
        didSet {
            guard let tiles = tiles else { return }
            switch state {
            case .targetsWhatToEat:
                let targets = targetRocksToEat(in: tiles)
                //create the input
                InputQueue.append(Input(.bossTargetsWhatToEat(targets)))
            case .eats:
                var coordsTargetedToEat: [TileCoord] = []
                
                for row in 0..<tiles.count {
                    for col in 0..<tiles.count {
                        let tile = tiles[row][col]
                        if tile.bossTargetedToEat {
                            rocksToEat.append(tile.type)
                            coordsTargetedToEat.append(TileCoord(row: row, column: col))
                        }
                    }
                }
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
    
    init() {
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
    
    enum BossAttack {
        case column
        case row
        case spawn
        case bomb
    }
    
    func attack(basedOnRocks rocksEaten: [TileType]) -> [BossAttack] {
        
        return rocksEaten.map {
            if case TileType.rock(let color) = $0 {
                switch color {
                case .blue:
                    return .column
                case .red:
                    return .bomb
                case .purple:
                    return .spawn
                case .brown:
                    return .row
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
        var columnsAttacked = Set<Int>()
        var rowsAttacked = Set<Int>()
        var monstersSpawned = Set<TileCoord>()
        var bombsSpawned = Set<TileCoord>()
        for attack in attacks {
            switch attack {
            case .bomb:
                bombsSpawned.insert(randomCoord(notIn: bombsSpawned))
            case .column:
                columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
            case .row:
                rowsAttacked.insert(Int.random(tiles.count, notInSet: rowsAttacked))
            case .spawn:
                monstersSpawned.insert(randomCoord(notIn: monstersSpawned))
            }
        }
        
        var columnCoords = Set<TileCoord>()
        var rowCoords = Set<TileCoord>()
        for row in 0..<tiles.count {
            for col in 0..<tiles.count {
                if columnsAttacked.contains(col) {
                    columnCoords.insert(TileCoord(row, col))
                }
                if rowsAttacked.contains(row) {
                    rowCoords.insert(TileCoord(row, col))
                }
            }
        }
        
        var result: [BossAttack: Set<TileCoord>] = [:]
        if !columnCoords.isEmpty {
            result[.column] = columnCoords
        }
        if !rowCoords.isEmpty {
            result[.row] = rowCoords
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
