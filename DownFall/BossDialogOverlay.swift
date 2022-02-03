//
//  BossDialogOverlay.swift
//  DownFall
//
//  Created by Billy on 1/26/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct BossDialoguePhase {
    let dialogue: Dialogue
    let selectRandomly: Int
    
    // use this to choose random sentences for the dialogue
    // currently just used to chance the win message when the player beats the boss
    var chosenDialogue: Dialogue {
        if selectRandomly > 0 {
            guard selectRandomly <= dialogue.sentences.count else { return dialogue }
            
            let randomSentences = dialogue.sentences.choose(random: selectRandomly)
            return Dialogue(sentences: randomSentences, character: dialogue.character, delayBeforeTyping: dialogue.delayBeforeTyping)
        } else {
            return dialogue
        }
    }
    
}

class BossDialogueOverlay: SKSpriteNode {
    
    let playableRect: CGRect
    let foreground: SKNode
    let dialogueView: DialogueView
    let bossDialoguePhase: BossDialoguePhase
    
    init (playableRect: CGRect, foreground: SKNode, bossDialoguePhase: BossDialoguePhase) {
        self.playableRect = playableRect
        self.foreground = foreground
        self.bossDialoguePhase = bossDialoguePhase
        
        let dialogueView = DialogueView(dialogue: bossDialoguePhase.chosenDialogue)
        dialogueView.zPosition = 200_000_000_000
        
        // we need these set for some UI code
        let fauxBackpackView = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height * 0.2))
        let backpackposition = CGPoint.position(this: fauxBackpackView.frame, centeredInBottomOf: playableRect)
        fauxBackpackView.position = backpackposition
        
        dialogueView.position = CGPoint.position(dialogueView.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 275)
        self.dialogueView = dialogueView
        
        super.init(texture: nil, color: .clear, size: playableRect.size)
        
        self.isUserInteractionEnabled = true
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
                
                let removeInteraction = SKAction.run { [weak self] in
                    self?.isUserInteractionEnabled = false
                }
                
                self.run(SKAction.sequence([fadeOut, removeInteraction, SKAction.removeFromParent()]))
            }
        }
    }
    
}
