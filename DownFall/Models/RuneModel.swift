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

extension TileType {
    static var runeAllCases: [TileType] = [.rock(color: .blue, holdsGem: false, groupCount: 0),
                                           .rock(color: .red, holdsGem: false, groupCount: 0),
                                           .rock(color: .purple, holdsGem: false, groupCount: 0),
                                           .rock(color: .brown, holdsGem: false, groupCount: 0),
                                           .player(.playerZero),
                                           .monster(.zero),
                                           .dynamite(.standardFuse),
                                           .offer(.zero),
                                           .item(.gem),
                                           .pillar(.random),
                                           .exit(blocked: false),
                                           .empty,
                                           .emptyGem(.blue, amount: 1),
    
    ]
}

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
    case fieryRage
    case teleportation
    case monsterBrawl
    
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
        case .fieryRage:
            return "Fiery Rage"
        case .teleportation:
            return "Teleportation to Exit"
        case .monsterBrawl:
            return "Monster Brawl"
        }
    }
}

extension Rune {
    static func ==(_ lhsRune: Rune, _ rhsRune: Rune) -> Bool {
        return lhsRune.type == rhsRune.type
    }
}

struct EndEffectTile: Hashable, Codable {
    let tileTypes: [TileType]
    let inclusive: Bool
}

