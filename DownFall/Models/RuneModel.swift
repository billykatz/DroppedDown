//
//  RuneModel.swift
//  DownFall
//
//  Created by Katz, Billy on 5/6/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

enum RuneType: String, Codable, Hashable {
    case rainEmbers
    case getSwifty
    case transformRock
    
    var humanReadable: String {
        switch self {
        case.getSwifty:
            return "Get Swifty"
        case .rainEmbers:
            return "Rain Embers"
        case .transformRock:
            return "Trasnformer Rock"
        }
    }
}

struct Rune: Hashable, Decodable {
    var type: RuneType
    var textureName: String
    var cost: Int
    var currency: Currency
    var description: String
    var flavorText: String?
    var targets: Int?
    var targetTypes: [TileType]?
    var heal: Int?
    var cooldown: Int
    var rechargeType: [TileType]
    var rechargeMinimum: Int
    var progressColor: Color
    var maxDistanceBetweenTargets: Int
    var recordedProgress: CGFloat? = 0
    let animationTextureName: String
    let animationColumns: Int
    
    var animationTexture: SKTexture {
        return SKTexture(imageNamed: animationTextureName)
    }
    
    var fullDescription: String {
        return
            """
            Effect: \(description)
            Charges: Mine \(cooldown) \(rechargeTypeString)\(cooldown > 1 ? "s" : "").
            """
    }
    
    var rechargeTypeString: String {
        if let first = rechargeType.first {
            return first.humanReadable
        }
        return ""
    }
    
    static let zero = Rune(type: .getSwifty, textureName: "", cost: 0, currency: .gem, description: "", flavorText: "", targets: 0, targetTypes: [], heal: 0, cooldown: 0, rechargeType: [], rechargeMinimum: 0, progressColor: .red, maxDistanceBetweenTargets: 0, animationTextureName: "", animationColumns: 0)
    
    static func rune(for type: RuneType) -> Rune {
        switch type {
        case .getSwifty:
            var cases = TileType.rockCases
            cases.append(TileType.player(.playerZero))
            
            return Rune(type: .getSwifty,
                        textureName: "getSwifty",
                        cost: 0,
                        currency: .gem,
                        description: "Swap places with an adjacent rock.",
                        flavorText: "Show them the meaning of swift.",
                        targets: 2,
                        targetTypes: cases,
                        heal: 0,
                        cooldown: 5,
                        rechargeType: [TileType.rock(.blue)],
                        rechargeMinimum: 1,
                        progressColor: .blue,
                        maxDistanceBetweenTargets: 1,
                        animationTextureName: "getSwiftySpriteSheet",
                        animationColumns: 6
            )
        case .transformRock:
            return Rune(type: .transformRock,
                        textureName: "transformRock",
                        cost: 0,
                        currency: .gem,
                        description: "Transform 3 rocks into purple.",
                        flavorText: "Barney was one a red dinosaur before running into me. - Durham the Dwarf",
                        targets: 3,
                        targetTypes: TileType.rockCases,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(.purple)],
                        rechargeMinimum: 1,
                        progressColor: .purple,
                        maxDistanceBetweenTargets: Int.max,
                        animationTextureName: "transformRockSpriteSheet",
                        animationColumns: 8
            )
        case .rainEmbers:
            return Rune(type: .rainEmbers,
                        textureName: "rainEmbers",
                        cost: 0,
                        currency: .gem,
                        description: "Fling fireballs at two monsters.",
                        flavorText: "Fire is my second favorite word, second only to `combustion.` - Mack the Wizard",
                        targets: 2,
                        targetTypes: [TileType.monster(.zero)],
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(.red)],
                        rechargeMinimum: 1,
                        progressColor: .red,
                        maxDistanceBetweenTargets: Int.max,
                        animationTextureName: "rainEmbersSpriteSheet",
                        animationColumns: 5
            )
        }
    }
}
