//
//  AnimationModel.swift
//  DownFall
//
//  Created by William Katz on 7/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

enum AnimationType: String, Decodable {
    case attack
    case hurt
    case dying
    case idle
    case fall
    case projectileStart
    case projectileMid
    case projectileEnd
}

struct AnimationModel: Equatable, Decodable {
    let animationFilename: String
    let numberOfFrames: Int
    let animationType: AnimationType
    var keyframe: Int?
    
    var texture: SKTexture? {
        if animationFilename.isEmpty { return nil }
        return SKTexture(imageNamed: animationFilename)
    }
    
    var animationTextures: [SKTexture]? {
        guard let texture = self.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: numberOfFrames).animationFrames()
    }
    
    static var zero = AnimationModel(animationFilename: "", numberOfFrames: 0, animationType: .attack)
}
