//
//  GameScope.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

struct GameScope {
    static let boardSizeCoefficient = CGFloat(0.9)
    static var shared: GameScope = GameScope(difficulty: .normal)
    var difficulty: Difficulty
    
    var tutorials: [TutorialData] = [GameScope.tutorialOne, GameScope.tutorialTwo]
    
    static let tutorialOne = TutorialData(steps:
        [
                    TutorialStep(dialog: "Welcome to Shift Shaft! You're a coal miner with extraordinary powers",
                                 highlightType: [.player(.zero)],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "This is a rare gemstone, let's collect it!",
                                 highlightType: [.gem],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "You can mine groups of rocks of three or more.  Tap on the rock grouping to mine them away.",
                                 highlightType: TileType.rockCases,
                                 inputToContinue: InputType.animationsFinished(ref: true)),
                    TutorialStep(dialog: "You're very close to the gem, but you can only fall down",
                                 highlightType: [.gem],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero),
                                 inputToEnter: InputType.animationsFinished(ref: false)),
                    TutorialStep(dialog: "Fear not! You can use your powers to rotate the board and fall on to the gem",
                                 highlightType: [],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "Rotate to collect the gem",
                                 highlightType: [],
                                 showClockwiseRotate: true,
                                 inputToContinue: InputType.rotateCounterClockwise(preview: false))
        ]
    )
    
    static let tutorialTwo = TutorialData(steps:
        [
                    TutorialStep(dialog: "That's an awesome pick axe, let's put it to good use!",
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "That's a baddie.  Baddies are bad.  Tap on it to see where it attacks",
                                 highlightType: [.monster(.zero)],
                                 tapToContinue: false,
                                 inputToContinue: InputType.touch(TileCoord(0, 2), .monster(.zero)),
                                 showFinger: true),
                    TutorialStep(dialog: "It will attack you if you land on either side of it.",
                                 highlightCoordinates: [TileCoord(0, 1), TileCoord(0, 3)],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero),
                                 inputToEnter: .animationsFinished(ref: false)),
                    TutorialStep(dialog: "All enemies are weak when attacked from above.  Mine some rocks and kill that rat!",
                                 highlightType: [],
                                 tapToContinue: false,
                                 inputToContinue: InputType.monsterDies(.zero, .wizard))
        ]
    )
}

