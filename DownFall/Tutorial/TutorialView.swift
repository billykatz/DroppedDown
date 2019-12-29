//
//  TutorialView.swift
//  DownFall
//
//  Created by William Katz on 11/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol TutorialViewDelegate: class {
    func queue(inputType: InputType)
}

class TutorialView: SKSpriteNode {
    
    let tutorialData: TutorialData
    
    weak var delegate: TutorialViewDelegate?
    
    init(tutorialData: TutorialData,
         texture: SKTexture?,
         color: UIColor,
         size: CGSize) {
        self.tutorialData = tutorialData
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
        
        
        Dispatch.shared.register { [weak self] (input) in
            guard let self = self else { return }
            
            // This is the input specifically for tutorial steps that are just "Tap to continue"
            if case let InputType.tutorial(step) = input.type {
                self.step(step)
            } else if case .boardBuilt = input.type {
                // start the tutorial

                let step = tutorialData.currentStep
                InputQueue.append(
                    Input(
                        .tutorial(step)
                    )
                )
            }
            // Certain inputs match up with the input needed to finish a tutorial step
            else if InputType.fuzzyEqual(input.type, tutorialData.currentStep.inputToContinue) {
                tutorialData.currentStep.completed = true
                tutorialData.incrStepIndex()
                
                if tutorialData.finished {
                    self.removeFromParent()
                } else {
                    // Often, we will know we need to continue the tutorial, but cannot because of the current game state
                    // Use our delegate method to "queue" input which should be digested at the next possible update
                    // This is heavily coupled with TutorialScene and its update method
                    let step = tutorialData.currentStep
                    self.delegate?.queue(inputType: .tutorial(step))
                }
                
            }
            // Ceratin inputs match up with the input needed to begin the next tutorial step
            else if let inputToEnter = tutorialData.currentStep.inputToEnter,
                InputType.fuzzyEqual(input.type, inputToEnter) {
                self.step(tutorialData.currentStep)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func step(_ currentStep: TutorialStep) {
        // start the step
        // enable or disable user interaction depending on the the input to continue
        if !currentStep.started {
            currentStep.started = true
            self.isUserInteractionEnabled = true
            if currentStep.inputToContinue != .tutorial(.zero) {
                // we need to use the game to continue this tutorial
                // stop intercepting calls
                self.isUserInteractionEnabled = false
            }
        }
        // mark this step as completed and finish the tutorial if we are at the end
        // else proceed to the next step
        else {
            currentStep.completed = true
            if tutorialData.finished {
                self.removeFromParent()
            } else {
                tutorialData.incrStepIndex()
                let step = tutorialData.currentStep
                InputQueue.append(
                    Input(
                        .tutorial(step)
                    )
                )
            }

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If we are receving touches that means that our user interation is enabled
        // If the current step is started and we receive a touch
        // We send out the current step which will eventually progress the tutorial
        
        if tutorialData.currentStep.started &&
            tutorialData.currentStep.inputToContinue == .tutorial(.zero) {

            let step = tutorialData.currentStep
            InputQueue.append(
                Input(
                    .tutorial(step)
                )
            )
        }
    }
}
