//
//  BoardMocker.swift
//  DownFallTests
//
//  Created by William Katz on 2/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import DownFall

extension Int: Sequence {
    public func makeIterator() -> CountableRange<Int>.Iterator {
        return (0..<self).makeIterator()
    }
}

func entities() -> [EntityModel] {
    guard let data = try! Data.data(from: "EntityTest") else {
        return []
    }
    do {
        return try JSONDecoder().decode(EntitiesModel.self, from: data).entities
    }
    catch {
        fatalError("\(error)")
    }
}

extension Board {
    convenience init(tiles: [[TileType]]) {
        self.init(tiles: tiles,
                  tileCreator: TileCreator(entities(),
                                           difficulty: .normal,
                                           objectiveTracker: MockObjectiveTracker()))
    }
}

typealias Builder = (Board) -> Board
infix operator >>>
func >>>(builder1: @escaping Builder, builder2: @escaping Builder) -> Builder { return { board in builder2(builder1(board)) }
}

func emptyBoard(size: Int) -> Builder {
    return { _ in
        var tiles : [[TileType]] = []
        for i in size {
            tiles.append([])
            for _ in size {
                tiles[i].append(.empty)
            }
        }
        return Board(tiles: tiles)
    }
}

func all(_ tile: TileType, _ board: Board) -> Builder {
    return { newBoard in
        var newTiles : [[TileType]] = board.tiles
        for row in board.boardSize {
            for col in board.boardSize {
                newTiles[row][col] = tile
            }
        }
        return Board(tiles: newTiles)
    }
}

func xRows(_ numRows: Int,_ tile: TileType,_ board: Board) -> Builder {
    return { board in
        var newTiles : [[TileType]] = board.tiles
        for row in numRows {
            for col in board.boardSize {
                newTiles[row][col] = tile
            }
        }
        return Board(tiles: newTiles)

    }
}

func xTiles(_ numTiles: Int, _ tile: TileType, _ board: Board) -> Builder {
    return { board in
        let row = Int.random(board.boardSize)
        let col = Int.random(board.boardSize)
        var newTiles = board.tiles
        newTiles[row][col] = tile
        return Board(tiles: newTiles)
    }
}

extension TileType {
    static var playerWithGem: TileType {
        let gemCarry = CarryModel(item: [Item(type: .gem, range: .one)])
        return TileType.createPlayer(carry: gemCarry)
    }
}


/*
 +----------+-----------------------------+------------------------------------------------+
 |          |         Player Yes          |                   Player No                    |
 +----------+-----------------------------+------------------------------------------------+
 | Exit Yes | Puts player on top of exit  | places a player on top of exit                 |
 | Exit No  | Puts exit under player      | places player and exit, with player above exit |
 +----------+-----------------------------+------------------------------------------------+
 */
func win(_ board: Board) -> Builder {
    return { board in
        guard board.boardSize > 1 else { return board } //cant win if there is only 1 row
        let playerPosition = typeCount(for: board.tiles, of: .player(.zero)).first
        let exitPosition = typeCount(for: board.tiles, of: .exit).first
        var newTiles = board.tiles
        
        if let pp = playerPosition, let ep = exitPosition {
            if !board.isUpperBound(row: ep.x) {
                let intermediate = newTiles[ep.rowAbove.x][ep.y]
                newTiles[ep.rowAbove.x][ep.y] = .playerWithGem
                newTiles[pp.x][pp.y] = intermediate
            } else if !board.isLowerBound(row: pp.x)  {
                let intermediate = newTiles[pp.rowBelow.x][pp.y]
                newTiles[pp.rowBelow.x][pp.y] = .exit
                newTiles[ep.x][ep.y] = intermediate
            } else {
                //exit is on top row and player in on bottom row
                //swapsies time
                let intermediate = newTiles[ep.rowBelow.x][ep.y] // tile beneath exit
                newTiles[ep.rowBelow.x][ep.y] = .exit // swaps intermediate with exit
                newTiles[ep.x][ep.y] = .playerWithGem // put player on top of exit
                newTiles[pp.x][pp.y] = intermediate // swap intermediate with player
            }
        } else if let pp = playerPosition {
            if !board.isLowerBound(row: pp.x)  {
                newTiles[pp.rowBelow.x][pp.y] = .exit
            } else {
                //player is on bottom row, move it up and
                newTiles[pp.rowAbove.x][pp.y] = .playerWithGem // swaps intermediate with exit
                newTiles[pp.x][pp.y] = .exit // swap intermediate with player
            }
        } else if let ep = exitPosition {
            if !board.isUpperBound(row: ep.x) {
                newTiles[ep.rowAbove.x][ep.y] = .playerWithGem
            } else {
                //exit is on top row
                newTiles[ep.rowBelow.x][ep.y] = .exit // swaps intermediate with exit
                newTiles[ep.x][ep.y] = .playerWithGem // put player on top of exit
            }
        } else {
            let playerPosition = TileCoord.random(board.boardSize-1).rowAbove // guaranteed not to be on the bottom
            let exitPosition = playerPosition.rowBelow
            newTiles[playerPosition.x][playerPosition.y] = .playerWithGem
            newTiles[exitPosition.x][exitPosition.y] = .exit
        }
        
        return Board(tiles: newTiles)
    }
}

func lose(_ board: Board) -> Builder {
    return { board in
        var newTiles = board.tiles
        for i in board.boardSize {
            for j in board.boardSize {
                newTiles[i][j] = (i + j) % 2 == 0  ? .blackRock : .greenRock
            }
        }
        return Board(tiles: newTiles)
    }
}

func playerAttacks(_ board: Board,
                   _ monsterTile: TileType = .monster(.zero),
                   _ player: TileType = .player(.zero)) -> Builder {
    return { board in
        guard board.boardSize > 1 else { return board }
        let playerPosition = typeCount(for: board.tiles, of: .player(.zero)).first
        var newTiles = board.tiles
        
        if let pp = playerPosition{
            if !board.isLowerBound(row: pp.x) {
                //player on board above bottom row put a monster beneath it
                newTiles[pp.rowBelow.x][pp.y] = monsterTile
            } else {
                //player on bottom row
                newTiles[pp.rowAbove.x][pp.y] = player
                newTiles[pp.x][pp.y] = monsterTile
            }
        } else {
            //player is not on the board
            let nonBottomRowCol = TileCoord.random(board.boardSize - 1)
            newTiles[nonBottomRowCol.rowAbove.x][nonBottomRowCol.y] = player
            newTiles[nonBottomRowCol.x][nonBottomRowCol.y] = monsterTile
            
        }
        
        return Board(tiles: newTiles)
    }
}

extension Array {
    //TODO: figure out how to do this without force casting
    subscript(index: TileCoord) -> Element? {
        get {
            let inner = self[index.x]
            let innerArray = inner as! Array
            return innerArray[index.y]
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            let inner = self[index.x]
            var innerArray = inner as! Array
            innerArray[index.y] = newValue
        }
    }
}





extension Board {
    static func build(size: Int) -> Board {
        var tiles : [[TileType]] = []
        for i in size {
            tiles.append([])
            for _ in size {
                tiles[i].append(.empty)
            }
        }
        return Board(tiles: tiles)
    }
    
    func isUpperBound(row: Int) -> Bool {
        return self.boardSize - 1 <= row
    }
    
    func isLowerBound(row: Int) -> Bool {
        return 0 >= row
    }
    
    

}
