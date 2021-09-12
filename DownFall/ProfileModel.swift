//
//  ProfileModel.swift
//  DownFall
//
//  Created by Billy on 6/23/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


struct Profile: Codable, Equatable {
    static var zero = Profile(name: "zero", progress: 0, player: .zero, currentRun: nil, deepestDepth: 0, progressModel: ProgressableModel())
    
    let name: String
    let progress: Int
    let player: EntityModel
    var currentRun: RunModel?
    var randomRune: Rune?
    let deepestDepth: Int
    let progressModel: ProgressableModel
    
    var runPlayer: EntityModel {
        guard let rune = randomRune else {
            return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: []))
        }
        return player.update(pickaxe: Pickaxe(runeSlots: 1, runes: [rune]))
    }
    
    func updatePlayer(_ entityModel: EntityModel) -> Profile {
        return Profile(name: name, progress: progress + 1, player: entityModel, currentRun: currentRun, deepestDepth: deepestDepth, progressModel: progressModel)
    }
    
    func updateRunModel(_ currentRun: RunModel?) -> Profile {
        return Profile(name: name, progress: progress + 1, player: player, currentRun: currentRun, deepestDepth: deepestDepth, progressModel: progressModel)
    }
    
    func updateDepth(_ depth: Int) -> Profile {
        let newDepth = depth > deepestDepth ? depth : deepestDepth
        return Profile(name: name, progress: progress + 1, player: player, currentRun: currentRun, deepestDepth: newDepth, progressModel: progressModel)
    }
    
    func updateProgress(_ progress: ProgressableModel) -> Profile {
        return Profile(name: name, progress: self.progress, player: player, currentRun: currentRun, deepestDepth: deepestDepth, progressModel: progress)
    }
    
    // just for debug purposes
    public mutating func givePlayerARandomRune() {
        let runeType = RuneType.allCases.randomElement()!
        randomRune = Rune.rune(for: runeType)
    }
        
}
