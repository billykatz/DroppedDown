//
//  Dialogue.swift
//  DownFall
//
//  Created by Billy on 10/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum Emotion: String, Hashable, Codable {
    case content
    case skeptical
    case surprised
}

struct Sentence: Hashable, Codable {
    let text: String
    let emotion: Emotion
    
}

struct Dialogue: Hashable, Codable {
    let sentences: [Sentence]
    let character: Character
    let delayBeforeTyping: Double
}

extension Dialogue {
    static let thisIsYou: Dialogue = .init(sentences:
                                            [
                                                Sentence(text: "Hey! I'm Teri. This is you. We're in level 1 of the mines.", emotion: .content)
                                            ],
                                           character: .teri, delayBeforeTyping: 1.25)
    
    static let thisIsTheExit: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "This is the exit to get to the next level.", emotion: .content),
                                                    Sentence(text: "BUT it's blocked. You'll have to complete the level goals to get all those rocks out of the way.", emotion: .content),
                                                    
                                                    ],
                                               character: .teri, delayBeforeTyping: 0.25)
    
    static let theseAreLevelGoals: Dialogue = .init(sentences:
                                                        [
                                                            Sentence(text: "The level goals will show up at the start of each level.", emotion: .content),
                                                        ], character: .teri, delayBeforeTyping: 0.25)
    
    static let theseAreLevelGoalsInHUD: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "You can also find them by tapping up here in your HUD.", emotion: .content)
                                                            ],
                                                         character: .teri, delayBeforeTyping: 0.25)
    
    static let okayReadyToMineSomeRocks: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "Okay, ready to mine some rocks? Wait, you're a miner and you've never mined rocks? Fine.", emotion: .skeptical),
                                                                Sentence(text: "Try mining some rocks by tapping any group of 3 or more adjacent rocks of the same color.", emotion: .skeptical)
                                                                
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let youCanRotate: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "Amazing! Now rotate the board to get those gems.", emotion: .surprised),
                                                                Sentence(text: "Use the power of the anicent cave hieroglyphics to rotate the board.", emotion: .content),
                                                                
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let youCanRotateAgain: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "You won't get very far without rotating the board", emotion: .skeptical),
                                                                Sentence(text: "Swipe your finger across the screen to rotate the board.", emotion: .skeptical),
                                                                
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yikesAMonster: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "Look out! That's a monster.", emotion: .surprised),
                                                                Sentence(text: "The red dot means it's dormant, but once the dot turns green, it can attack you.", emotion: .skeptical),
                                                                Sentence(text:  "Tap on it to see how it attacks.", emotion: .content),
                                                               
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let killAMonster: Dialogue = .init(sentences:
                                                            [
                                                                Sentence(text: "Try landing on TOP of this monster to kill it", emotion: .content),
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yayMonsterDead1GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Phew! You did it.", emotion: .content),
                                                    Sentence(text: "You still need to mine a few more rocks to unlock the exit.", emotion: .content),
                                                    
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let yayMonsterDead2GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Phew! You did it.", emotion: .content),
                                                    Sentence(text: "I think you should get to the exit before more monsters show up.", emotion: .content),
                                                    Sentence(text: "Remember, the village is just past the Crystal River!", emotion: .content)
                                                    
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let levelGoalRewards: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "When you complete all the level goals you unblock the exit", emotion: .content),
                                                    Sentence(text: "Not only that, but each completed goal grants you the choice between two items.", emotion: .content),
                                                    Sentence(text: "When you collect one the other one disappears as an offering to the Mineral Sprits", emotion: .content)
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let youCanLeaveNow: Dialogue = .init(sentences:
                                                [
                                                    Sentence(text: "Once the exit unlocks monsters start to appear more frequently", emotion: .content),
                                                    Sentence(text: "I'd get out of there if I was you.", emotion: .skeptical),
                                                    
                                                    
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)



    
}
