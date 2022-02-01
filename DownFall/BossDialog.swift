//
//  BossDialog.swift
//  DownFall
//
//  Created by Billy on 1/26/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation


extension Dialogue {
    static let bossPlayerMeetBoss: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Player Meet Boss", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsRocksToEat: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Boss Targets Rocks To Eat", emotion: .content),
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
                                                    Sentence(text: "Boss About to Throw Dynamite", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsToAttackPoison: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Boss About to Spew Poison, Yuck", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossTargetsToAttackSpawnMonsters: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Boss About to Spawn Monsters, Yikes", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)

    static let bossPlayerTriggersFirstPhaseChange: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Nice job keep going.  Phase 1 -> 2", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerTriggersSecondPhaseChange: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "How long will this go on?  Phase 2 -> 3", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerKillsBoss: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Is it over?? Holy crap, you did it!", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossPlayerDestroysFirstPillar: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Whoa, that did something. Keep doing that!!", emotion: .content),
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let bossIsGettingReadyToEatAgain: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Hmmm, the boss's eyes are changing from red to yellow.  I wonder if it is getting hungry...", emotion: .content),
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
