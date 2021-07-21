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

enum RuneType: String, Codable, Hashable, CaseIterable {
    case rainEmbers
    case getSwifty
    case transformRock
    case flameWall
    case bubbleUp
    case vortex
    
    var humanReadable: String {
        switch self {
        case.getSwifty:
            return "Get Swifty"
        case .rainEmbers:
            return "Rain Embers"
        case .transformRock:
            return "Transformer Rock"
        case .flameWall:
            return "Flame Wall"
        case .bubbleUp:
            return "Bubble Up"
        case .vortex:
            return "Vortex"
        }
    }
}

extension Rune {
    static func ==(_ lhsRune: Rune, _ rhsRune: Rune) -> Bool {
        return lhsRune.type == rhsRune.type
    }
}

struct Rune: Hashable, Codable {
    var type: RuneType
    var textureName: String
    var cost: Int
    var currency: Currency
    var description: String
    var flavorText: String?
    var targets: Int?
    var targetTypes: [TileType]?
    var affectSlopes: [AttackSlope]
    var affectRange: Int
    var heal: Int?
    var cooldown: Int
    var rechargeType: [TileType]
    var rechargeMinimum: Int
    var rechargeCurrent: Int
    var progressColor: ShiftShaft_Color
    var maxDistanceBetweenTargets: Int
    var recordedProgress: CGFloat? = 0
    let animationTextureName: String
    let animationColumns: Int
    
    var animationTexture: SKTexture {
        SKTexture(imageNamed: animationTextureName)
    }
    
    var fullDescription: String {
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
    
    func update(type: RuneType? = nil,
                textureName: String? = nil,
                cost: Int? = nil,
                currency: Currency? = nil,
                description: String? = nil,
                flavorText: String? = nil,
                targets: Int? = nil,
                targetTypes: [TileType]? = nil,
                affectSlopes: [AttackSlope]? = nil,
                affectRange: Int? = nil,
                cooldown: Int? = nil,
                rechargeType: [TileType]? = nil,
                rechargeMinimum: Int? = nil,
                rechargeCurrent: Int? = nil,
                progressColor: ShiftShaft_Color? = nil,
                maxDistanceBetweenTargets: Int? = nil,
                animationTextureName: String? = nil,
                animationColumns: Int? = nil) -> Rune {
        return Rune(type: type ?? self.type,
                    textureName: textureName ?? self.textureName,
                    cost: cost ?? self.cost,
                    currency: currency ?? self.currency,
                    description: description ?? self.description,
                    flavorText: flavorText ?? self.flavorText,
                    targets: targets ?? self.targets,
                    targetTypes: targetTypes ?? self.targetTypes,
                    affectSlopes: affectSlopes ?? self.affectSlopes,
                    affectRange: affectRange ?? self.affectRange,
                    heal: heal ?? self.heal,
                    cooldown: cooldown ?? self.cooldown,
                    rechargeType: rechargeType ?? self.rechargeType,
                    rechargeMinimum: rechargeMinimum ?? self.rechargeMinimum,
                    rechargeCurrent: rechargeCurrent ?? self.rechargeCurrent,
                    progressColor: progressColor ?? self.progressColor,
                    maxDistanceBetweenTargets: maxDistanceBetweenTargets ?? self.maxDistanceBetweenTargets,
                    recordedProgress: recordedProgress ?? self.recordedProgress,
                    animationTextureName: animationTextureName ?? self.animationTextureName,
                    animationColumns: animationColumns ?? self.animationColumns)
        
    }
    
    func resetProgress() -> Rune {
        return update(rechargeCurrent: 0)
    }

    
    func progress(_ units: Int) -> Rune {
        return update(rechargeCurrent: min(rechargeCurrent+units, cooldown))
    }
    
    func textureName(isEnabled: Bool) -> String {
        return  textureName + "-enabled"
    }
    
    static let zero = Rune(type: .getSwifty, textureName: "", cost: 0, currency: .gem, description: "", flavorText: "", targets: 0, targetTypes: [], affectSlopes: [], affectRange: 0, heal: 0, cooldown: 0, rechargeType: [], rechargeMinimum: 0, rechargeCurrent: 0, progressColor: .red, maxDistanceBetweenTargets: 0, animationTextureName: "", animationColumns: 0)
    
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
                        affectSlopes: [],
                        affectRange: 0,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .blue, holdsGem: false)],
                        rechargeMinimum: 1,
                        rechargeCurrent: 0,
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
                        affectSlopes: [],
                        affectRange: 0,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .purple, holdsGem: false)],
                        rechargeMinimum: 1,
                        rechargeCurrent: 0,
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
                        affectSlopes: [],
                        affectRange: 0,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .red, holdsGem: false)],
                        rechargeMinimum: 1,
                        rechargeCurrent: 0,
                        progressColor: .red,
                        maxDistanceBetweenTargets: Int.max,
                        animationTextureName: "rainEmbersSpriteSheet",
                        animationColumns: 5
            )
        case .flameWall:
            return Rune(
                type: .flameWall,
                textureName: "flameWall",
                cost: 0,
                currency: .gem,
                description: "Create a horizontal flame wall",
                flavorText: "Kill them all",
                targets: 1,
                targetTypes: [],
                affectSlopes: [AttackSlope(over: -1, up: 0), AttackSlope(over: 1, up: 0)],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "flameWallSpriteSheet",
                animationColumns: 5
            )
            
        case .bubbleUp:
            return Rune(
                type: .bubbleUp,
                textureName: "bubbleUp",
                cost: 0,
                currency: .gem,
                description: "Float to the top of the board",
                flavorText: "You bumped into the ceiling which now has to be washed and sterilized, so you get nothing!",
                targets: 1,
                targetTypes: [TileType.player(.playerZero)],
                affectSlopes: [],
                affectRange: 0,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .blue, holdsGem: false)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .blue,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "rainEmbersSpriteSheet",
                animationColumns: 5
            )
        case .vortex:
            return Rune(
                type: .vortex,
                textureName: "vortex",
                cost: 0,
                currency: .gem,
                description: "Turns each monster into a rock and each rock into a monster within a 3 by 3 area.",
                flavorText:
                """
                "Ah, I see my error-- it was only suppose to be a teaspoon of bat's wing" - Dunvain the Careless
                """
                ,
                targets: 1,
                targetTypes: [],
                affectSlopes: AttackSlope.allDirections,
                affectRange: 1,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "vortexSpriteSheet",
                animationColumns: 5
            )

        }
    }
}