struct ConstrainedTargets: Hashable, Codable {
    let constraintedTypes: [TileType]
    let nearByType: [TileType]
    let maxDistance: CGFloat
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
    var constrainedTargets: ConstrainedTargets?
    var affectSlopes: [AttackSlope]
    var affectRange: Int
    var stopsEffectTypes: EndEffectTile?
    var heal: Int?
    var cooldown: Int
    var rechargeType: [TileType]
    var rechargeMinimum: Int
    var rechargeCurrent: Int
    var progressColor: ShiftShaft_Color
    var maxDistanceBetweenTargets: CGFloat
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
                constrainedTargets: ConstrainedTargets? = nil,
                affectSlopes: [AttackSlope]? = nil,
                affectRange: Int? = nil,
                stopsEffectTypes: EndEffectTile? = nil,
                cooldown: Int? = nil,
                rechargeType: [TileType]? = nil,
                rechargeMinimum: Int? = nil,
                rechargeCurrent: Int? = nil,
                progressColor: ShiftShaft_Color? = nil,
                maxDistanceBetweenTargets: CGFloat? = nil,
                animationTextureName: String? = nil,
                animationColumns: Int? = nil) -> Rune {
        
        let type = type ?? self.type
        let textureName = textureName ?? self.textureName
        let cost = cost ?? self.cost
        let currency = currency ?? self.currency
        let description = description ?? self.description
        let flavorText = flavorText ?? self.flavorText
        let targets = targets ?? self.targets
        let targetTypes = targetTypes ?? self.targetTypes
        let constrainedTypes = constrainedTargets ?? self.constrainedTargets
        let affectSlopes = affectSlopes ?? self.affectSlopes
        let affectRange = affectRange ?? self.affectRange
        let stopsEffectTypes = stopsEffectTypes ?? self.stopsEffectTypes
        let heal = heal ?? self.heal
        let cooldown = cooldown ?? self.cooldown
        let rechargeType = rechargeType ?? self.rechargeType
        let rechargeMinimum = rechargeMinimum ?? self.rechargeMinimum
        let rechargeCurrent = rechargeCurrent ?? self.rechargeCurrent
        let progressColor = progressColor ?? self.progressColor
        let maxDistanceBetweenTargets = maxDistanceBetweenTargets ?? self.maxDistanceBetweenTargets
        let recordedProgress = recordedProgress ?? self.recordedProgress
        let animationTextureName = animationTextureName ?? self.animationTextureName
        let animationColumns = animationColumns ?? self.animationColumns
        
        
        return Rune(type: type,
                    textureName: textureName,
                    cost: cost,
                    currency: currency,
                    description: description,
                    flavorText: flavorText,
                    targets: targets,
                    targetTypes: targetTypes,
                    constrainedTargets: constrainedTypes,
                    affectSlopes: affectSlopes,
                    affectRange: affectRange,
                    stopsEffectTypes: stopsEffectTypes,
                    heal: heal,
                    cooldown: cooldown,
                    rechargeType: rechargeType,
                    rechargeMinimum: rechargeMinimum,
                    rechargeCurrent: rechargeCurrent,
                    progressColor: progressColor,
                    maxDistanceBetweenTargets: maxDistanceBetweenTargets,
                    recordedProgress: recordedProgress,
                    animationTextureName: animationTextureName,
                    animationColumns: animationColumns
                )
        
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
                        constrainedTargets: ConstrainedTargets(constraintedTypes: TileType.rockCases, nearByType: [.player(.playerZero)], maxDistance: 1),
                        affectSlopes: [],
                        affectRange: 0,
                        stopsEffectTypes: nil,
                        heal: 0,
//                cooldown: 25,
                        cooldown: 5,
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
                        constrainedTargets: nil,
                        affectSlopes: [],
                        affectRange: 0,
                        stopsEffectTypes: nil,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                        rechargeMinimum: 1,
                        rechargeCurrent: 0,
                        progressColor: .purple,
                        maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                        constrainedTargets: nil,
                        affectSlopes: [],
                        affectRange: 0,
                        stopsEffectTypes: nil,
                        heal: 0,
                        cooldown: 25,
                        rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                        rechargeMinimum: 1,
                        rechargeCurrent: 0,
                        progressColor: .red,
                        maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [AttackSlope(over: -1, up: 0), AttackSlope(over: 1, up: 0)],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [AttackSlope(over: 0, up: 1)],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                //                cooldown: 25,
                cooldown: 5,
                rechargeType: [TileType.rock(color: .blue, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .blue,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: AttackSlope.allDirections,
                affectRange: 1,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: 1,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 5,
                rechargeType: [.monster(.zero)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .blood,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [AttackSlope(over: 0, up: 1), AttackSlope(over: 0, up: -1)],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 25,
                progressColor: .red,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: 0,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "rainEmbersSpriteSheet",
                animationColumns: 5
            )
            
        case .drillDown:
            return Rune(
                type: .drillDown,
                textureName: "rune-drilldown-off",
                cost: 0,
                currency: .gem,
                description: "Drill down until you reach the bottom of the board or a non-destructible tile.",
                flavorText: "A straight line isn't always the fastest way to the bottom, but in this case it is.",
                targets: 1,
                targetTypes: [.player(.playerZero)],
                constrainedTargets: nil,
                affectSlopes: [AttackSlope(over: 0, up: -1)],
                affectRange: Int.max,
                stopsEffectTypes: EndEffectTile(tileTypes: [.exit(blocked: false), .exit(blocked: true), .item(.zero), .gem, .pillar(.random), .dynamite(.standardFuse), .offer(.zero)], inclusive: false),
                heal: 0,
//                cooldown: 25,
                cooldown: 5,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "rune-drilldown-spriteSheet4",
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
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .purple,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "",
                animationColumns: 0
            )
        case .moveEarth:
            return Rune(
                type: .moveEarth,
                textureName: "rune-moveearth-on",
                cost: 0,
                currency: .gem,
                description: "Swap your row with another row.",
                flavorText: "Marv the Earthmover loved mead so much that he created the world's first bar with the flick of his wrist.",
                targets: 2,
                targetTypes: TileType.runeAllCases,
                constrainedTargets: nil,
                affectSlopes: [AttackSlope(over: 1, up: 0), AttackSlope(over: -1, up: 0)],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 5,
                rechargeType: [TileType.rock(color: .purple, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 5,
                progressColor: .purple,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
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
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 25,
                rechargeType: [TileType.rock(color: .red, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 0,
                progressColor: .red,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "",
                animationColumns: 0
            )
            
        case .fieryRage:
            return Rune(
                type: .fieryRage,
                textureName: "rune-fireyrage-on",
                cost: 0,
                currency: .gem,
                description: "Throw a fireball above, below and to each side of you.",
                flavorText: "I discovered move by accident after losing a match of Cave Chess. - Margarey The Hothead ",
                targets: 1,
                targetTypes: [.player(.playerZero)],
                constrainedTargets: nil,
                affectSlopes: AttackSlope.orthogonalDirectionAttacks,
                affectRange: Int.max,
                stopsEffectTypes: EndEffectTile(tileTypes: [.monster(.zero)], inclusive: true),
                heal: 0,
                cooldown: 1,
                rechargeType: [TileType.monster(.zero)],
                rechargeMinimum: 1,
                rechargeCurrent: 1,
                progressColor: .blood,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "rainEmbersSpriteSheet",
                animationColumns: 5
            )
            
        case .teleportation:
            var constrainedTypes = TileType.rockCases
            constrainedTypes.append(.monster(.zero))
            constrainedTypes.append(.dynamite(.standardFuse))
            constrainedTypes.append(.offer(.zero))
            constrainedTypes.append(.item(.gem))
            let constrained = ConstrainedTargets.init(constraintedTypes: constrainedTypes, nearByType: [.exit(blocked: false), .exit(blocked: true)], maxDistance: 1)
            
            var targets = constrainedTypes
            targets.append(TileType.player(.playerZero))
            
            return Rune(
                type: .teleportation,
                textureName: "rune-teleport-enabled",
                cost: 0,
                currency: .gem,
                description: "Swap places with a tile adjacent to the exit",
                flavorText: "[Olivia the Cunning]",
                targets: 2,
                targetTypes: targets,
                constrainedTargets: constrained,
                affectSlopes: [],
                affectRange: Int.max,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 5,
                rechargeType: [.rock(color: .blue, holdsGem: false, groupCount: 0)],
                rechargeMinimum: 1,
                rechargeCurrent: 5,
                progressColor: .blue,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "getSwiftySpriteSheet",
                animationColumns: 6
            )
            
        case .monsterBrawl:
//            rune-monster-brawl-on
            return Rune(
                type: .monsterBrawl,
                textureName: "rune-monster-brawl-on",
                cost: 0,
                currency: .gem,
                description: "Force all monsters to attack and hurt eachother.",
                flavorText: "I've found the easiest way to dispatch multiple monsters at once is to do nothing at all",
                targets: Int.max,
                targetTypes: [.monster(.zero)],
                constrainedTargets: nil,
                affectSlopes: [],
                affectRange: 0,
                stopsEffectTypes: nil,
                heal: 0,
                cooldown: 1,
                rechargeType: [TileType.monster(.zero)],
                rechargeMinimum: 1,
                rechargeCurrent: 1,
                progressColor: .blood,
                maxDistanceBetweenTargets: CGFloat.greatestFiniteMagnitude,
                animationTextureName: "",
                animationColumns: 0
            )

        }
        
    }
}
