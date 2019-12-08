//
//  GameScope.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct GameScope {
    static var shared: GameScope = GameScope(difficulty: .normal)
    var difficulty: Difficulty
    
    static let tutorialOne = TutorialData(sections:
        [
            TutorialSection(steps:
                [
                    TutorialStep(dialog: "Welcome to the Mine! You're a coal minter with extraordinary powers",
                                 highlightType: [.player(.zero)],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "This is a rare gem, let's collect it!",
                                 highlightType: [.gold],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "These are rocks, you can destory them with a tap of your finger",
                                 highlightType: TileType.rockCases,
                                 inputToContinue: InputType.touch(.zero, .empty))
                ]
            ),
            TutorialSection(steps:
                [
                    TutorialStep(dialog: "You're very close to the gem, but you can only fall down",
                                 highlightType: [.gold],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "Fear not! You can use your powers to rotate the board and fall on to the gem",
                                 highlightType: [],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "Rotate to collect the gem",
                                            highlightType: [],
                                            showClockwiseRotate: true,
                                            inputToContinue: InputType.rotateCounterClockwise)
                ]
            )
        ]
    )
}

