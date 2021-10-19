//
//  Dialogue.swift
//  DownFall
//
//  Created by Billy on 10/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct Dialogue: Hashable, Codable {
    let sentences: [String]
    let character: Character
    let delayBeforeTyping: Double
}

extension Dialogue {
    static let thisIsYou: Dialogue = .init(sentences: ["Hey! I'm Teri. This is you. We're in level 1 of the mines."], character: .teri, delayBeforeTyping: 1.25)
    static let thisIsTheExit: Dialogue = .init(sentences: ["This is the exit to get to the next level.",
                                                           "BUT it's blocked. You'll have to complete the level goals to get all those rocks out of the way."],
                                               character: .teri,
                                               delayBeforeTyping: 0.25)
    static let theseAreLevelGoals: Dialogue = .init(sentences: ["The level goals will show up at the start of each level."], character: .teri, delayBeforeTyping: 0.25)
    static let theseAreLevelGoalsInHUD: Dialogue = .init(sentences: ["You can also find them by tapping up here in your HUD."], character: .teri, delayBeforeTyping: 0.25)
    static let okayReadyToMineSomeRocks: Dialogue = .init(sentences:
                                                            [
                                                                "Okay, ready to mine some rocks? Wait, you're a miner and you've never mined rocks? Fine.",
                                                                "Try mining some rocks by tapping any group of 3 or more adjacent rocks of the same color."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let youCanRotate: Dialogue = .init(sentences:
                                                            [
                                                                "You saw how things move down from the top when you mine?",
                                                                "You can also rotate the level by dragging it to affect how the board shifts.",
                                                                "Try getting to the gem you just uncovered."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yikesAMonster: Dialogue = .init(sentences:
                                                            [
                                                                "Look out! That's a monster.",
                                                                "The red dot means it's dormant, but once the dot turns green, it can attack you.",
                                                                "Tap on it to see how it attacks."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let killAMonster: Dialogue = .init(sentences:
                                                            [
                                                                "Try landing on TOP of this monster to kill it",
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yayMonsterDead1GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    "Phew! You did it.",
                                                    "You still need to mine a few more rocks to unlock the exit."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let yayMonsterDead2GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    "Phew! You did it.",
                                                    "I think you should get to the exit before more monsters show up.",
                                                    "Remember, the village is just past the Crystal River!"
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let levelGoalRewards: Dialogue = .init(sentences:
                                                [
                                                    "When you complete all the level goals you unblock the exit",
                                                    "Not only that, but each completed goal grants you the choice between two items.",
                                                    "When you collect one the other one disappears...",
                                                    "... no one knows what happens to the other item, some say the Mineral Spirits feed off it."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let youCanLeaveNow: Dialogue = .init(sentences:
                                                [
                                                    "Once the exit unlocks monsters start to appear more frequently",
                                                    "I'd get out of there if I was you."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)



    
}
