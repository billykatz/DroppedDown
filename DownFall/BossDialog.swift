//
//  BossDialog.swift
//  DownFall
//
//  Created by Billy on 1/26/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit


extension Dialogue {
    static let bossFullName = "Wallace"
    static let bossNickName = "Wally"
    static let bossPlayerMeetBoss: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Yikes! That’s \(bossNickName) and they don’t look like they want to let you pass. There must be a way to mine out of here.", emotion: .surprised),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsRocksToEat: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Not to backseat drive, but did ya notice that \(bossNickName) has different attacks based on what rocks it eats?", emotion: .skeptical),
                                                    Sentence(text: "Maybe if you get rid of some of them…", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossEatsThoseRocksYum: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Boss Eats Those Rocks, Yum", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)

    
    static let bossTargetsToAttackDynamite: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Did you notice that \(bossNickName) ate some red rocks earlier?", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsToAttackPoison: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "You might not want to stand under the acid-looking green stuff. I'm pretty sure \(bossNickName) ate blue rocks just now.", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsToAttackSpawnMonsters: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "I'm pretty sure after purple rocks get eaten then \(bossNickName)'s monsters show up", emotion: .surprised),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)

    static let bossPlayerTriggersFirstPhaseChange: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Way to go!", emotion: .surprised),
                                                    Sentence(text: "Uh oh. Looks like I spoke too soon.", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerTriggersSecondPhaseChange: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Nice! Almost there!", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerKillsBoss: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Woohoo! Let’s get out of here while \(bossNickName) still under those rocks. Your mining skills aren’t too shabby lately!", emotion: .surprised),
                                                    Sentence(text: "Nice work, let’s get out of here.", emotion: .surprised),
                                                    Sentence(text: "Phew! Alright let’s jet.", emotion: .surprised),
                                                    Sentence(text: "Well done!", emotion: .surprised),
                                                    Sentence(text: "Nice! Way to keep your *coal* on that one!", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerOnAWinStreak: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Sorry, \(bossFullName), having a rocky day, eh? He he he.", emotion: .skeptical),
                                                    Sentence(text: "\(bossNickName), your ceiling is looking a little er crumbly. Might want to get that looked at.", emotion: .skeptical),
                                                    Sentence(text: "Okay, \(bossNickName), are you letting us win?", emotion: .skeptical),
                                                    Sentence(text: "Kind of feels like we’ve been here before...", emotion: .skeptical),
                                                    Sentence(text: "...\t ...\nOh! Well done. Sorry, I wasn’t looking.", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerDestroysFirstPillar: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Nice shot with that pillar!... Maybe you're getting somewhere", emotion: .skeptical),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossIsGettingReadyToEatAgain: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Hey, Wally's looking kind of hungry.  Better get mining!", emotion: .surprised),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)

    
    
    
    static let bossPlayerDied: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Womp womp womppppppp", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)


    
}
