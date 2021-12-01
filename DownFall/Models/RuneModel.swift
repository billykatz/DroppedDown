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
    case undo
    case flameColumn
    case fireball
    case drillDown
    case flipFlop
    case gemification
    case moveEarth
    case phoenix
    
    var humanReadable: String {
        switch self {
        case.getSwifty:
            return "Get Swifty"
        case .rainEmbers:
            return "Rain Embers"
        case .transformRock:
            return "Transform Rock"
        case .flameWall:
            return "Flame Wall"
        case .bubbleUp:
            return "Bubble Up"
        case .vortex:
            return "Vortex"
        case .undo:
            return "Undo"
        case .flameColumn:
            return "Flame Column"
        case .fireball:
            return "Fireball"
        case .drillDown:
            return "Drill Down"
        case .flipFlop:
            return "Flip Flop"
        case .gemification:
            return "Gemify"
        case .moveEarth:
            return "Move Earth"
        case .phoenix:
            return "Phoenix"
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
    
    var isCharged: Bool {
        return rechargeCurrent >= cooldown
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
    
    static func rune(for type: RuneType, isCharged: Bool = false) -> Rune {
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
                        rechargeType: [TileType.rock(color: .blue, holdsGem: false, groupCount: 0)],
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
                        flavorText: "Barney was a red dinosaur before running into me. - Durham the Dwarf",
                        targets: 3,
                        targetTypes: TileType.rockCases,
                        affectSlopes: [],
                        affectRange: 0,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
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
                        rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
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
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
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
                flavorText: "You bumped into the ceiling which now has to be washed and sterilized, so you get nothing, good day sir!",
                targets: 1,
                targetTypes: [.player(.playerZero)],
                affectSlopes: [],
                affectRange: 0,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .blue, holdsGem: false, groupCount: 0)],
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
                description: "In 3x3 area, monsters become rocks and rocks become monsters",
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
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "vortexSpriteSheet",
                animationColumns: 5
            )
            
        case .undo:
            return Rune(
                type: .undo,
                textureName: "rune-reversereverse-on",
                cost: 0,
                currency: .gem,
                description: "Undo your most recent move",
                flavorText:
                    """
                "Oopsies! Let's see if this works in real life" - Cal the Mathematician
                """
                ,
                targets: 0,
                targetTypes: [],
                affectSlopes: [],
                affectRange: 1,
                heal: 0,
                cooldown: 5,
                rechargeType: [.monster(.zero)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .blood,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )
        case .flameColumn:
            return Rune(
                type: .flameColumn,
                textureName: "rune-flame-column-off",
                cost: 0,
                currency: .gem,
                description: "Create a vertical flame wall",
                flavorText: "Careful where you stand",
                targets: 1,
                targetTypes: [],
                affectSlopes: [AttackSlope(over: 0, up: 1), AttackSlope(over: 0, up: -1)],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: isCharged ? 25 : 0,
                progressColor: .red,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "flameWallSpriteSheet",
                animationColumns: 5
            )
            
        case .fireball:
            return Rune(
                type: .fireball,
                textureName: "rune-fireball-off",
                cost: 0,
                currency: .gem,
                description: "Fling a fireball at a monster.",
                flavorText: "The only thing worse than fire is a pyro who loves fires.",
                targets: 1,
                targetTypes: [TileType.monster(.zero)],
                affectSlopes: [],
                affectRange: 0,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "rainEmbersSpriteSheet",
                animationColumns: 5
            )
            
        case .drillDown:
            return Rune(
                type: .drillDown,
                textureName: "rune-drilldown-off",
                cost: 0,
                currency: .gem,
                description: "Move all the way to the bottom. Destroy all tiles along the way.",
                flavorText: "A straight line isn't always the fastest way to the bottom, but in this case it is.",
                targets: 1,
                targetTypes: [.player(.playerZero)],
                affectSlopes: [AttackSlope(over: 0, up: -1)],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )
            
        case .flipFlop:
            return Rune(
                type: .flipFlop,
                textureName: "rune-flipflop-off",
                cost: 0,
                currency: .gem,
                description: "Flip the board horizontally or vertically",
                flavorText: "Hold my mead, I'm gonna try something crazy - Marv the Earthmover",
                targets: 1,
                targetTypes: [],
                affectSlopes: [],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )

        case .gemification:
            return Rune(
                type: .gemification,
                textureName: "rune-gemification-off",
                cost: 0,
                currency: .gem,
                description: "Infuse a rock with a gem.",
                flavorText: "The dwarf queen, Emeralelda, bestowed the first rune of its kind to her first born daughter, Gemma.",
                targets: 1,
                targetTypes: TileType.rockCases,
                affectSlopes: [],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )
        case .moveEarth:
            return Rune(
                type: .moveEarth,
                textureName: "rune-moveearth-off",
                cost: 0,
                currency: .gem,
                description: "Swap your row with another.",
                flavorText: "Marv the Earthmover loved mead so much that he created the world's first bar with the flick of his wrist.",
                targets: 1,
                targetTypes: TileType.rockCases,
                affectSlopes: [],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )

        case .phoenix:
            return Rune(
                type: .phoenix,
                textureName: "rune-phoenix-off",
                cost: 0,
                currency: .gem,
                description: "If you would die, instead destroy this rune and heal fully.",
                flavorText: "Life and death are partners.",
                targets: 1,
                targetTypes: [.player(.playerZero)],
                affectSlopes: [],
                affectRange: Int.max,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: Int.max,
                animationTextureName: "",
                animationColumns: 0
            )

        }
    }
}
