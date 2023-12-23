//
//  Transformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//


struct Transformation: Hashable {
    var tileTransformation: [TileTransformation]?
    var inputType: InputType? = nil
    var endTiles: [[Tile]]?
    
    var removed: [TileTransformation]?
    var newTiles: [TileTransformation]?
    var shiftDown: [TileTransformation]?
    var removedTilesContainGem: Bool?
    var offers: [StoreOffer]?
    var monstersDies: [MonsterDies]?
    var pillarsTakeDamage: [PillarTakesDamage]?
    
    var poisonColumnAttacks: [[TileCoord]]?
    var poisonRowAttacks: [[TileCoord]]?
    
    var playerTookDamage: [TileCoord]?
    
    
    
    init(transformation tileTransformation: [TileTransformation]? = nil,
         inputType: InputType? = nil,
         endTiles: [[Tile]]? = nil,
         removed: [TileTransformation]? = nil,
         newTiles: [TileTransformation]? = nil,
         shiftDown: [TileTransformation]? = nil,
         removedTilesContainGem: Bool? = false,
         offers: [StoreOffer]? = nil,
         monstersDies: [MonsterDies]? = nil,
         pillarsTakeDamage: [PillarTakesDamage]? = nil,
         poisonColumnAttacks: [[TileCoord]]? = nil,
         poisonRowAttacks: [[TileCoord]]? = nil,
         playerTookDamage: [TileCoord]? = nil
    ) {
        self.tileTransformation = tileTransformation
        self.inputType = inputType
        self.endTiles = endTiles
        self.removed =  removed
        self.newTiles = newTiles
        self.shiftDown = shiftDown
        self.removedTilesContainGem = removedTilesContainGem
        self.offers = offers
        self.monstersDies = monstersDies
        self.pillarsTakeDamage = pillarsTakeDamage
        self.poisonColumnAttacks = poisonColumnAttacks
        self.poisonRowAttacks = poisonRowAttacks
        self.playerTookDamage = playerTookDamage
    }
    
    static var zero : Transformation {
        return Transformation()
    }
}
