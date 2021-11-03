//
//  FTUEConductor.swift
//  DownFall
//
//  Created by Billy on 11/2/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class FTUEDialogueOverlay: SKSpriteNode {
    
    let playableRect: CGRect
    let dialogueView: DialogueView
    
    
    
    init (playableRect: CGRect, dialog: Dialogue) {
        self.playableRect = playableRect
        
        let dialogueView = DialogueView(dialogue: dialog)
        dialogueView.zPosition = 200_000_000_000
        dialogueView.position = CGPoint.position(dialogueView.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 275)
        self.dialogueView = dialogueView
        
        super.init(texture: nil, color: .clear, size: playableRect.size)
        
        self.zPosition = 100_000_000_000
        
        self.addChild(dialogueView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.alpha == 1 {
            if !self.dialogueView.finishedTyping {
                dialogueView.showFullSentence()
            } else if dialogueView.canShowNextSentence(){
                dialogueView.showNextSentence()
            } else {
                let fadeOut = SKAction.fadeOut(withDuration: 0.25)
                fadeOut.timingMode = .easeIn
                
                self.run(SKAction.sequence([fadeOut, SKAction.removeFromParent()]))
            }
        }
    }
    
}


class FTUEMetaGameConductor {
    
    public func showFirstDeathDialog(playableRect: CGRect, in view: SKNode) {
        if UserDefaults.standard.bool(forKey: UserDefaults.shouldSeeDiedForTheFirstTimeKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenDiedForTheFirstTimeKey) {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenDiedForTheFirstTimeKey)
        
            let sentence1 = Sentence(text: "Wow, good thing the Mineral Sprites are nice. They will bring you back everytime you die.", emotion: .skeptical)
            let sentence2 = Sentence(text: "And you'll have a chance to spend your gems at the local shoppe!", emotion: .content)
            let sentence3 = Sentence(text: "Tap on the store button and see what's available", emotion: .content)
            let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
            
            let dialogView = FTUEDialogueOverlay(playableRect: playableRect, dialog: dialog)
            dialogView.zPosition = 1_000_000_000_000
            dialogView.isUserInteractionEnabled = true
            
            view.addChild(dialogView)
        }
        
    }
    
    var shouldShowCompletedTutorial: Bool {
        UserDefaults.standard.bool(forKey: UserDefaults.shouldShowCompletedTutorialKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenCompletedTutorialKey)
        
    }
    public func dialogForCompletingTheTutorial() -> TutorialPhase? {
        
        
        if shouldShowCompletedTutorial {
        
            let sentence1 = Sentence(text: "I knew you could do it! Keep up the great work!!", emotion: .surprised)
            let sentence2 = Sentence(text: "One last thing, remember those Mineral Spirits I was talking about...?", emotion: .skeptical)
            let sentence3 = Sentence(text: "Well, they are will revive you every time you die back at base camp.  So don't worry too much about dying.", emotion: .skeptical)
            let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
            
            let ftuePhase = TutorialPhase(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: false, shouldSpawnMonsters: true, shouldSpawnTileWithGem: true, dialogue: dialog, highlightTileType: nil, waitDuration: 0.0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
            
            return ftuePhase
        }
        
        return nil
    }

    
    
}

