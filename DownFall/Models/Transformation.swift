//
//  Transformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//


struct Transformation: Equatable, Hashable {
    var tileTransformation: [[TileTransformation]]?
    var inputType: InputType? = nil
    var endTiles: [[Tile]]?
    
    init(transformation tileTransformation: [[TileTransformation]]? = nil,
         inputType: InputType? = nil,
         endTiles: [[Tile]]? = nil) {
        self.tileTransformation = tileTransformation
        self.inputType = inputType
        self.endTiles = endTiles
    }
    
    static var zero : Transformation {
        return Transformation()
    }
}
