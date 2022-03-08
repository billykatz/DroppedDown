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
    
    var poisonColumnAttacks: [[TileCoord]]? = nil
    var poisonRowAttacks: [[TileCoord]]? = nil
    
    
    
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
         poisonRowAttacks: [[TileCoord]]? = nil
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
    }
    
    static var zero : Transformation {
        return Transformation()
    }
}
