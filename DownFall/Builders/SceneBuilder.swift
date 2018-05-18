//
//  SceneBuilder.swift
//  DownFall
//
//  Created by William Katz on 5/17/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol SceneBuilder : class {
    var foreground : SKNode! { get set }
    func addTileNodes(_ given: [[DFTileSpriteNode]])
    
    //data source stuff
    var mediator: SpriteMediator? { get set }
}

extension SceneBuilder where Self: SKScene {
    
    func addTileNodes(_ given : [[DFTileSpriteNode]]) {
        guard let tileSize = mediator?.getBoard().tileSize, let board = mediator?.getBoard() else { fatalError("No board injected") }
        var x : Int = 0
        var y : Int = 0
        for row in 0..<given.count {
            y = row * tileSize + board.bottomLeft.0
            for col in 0..<given.count {
                x = col * tileSize + board.bottomLeft.1
                given[row][col].position = CGPoint.init(x: x, y: y)
                foreground.addChild(given[row][col])
            }
        }
    }


}
