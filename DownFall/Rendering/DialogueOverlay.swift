//
//  DialogueOverlay.swift
//  DownFall
//
//  Created by Billy on 10/14/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class DialogueView: SKSpriteNode {
    
    let totalDialogueSize = CGSize(width: 834, height: 381)
    let dialogueBoxSize = CGSize(width: 550, height: 360)
    let characterBox = CGSize(width: 220, height: 220)
    let characterNameBox = CGSize(width: 292, height: 87)
    let dialogueLabelName = "dialogueLabelName"
    let dialogSpriteName = "dialog"
    
    var containerView: SKSpriteNode
    var finishedTyping: Bool = false
    let dialogue: Dialogue
    let dialogueFrame: CGRect
    
    var sentenceIndex = 0
    
    init(dialogue: Dialogue) {
        self.dialogue = dialogue
        self.containerView = SKSpriteNode(color: .clear, size: totalDialogueSize)
        
        let dialogueBackgroundImage = SKSpriteNode(texture: SKTexture(imageNamed: dialogSpriteName), size: totalDialogueSize)
        dialogueBackgroundImage.zPosition = -1
        
//        let dialogueBox = SKShapeNode(rectOf: dialogueBoxSize, cornerRadius: 24.0)
//        dialogueBox.strokeColor = .white
//        dialogueBox.fillColor = .dialogueBoxBackground
//        dialogueBox.lineWidth = 16.0
//        
//        dialogueBox.position = CGPoint.position(dialogueBox.frame, inside: containerView.frame, verticalAlign: .bottom, horizontalAnchor: .left)
        
        
        let character = SKSpriteNode(texture: SKTexture(imageNamed: dialogue.character.textureName), size: characterBox)
        character.xScale = -1
        character.zPosition = 100000

        character.position = CGPoint.alignVertically(character.frame, relativeTo: dialogueBackgroundImage.frame, horizontalAnchor: .left, verticalAlign: .center, verticalPadding: -15, horizontalPadding: -275, translatedToBounds: true)
        
        let characterNameLabel = ParagraphNode(text: dialogue.character.humanReadable, fontSize: 80, fontColor: .white)
        characterNameLabel.position = CGPoint.alignVertically(characterNameLabel.frame, relativeTo: character.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: -24,  horizontalPadding: -8,  translatedToBounds: true)
        characterNameLabel.zPosition = 100000
        
        let emptySprite = SKSpriteNode(color: .clear, size: dialogueBoxSize)
        emptySprite.position = CGPoint.alignHorizontally(emptySprite.frame, relativeTo: characterNameLabel.frame, horizontalAnchor: .left, verticalAlign: .bottom, translatedToBounds: true)
        
        dialogueFrame = emptySprite.frame
        
        
        super.init(texture: nil, color: .clear, size: .fifty)
        
        containerView.addChild(dialogueBackgroundImage)
        containerView.addChild(character)
        containerView.addChild(characterNameLabel)
        self.addChild(containerView)
        
        showNextSentence()
    }
    
    func showFullSentence() {
        let sentence = dialogue.sentences[sentenceIndex]
        
        let dialogueLabel = ParagraphNode(text: String(sentence), paragraphWidth: dialogueFrame.width, fontSize: sentenceFontSize, fontColor: .white)
        
        dialogueLabel.position = CGPoint.position(dialogueLabel.frame, inside: dialogueFrame, verticalAlign: .top, horizontalAnchor: .left, translatedToBounds: true)
        dialogueLabel.zPosition = 100000
        
        if let currentLabel = containerView.childNode(withName: dialogueLabelName) {
            currentLabel.removeFromParent()
        }
        
        dialogueLabel.name = dialogueLabelName
        
        containerView.removeAllActions()
        containerView.addChild(dialogueLabel)
        
        finishedTyping = true
        
        return

    }
    
    public func canShowNextSentence() -> Bool {
        sentenceIndex += 1
        if sentenceIndex >= dialogue.sentences.count {
            return false
        } else {
            return true
        }
        
    }
    
    let sentenceFontSize: CGFloat = 60
    
    func showNextSentence() {
        
        finishedTyping = false
        
        let dialogueLabel = ParagraphNode(text: dialogue.sentences[sentenceIndex], paragraphWidth: dialogueFrame.width, fontSize: sentenceFontSize, fontColor: .white)
        dialogueLabel.position = CGPoint.position(dialogueLabel.frame, inside: dialogueFrame, verticalAlign: .top, horizontalAnchor: .left, translatedToBounds: true)
        
        var waitTime = dialogue.delayBeforeTyping
        let waitIncrement = 0.025
        var actions: [SKAction] = []
        
        // build the sentence one more letter each time
        
        for index in 0..<dialogue.sentences[sentenceIndex].count {
            let waitAction = SKAction.wait(forDuration: waitTime)
            
            let createLabelAction = SKAction.run { [containerView, sentenceIndex, dialogueLabelName, dialogueFrame, dialogue, sentenceFontSize, weak self] in
                let sentence = dialogue.sentences[sentenceIndex]
                let endIndex = sentence.index(sentence.startIndex, offsetBy: index+1)
                let subsentence = dialogue.sentences[sentenceIndex][sentence.startIndex..<endIndex]
                
                let dialogueLabel = ParagraphNode(text: String(subsentence), paragraphWidth: dialogueFrame.width, fontSize: sentenceFontSize, fontColor: .white)
                
                dialogueLabel.position = CGPoint.position(dialogueLabel.frame, inside: dialogueFrame, verticalAlign: .top, horizontalAnchor: .left, translatedToBounds: true)
                
                
                if let currentLabel = containerView.childNode(withName: dialogueLabelName) {
                    currentLabel.removeFromParent()
                }
                
                dialogueLabel.name = dialogueLabelName
                dialogueLabel.zPosition = 100000
                
                containerView.addChild(dialogueLabel)
                
                if endIndex == sentence.endIndex {
                    self?.finishedTyping = true
                }

            }
            
            actions.append(SKAction.sequence([waitAction, createLabelAction]))
            
            
            waitTime += waitIncrement
        }
        
        containerView.run(SKAction.group(actions))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DialogueOverlay: SKSpriteNode {
    
    let highlightMaskName = "test-highlight-mask-2"
    let highlightLevelGoalsMaskName = "test-highlight-level-goals"
    
    let playableRect: CGRect
    let foreground: SKNode
    let tutorialPhase: TutorialPhase
    let dialogueView: DialogueView
    
    
    
    init (playableRect: CGRect, foreground: SKNode, tutorialPhase: TutorialPhase, levelGoalViewOrigin: CGPoint, tileTypeToPosition: (TileType) -> CGPoint?) {
        self.playableRect = playableRect
        self.foreground = foreground
        self.tutorialPhase = tutorialPhase
        
        
        
        let dialogueView = DialogueView(dialogue: tutorialPhase.dialogue)
        dialogueView.zPosition = 200_000_000_000
        dialogueView.position = CGPoint.position(dialogueView.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 275)
        self.dialogueView = dialogueView
        
        super.init(texture: nil, color: .clear, size: playableRect.size)
        
        self.zPosition = 100_000_000_000
        
        let levelGoalsHighlight = SKSpriteNode(texture: SKTexture(imageNamed: highlightLevelGoalsMaskName), color: .white, size: CGSize(width: playableRect.width, height: playableRect.height * 2.31 ))
        
        for tileHighlight in tutorialPhase.highlightTileType ?? [] {
            if let position = tileTypeToPosition(tileHighlight) {
                let maskHighlightNode = SKSpriteNode(texture: SKTexture(imageNamed: highlightMaskName), color: .white, size: playableRect.size.scale(by: 2.0))
                maskHighlightNode.position = position
                maskHighlightNode.alpha = CGFloat(tutorialPhase.highlightTileType?.count ?? 1) == 2 ? 0.25 : 0.75
                if tutorialPhase.shouldDimScreen {
                    self.addChild(maskHighlightNode)
                }
                
            }
        }
        
        if tutorialPhase.shouldHighlightLevelGoalsInHUD {
            levelGoalsHighlight.position = levelGoalViewOrigin
            self.addChild(levelGoalsHighlight)
        }

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
                InputQueue.append(Input(.tutorialPhaseEnd(tutorialPhase)))
            }
        }
    }
    
}
