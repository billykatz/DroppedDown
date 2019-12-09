//
//  TutorialView.swift
//  DownFall
//
//  Created by William Katz on 11/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class TutorialView: SKSpriteNode {
    
    let tutorialData: TutorialData
    
    init(tutorialData: TutorialData,
         texture: SKTexture?,
         color: UIColor,
         size: CGSize) {
        self.tutorialData = tutorialData
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
        
        
        Dispatch.shared.register { [weak self] (input) in
            guard let self = self else { return }
            if case let InputType.tutorial(step) = input.type {
                self.continueTutorial(step.dialog)
            }
            else if case InputType.newTurn = input.type {
                self.isUserInteractionEnabled = true
                let step = tutorialData.currentStep
                InputQueue.append(
                    Input(
                        .tutorial(step)
                    )
                )
            } else if case .boardBuilt = input.type {
                //START THE TUTORIAL

                let step = tutorialData.currentStep
                InputQueue.append(
                    Input(
                        .tutorial(step)
                    )
                )
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func continueTutorial(_ dialog: String) {
        if !InputType.fuzzyEqual(tutorialData.currentStep.inputToContinue, .tutorial(.zero)) {
            self.isUserInteractionEnabled = false
        }
        tutorialData.incrStepIndex()

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let step = tutorialData.currentStep
        InputQueue.append(
            Input(
                .tutorial(step)
            )
        )
    }
}
