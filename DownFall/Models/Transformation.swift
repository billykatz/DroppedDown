//
//  Transformation.swift
//  DownFall
//
//  Created by William Katz on 12/24/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

struct Transformation: Equatable, Hashable {
    let endTiles: [[TileType]]?
    var tileTransformation: [[TileTransformation]]?
    var inputType: InputType? = nil
    
    init(tiles endTiles: [[TileType]]? = nil,
         transformation tileTransformation: [[TileTransformation]]? = nil,
         inputType: InputType? = nil) {
        self.endTiles = endTiles
        self.tileTransformation = tileTransformation
        self.inputType = inputType
    }
    
    static var zero : Transformation {
        return Transformation.init(tiles: nil,
                                   transformation: nil,
                                   inputType: nil)
    }
}
