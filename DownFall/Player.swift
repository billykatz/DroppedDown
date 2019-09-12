//
//  Player.swift
//  DownFall
//
//  Created by William Katz on 8/23/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

protocol MakesMoves {
    func move()
}

protocol Navigates {
    func navigate() -> InputType
}

protocol MakesMistakes {
    func mistake(_ type: InputType) -> InputType
}

protocol KillsMonsters {
    func kills() -> InputType?
}

class Player {
    let board: Board
    let objective: ObjectiveTracker
    let intelligence = 10
    
    init(objective: ObjectiveTracker,
         board: Board) {
        self.objective = objective
        self.board = board
    }
}

extension Player: MakesMoves {
    func move() {
        let intelligentMove = kills() ?? mistake(navigate())
        switch intelligentMove {
        case .touch:
            let boardSize = board.boardSize
            let randomRow = Int.random(boardSize)
            let randomCol = Int.random(boardSize)
            let coord = TileCoord(randomRow, randomCol)
            InputQueue.append(Input(.touch(coord, board.tiles[coord])))
        case .rotateRight, .rotateLeft:
            InputQueue.append(Input(intelligentMove))
        default:
            ()
        }
    }
}

extension Player: Navigates {
    func navigate() -> InputType {
        switch (objective.relativeDirection){
        case .north:
            return .touch(.zero, .empty)
        case .south:
            return .rotateLeft
        case .east:
            return .rotateLeft
        case .west:
            return .rotateRight
        }
    }
}

extension Player: MakesMistakes {
    func mistake(_ type: InputType) -> InputType {
        if Int.random(100) / intelligence < 7 {
            return type
        }
        
        var legalMoves = InputType.legalMoves()
        legalMoves = legalMoves.filter { $0 != type }
        return legalMoves[Int.random(legalMoves.count)]
        
    }
}

extension Player: KillsMonsters {
    func kills() -> InputType? {
        guard let playerPosition = board.getTilePosition(.player(.zero)) else {
            return nil
        }
        let orthogonalPositions = playerPosition.adjacentOrthogonalCoords
        for coord in orthogonalPositions {
            guard board[coord] == TileType.monster(.zero) else { continue }
            if coord == playerPosition.rowBelow {
                return .touch(.zero, .empty)
            } else if coord == playerPosition.rowAbove {
                return .rotateLeft
            } else if coord == playerPosition.colRight {
                return .rotateRight
            } else {
                return .rotateLeft
            }
        }
        
        return nil

    }
    
    
}

