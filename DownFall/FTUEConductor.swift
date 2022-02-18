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


class FTUEConductor {
    
    var shouldShowCompletedTutorial: Bool {
        UserDefaults.standard.bool(forKey: UserDefaults.shouldShowCompletedTutorialKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenCompletedTutorialKey)
        
    }
    
    public func showFirstDeathDialog(playableRect: CGRect, in view: SKNode) {
        if UserDefaults.standard.bool(forKey: UserDefaults.shouldSeeDiedForTheFirstTimeKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenDiedForTheFirstTimeKey) {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenDiedForTheFirstTimeKey)
        
            let sentence1 = Sentence(text: "Wow, good thing the Mineral Sprites are so nice. They will bring you back here everytime you die.", emotion: .skeptical)
            let sentence2 = Sentence(text: "AND you'll have a chance to spend your gems at the local store!", emotion: .content)
            let sentence3 = Sentence(text: "Tap on the store button and see what's available.", emotion: .content)
            let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
            
            let dialogView = FTUEDialogueOverlay(playableRect: playableRect, dialog: dialog)
            dialogView.zPosition = 1_000_000_000_000
            dialogView.isUserInteractionEnabled = true
            
            view.addChild(dialogView)
        }
        
    }
    
    public func dialogForCompletingTheTutorial() -> TutorialPhase? {
        if shouldShowCompletedTutorial {
        
            let sentence1 = Sentence(text: "I knew you could do it! Keep up the great work!!", emotion: .surprised)
            let sentence2 = Sentence(text: "One last thing, remember those Mineral Spirits I was talking about...?", emotion: .skeptical)
            let sentence3 = Sentence(text: "Well, they will revive you every time you die. Pretty nice of them, huh?", emotion: .skeptical)
            let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
            
            let ftuePhase = TutorialPhase(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: false, shouldSpawnMonsters: true, shouldSpawnTileWithGem: true, dialogue: dialog, highlightTileType: nil, waitDuration: 0.0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false, showAbovePickaxe: false)
            
            return ftuePhase
        }
        
        return nil
    }

    var shouldShowPhaseForEncounteringFirstRune: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenFirstRuneFTUEKey)

    }
    
    public func phaseForEncounteringFirstRune(_ runeOffer: StoreOffer) -> TutorialPhase? {
        guard shouldShowPhaseForEncounteringFirstRune  else { return nil }
            
        let sentence1 = Sentence(text: "Whoa! The Minersal Spirits offered you a Rune.", emotion: .surprised)
        let sentence2 = Sentence(text: "Collect it to add it to your pickaxe and then charge it up by mining rocks with the same color.", emotion: .content)
        let sentence3 = Sentence(text: "When the Rune is fully charged you can use its powerful ability.", emotion: .content)
        let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
        
        let ftuePhase = TutorialPhase(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: false, shouldSpawnMonsters: true, shouldSpawnTileWithGem: true, dialogue: dialog, highlightTileType: [.offer(runeOffer)], waitDuration: 0.0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false, showAbovePickaxe: false)
        
        return ftuePhase

    }
    
    var shouldShowFTUEForMiningGems: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenMinedFirstGemFTUEKey)
    }
    
    public func phaseForMiningGems(_ gemTileType: TileType) -> TutorialPhase? {
        guard shouldShowFTUEForMiningGems  else { return nil }
            
        let sentence1 = Sentence(text: "Nice you mined a gem!\nOnly some rocks have gems inside.  Look for a sparkle to find the gem-infused rocks.", emotion: .surprised)
//        let sentence2 = Sentence(text: "The larger the group of rocks, the more gems you will mine!", emotion: .content)
        let sentence2 = Sentence(text: "Groups with less than 10 rocks earns you 1 gem per rock.", emotion: .skeptical)
        let sentence3 = Sentence(text: "10 or more rocks earn you 2 gems per rock.", emotion: .skeptical)
        let sentence4 = Sentence(text: "Some of the best miners can collect 3 gems per rock but that is super rare.", emotion: .skeptical)
        let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3, sentence4], character: .teri, delayBeforeTyping: 0.25)
        
        let ftuePhase = TutorialPhase(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: false, shouldSpawnMonsters: true, shouldSpawnTileWithGem: true, dialogue: dialog, highlightTileType: [gemTileType], waitDuration: 0.0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false, showAbovePickaxe: false)
        
        return ftuePhase

    }
    
    var shouldShowRuneChargedForTheFirstTime: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaults.hasSeenRuneChargedForTheFirstTimeFTUEKey)
    }
    
    func runeIsCharged(_ rune: Rune) -> Bool {
        return rune.rechargeCurrent >= rune.cooldown
    }

    
    public func phaseForFirstRuneCharge(runes: [Rune]) -> TutorialPhase? {
        guard shouldShowRuneChargedForTheFirstTime  else { return nil }
        guard !runes.filter( { rune in runeIsCharged(rune) }).isEmpty else { return nil }
            
        let sentence1 = Sentence(text: "Woohooo! Your rune is fully charged.", emotion: .surprised)
        let sentence2 = Sentence(text: "Tap on it to choose targets and unleash its power.", emotion: .content)
        let sentence3 = Sentence(text: "Runes will recharge after each use so use them often.", emotion: .skeptical)
        let dialog = Dialogue(sentences: [sentence1, sentence2, sentence3], character: .teri, delayBeforeTyping: 0.25)
        
        let ftuePhase = TutorialPhase(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: true, shouldSpawnTileWithGem: true, dialogue: dialog, highlightTileType: nil, waitDuration: 0.0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false, showAbovePickaxe: true)
        
        return ftuePhase

    }

    
}

