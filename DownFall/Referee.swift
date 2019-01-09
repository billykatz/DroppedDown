//
//  Referee.swift
//  DownFallTests
//
//  Created by William Katz on 12/29/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

struct Referee {
    let board: Board
    
    init(_ board: Board) {
        self.board = board
    }
    
    func enforceRules() -> [Input] {
        //player wins
        func playerWins() -> Bool {
            guard let playerRow = board.playerPosition?.x,
                let playerCol = board.playerPosition?.y,
                let exitRow = board.exitPosition?.x,
                let exitCol = board.exitPosition?.y else { return false }
            return playerRow == exitRow + 1 && playerCol == exitCol
        }
        
        func boardHasMoreMoves() -> Bool {
            guard let exitPosition = board.exitPosition,
                let playerPosition = board.playerPosition else { return false }
            for (i, row) in board.tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if board.findNeighbors(i, j)?.count ?? 0 > 2 || board.valid(neighbor: exitPosition, for: playerPosition) || playerAttacks() {
                        return true
                    }
                }
            }
            return false
        }
        
        func playerAttacks() -> Bool {
            guard let playerCol = board.playerPosition?.y,
                let playerRow = board.playerPosition?.x,
                board.playerPosition?.x ?? 0 - 1 >= 1 else { return false }
            if case TileType.greenMonster(_) = board.tiles[playerRow-1][playerCol] {
                return true
            }
            return false
        }
        
        
        func monsterAttacks() -> [TileCoord] {
            var attacks : [TileCoord] = []
            
            for (i, row) in board.tiles.enumerated() {
                for (j, _) in row.enumerated() {
                    if i >= 1 {
                        if case TileType.greenMonster(_) = board.tiles[i][j],
                            case TileType.player(_) = board.tiles[i-1][j] {
                            attacks.append(TileCoord(i, j))
                        }
                    }
                }
            }
            return attacks
        }

        // Game rules are enforced in the following priorities
        // Game Win
        // Game Lose
        // Player attack
        // Monster attack
        // For rules that are not game win or game lose, they are all determined in the same step
        // Rules (inputs) are resolved in order of the array of inputs
        if playerWins() {
            return [.gameWin]
        } else if !boardHasMoreMoves() {
            return [.gameLose]
        }
        
        var inputs: [Input] = []
        
        if playerAttacks() {
           inputs.append(Input.playerAttack)
        }
        
        monsterAttacks().forEach { inputs.append(Input.monsterAttack($0)) }
        
        return inputs
    }
}
