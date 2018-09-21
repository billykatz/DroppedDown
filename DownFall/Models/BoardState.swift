//
//  BoardState.swift
//  DownFall
//
//  Created by William Katz on 9/17/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit

protocol BoardState {
    func handleInput(_ point: CGPoint, in board: Board) -> BoardState?
}

struct SelectedState : BoardState {
    let selectedTiles: [TileCoord]
    
    func handleInput(_ point: CGPoint, in board: Board) -> BoardState? {
        if let direction = board.shouldRotateDirection(point: point) {
            return UnselectedState(currentBoard: board.rotate(direction))
        }
        return traverse(board: board) { (tile, coord) in
            guard tile.contains(point), tile.isTappable() else { return nil }
            if tile.selected {
                //return a standard state after removing and refilling
                return UnselectedState(currentBoard: board.removeAndRefill(selectedTiles: selectedTiles))
            } else {
                //return a new Selected State with new selected tiles
                return SelectedState(selectedTiles: board.findNeighbors(coord.0, coord.1))
            }
        }
    }
}

func traverse(board: Board,_ work: (DFTileSpriteNode, TileCoord) -> BoardState?) -> BoardState? {
    for index in 0..<board.spriteNodes.reduce([],+).count {
        let row = index / board.boardSize
        let col = (index - row * board.boardSize) % board.boardSize
        let tile = board.spriteNodes[row][col]
        if let state = work(tile, (row, col)) {
            return state
        }
    }
    return nil
}

struct UnselectedState : BoardState {
    let currentBoard : [[DFTileSpriteNode]]?
    func handleInput(_ point: CGPoint, in board: Board) -> BoardState? {
        if let direction = board.shouldRotateDirection(point: point) {
            return UnselectedState(currentBoard: board.rotate(direction))
        }
        return traverse(board: board) { (tile, coord) in
            guard tile.contains(point), tile.isTappable() else { return nil }
            if !tile.selected {
                //return a standard state after removing and refilling
                return SelectedState(selectedTiles: board.findNeighbors(coord.0, coord.1))
            }
            return nil
        }
        //TODO: consider checking here for no moves lefts (ie we havent moved to another state even though we got an input)
    }
}
