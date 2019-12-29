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
            if case let InputType.tutorial(step) = input.type {
                self.step(step)
            } else if case .boardBuilt = input.type {
                // START THE TUTORIAL

                let step = tutorialData.currentStep
                InputQueue.append(
                    Input(
                        .tutorial(step)
                    )
                )
            } else if InputType.fuzzyEqual(input.type, tutorialData.currentStep.inputToContinue) {
                tutorialData.currentStep.completed = true
                tutorialData.incrStepIndex()
                
                if tutorialData.finished {
                    self.removeFromParent()
                } else {
                    let step = tutorialData.currentStep
                    self.delegate?.queue(inputType: .tutorial(step))
                }
                
            } else if let inputToEnter = tutorialData.currentStep.inputToEnter,
                InputType.fuzzyEqual(input.type, inputToEnter) {
                self.step(tutorialData.currentStep)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func step(_ currentStep: TutorialStep) {
        if !currentStep.started {
            currentStep.started = true
            self.isUserInteractionEnabled = true
            if currentStep.inputToContinue != .tutorial(.zero) {
                // we need to use the game to continue this tutorial
                // stop intercepting calls
                self.isUserInteractionEnabled = false
            }
        } else {
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
        if tutorialData.currentStep.started
            && tutorialData.currentStep.inputToContinue == .tutorial(.zero) {

            let step = tutorialData.currentStep
            InputQueue.append(
                Input(
                    .tutorial(step)
                )
            )
        }
    }
}
