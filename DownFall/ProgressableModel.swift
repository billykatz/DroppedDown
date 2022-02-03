//
//  CodexViewModel.swift
//  DownFall
//
//  Created by Billy on 9/3/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine


/*
 There are a few different types of items in the game:
   - permanent upgrades: these are things like upgrades to health, dodge, and luck, extra rune slots, and the ability to unlock a 3rd goal
     - health upgrade, level 1-4
     - dodge upgrade, level 1-4
     - luck upgrade, level 1-4
     - runes slots, level 1-4
     - unlock a 3rd level goal
   - one-time use potions: these are things like the transmogrify.  they can appear in levels
     - each item can be unlcok
   - runes: some runes are in the starting game pool but others can be unlocked and purchased so they appear in future runs
 
 Items introduced into the game need to be represented in multiple UIs:
   - In the Progress view
   - Some need to  the game view
 
 Items can be in multiple states:
    - locked or unlocked
    - not purchased or purchased
 
 In the progress view players can:
    - view unlocked items
    - view locked items
    - buy unlocked items

 */

enum CodexSections: String, CaseIterable, Identifiable {
    case items
    case runes
    case playerUpgrades
    case misc
    
    static var availableInRun: [CodexSections] = [.items, .runes]
    static var permanentUpgrades: [CodexSections] = [.playerUpgrades, .misc]
    
    var id: String {
        return self.rawValue
    }
    
    var header: String {
        switch self {
        case .items: return "Items"
        case .runes: return "Runes"
        case .playerUpgrades: return "Stats"
        case .misc: return "Pickaxe"
        }
    }
}

class CodexViewModel: ObservableObject {
    
    public let sections = CodexSections.allCases
    
    public let availableInRun = CodexSections.availableInRun
    public let permanentUpgrades = CodexSections.permanentUpgrades
    
    @Published var unlockables: [Unlockable] = []
    @Published var gemAmount: Int = 0
    
    private let profileViewModel: ProfileViewModel
    private var profile: Profile
    private let profilePublisher: AnyPublisher<Profile, Never>
    private var profileCancellable = Set<AnyCancellable>()
    private weak var codexCoordinator: CodexCoordinator?
    
    private var playerData: EntityModel {
        return profile.player
    }
    
    private var statData: [Statistics] {
        return profile.stats
    }

    init(profileViewModel: ProfileViewModel, codexCoordinator: CodexCoordinator) {
        self.profileViewModel = profileViewModel
        self.profile = profileViewModel.profile
        self.unlockables = profile.unlockables
        self.codexCoordinator = codexCoordinator
        self.profilePublisher = profileViewModel.profilePublisher
        
        profilePublisher.sink { [weak self] newProfile in
            self?.profile = newProfile
            self?.unlockables = newProfile.unlockables
            self?.gemAmount = newProfile.player.carry.total(in: .gem)
        }.store(in: &profileCancellable)

        profileViewModel.checkUnlockables()
    }
    
    
    //API
    func unlockables(in section: CodexSections) -> [Unlockable] {
        var unlockablesInSection: [Unlockable] = []
        for unlockable in unlockables {
            switch unlockable.item.type {
            case .dodge, .luck, .plusOneMaxHealth:
                if section == .playerUpgrades {
                    unlockablesInSection.append(unlockable)
                }
            case .luckyCat, .wingedBoots:
                if section == .items {
                    unlockablesInSection.append(unlockable)
                }       
            case .rune where section == .runes:
                unlockablesInSection.append(unlockable)
            case .killMonsterPotion, .greaterHeal, .lesserHeal, .transmogrifyPotion, .plusTwoMaxHealth:
                if section == .items {
                    unlockablesInSection.append(unlockable)
                }
            case .runeSlot where section == .misc:
                unlockablesInSection.append(unlockable)
            default:
                break
            }
        }
        return unlockablesInSection
    }
    
    func purchaseUnlockable(unlockable: Unlockable) {
        codexCoordinator?.updateUnlockable(unlockable)
    }
    
    func playerCanAfford(unlockable: Unlockable) -> Bool {
        return playerData.canAfford(unlockable.purchaseAmount, inCurrency: .gem)
    }
    
    
    func relevantStatForUnlockable(_ unlockable: Unlockable) -> Statistics {
        guard let stat = statData.first(where:
                                            { stat in
                                                stat.statType == unlockable.stat.statType
                                                    && stat.rockColor == unlockable.stat.rockColor
                                                    && stat.gemColor == unlockable.stat.gemColor
                                                    && stat.monsterType == unlockable.stat.monsterType
                                                    && stat.runeType == unlockable.stat.runeType
                                            }) else { preconditionFailure() }
        return stat
    }
    
    func amountNeededToUnlock(_ unlockable: Unlockable) -> Int {
        return relevantStatForUnlockable(unlockable).amount
    }
    
    func unlockAt(_ unlockable: Unlockable) -> String {
        let target = unlockable.stat.amount
        let relevantPlayerStat = relevantStatForUnlockable(unlockable)
        let current = relevantPlayerStat.amount
        
        var value: String = ""
        var subject: String = ""
        
        if let rockColor = relevantPlayerStat.rockColor {
            value += "Mine"
            subject = "\(rockColor) rocks"
        } else if let gemColor = relevantPlayerStat.gemColor {
            value += "Collect"
            subject = "\(gemColor) gems"
        } else if let monsterType = relevantPlayerStat.monsterType {
            value += "Kill"
            subject = "\(monsterType.humanReadable) monsters"
        } else if let runeType = relevantPlayerStat.runeType {
            value += "Use \(runeType.humanReadable)"
            subject = "times"
        } else if relevantPlayerStat.statType == .totalRocksDestroyed {
            value += "Mine"
            subject = "rocks"
        } else if relevantPlayerStat.statType == .totalGemsCollected {
            value += "Collect"
            subject = "gems"
        } else if relevantPlayerStat.statType == .totalMonstersKilled {
            value += "Kill"
            subject = "monsters"
        } else if relevantPlayerStat.statType == .totalRuneUses {
            value += "Use runes"
            subject = "times"
        } else if relevantPlayerStat.statType == .largestRockGroupDestroyed {
            return "Mine a group of \(target) rocks to unlock this."
        } else if relevantPlayerStat.statType == .lowestDepthReached {
            return "Reach depth \(target) to unlock this."
        }
        
        value += " \(target - current) more \(subject) to unlock this."
        return value
    }
    
    
}
