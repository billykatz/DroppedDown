//
//  Rule.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

protocol Rule {
    func apply(_ tiles: [[Tile]]) -> Input?
}

struct BossWin: Rule {
    func apply(_ tiles: [[Tile]]) -> Input? {
        for tile in tiles.reduce([], +) {
            if case TileType.pillar = tile.type {
                return nil
            }
        }
        return Input(.gameWin(0))
    }
}

struct Win: Rule {
    func apply(_ tiles: [[Tile]]) -> Input? {
        let playerPosition = getTilePosition(.player(.zero), tiles: tiles)
        guard
            let pp = playerPosition,
            isWithinBounds(pp.rowBelow, within: tiles),
            case TileType.exit(let blocked) = tiles[pp.rowBelow].type,
            !blocked else { return nil }
        return Input(.gameWin(0))
    }
}

