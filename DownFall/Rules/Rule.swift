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
        return Input(.gameWin)
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
        return Input(.gameWin)
    }
}

struct Tutorial1Win: Rule {
    func apply(_ tiles: [[Tile]]) -> Input? {
        guard let playerPosition = getTilePosition(.player(.zero), tiles: tiles),
            case let TileType.player(player) = tiles[playerPosition].type,
            player.canAfford(1, inCurrency: .gem)
            else { return nil }
        return Input(.gameWin)
    }
}

struct Tutorial2Win: Rule {
    func apply(_ tiles: [[Tile]]) -> Input? {
        guard
            let playerPosition = getTilePosition(.player(.zero), tiles: tiles),
            case let TileType.player(player) = tiles[playerPosition].type,
            player.canAfford(16, inCurrency: .gold)
            else { return nil }
        //TODO: this is a filmsy check, lets check to see the position of the player or if the player has killed any monsters
        // This could also be the start of tracking stats for a player
        return Input(.gameWin)
    }
}

