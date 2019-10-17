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
    var endTilesStructs: [[Tile]]?
    
    init(transformation tileTransformation: [[TileTransformation]]? = nil,
         inputType: InputType? = nil,
         endTilesStructs: [[Tile]]? = nil) {
        self.tileTransformation = tileTransformation
        self.inputType = inputType
        self.endTilesStructs = endTilesStructs
    }
    
    static var zero : Transformation {
        return Transformation()
    }
}
