//
//  AnimationModel.swift
//  DownFall
//
//  Created by William Katz on 7/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol BuildAnimations {
    var attackAnimation: [SKTexture]? { get }
    var hurtAnimation: [SKTexture]? { get }
    var dyingAnimation: [SKTexture]? { get }
    var idleAnimation: [SKTexture]? { get }
    var fallAnimation: [SKTexture]? { get }
}

struct AllAnimationsModel: Equatable, Decodable {
    let attack: AnimationModel
    let hurt: AnimationModel
    let dying: AnimationModel
    let idle: AnimationModel
    let fall: AnimationModel
    
    static var zero = AllAnimationsModel(attack: .zero,
                                         hurt: .zero,
                                         dying: .zero,
                                         idle: .zero,
                                         fall: .zero)
    
}

struct AnimationModel: Equatable, Decodable {
    let animationFilename: String
    let numberOfFrames: Int
    
    var texture: SKTexture? {
        if animationFilename.isEmpty { return nil }
        return SKTexture(imageNamed: animationFilename)
    }
    
    static var zero = AnimationModel(animationFilename: "", numberOfFrames: 0)
}

extension AllAnimationsModel: BuildAnimations {
    var attackAnimation: [SKTexture]? {
        guard let texture = attack.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: attack.numberOfFrames).animationFrames()
    }
    
    var hurtAnimation: [SKTexture]? {
        guard let texture = hurt.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: hurt.numberOfFrames).animationFrames()
    }
    
    var dyingAnimation: [SKTexture]? {
        guard let texture = dying.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: dying.numberOfFrames).animationFrames()
    }
    
    var idleAnimation: [SKTexture]? {
        guard let texture = idle.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: idle.numberOfFrames).animationFrames()
    }
    
    var fallAnimation: [SKTexture]? {
        guard let texture = fall.texture else { return nil }
        return SpriteSheet(texture: texture,
                           rows: 1,
                           columns: fall.numberOfFrames).animationFrames()
    }
}

