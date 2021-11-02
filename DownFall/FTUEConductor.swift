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
    
    private let playableRect: CGRect
    
    init(playableRect: CGRect){
        self.playableRect = playableRect
    }
    
    public func showFirstDeathDialog(in view: SKNode) {
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
    
    
}

