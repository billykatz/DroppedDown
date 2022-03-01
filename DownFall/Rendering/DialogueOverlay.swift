//
//  DialogueOverlay.swift
//  DownFall
//
//  Created by Billy on 10/14/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class DialogueView: SKSpriteNode {
    
    // Style constants
    let totalDialogueSize = CGSize(width: 834, height: 381)
    let dialogueBoxSize = CGSize(width: 520, height: 360)
    let characterBox = CGSize(width: 220, height: 220)
    let characterNameBox = CGSize(width: 292, height: 87)
    let dialogueLabelName = "dialogueLabelName"
    let dialogSpriteName = "dialog"
    let dialogCharacterSpriteName = "dialogCharacterSpriteName"
    let sentenceFontSize: CGFloat = 64
    
    var containerView: SKSpriteNode
    var finishedTyping: Bool = false
    let dialogue: Dialogue
    let dialogueFrame: CGRect
    let characterBoxPosition: CGPoint
    
    var sentenceIndex = 0
    
    init(dialogue: Dialogue) {
        self.dialogue = dialogue
        self.containerView = SKSpriteNode(color: .clear, size: totalDialogueSize)
        
        let dialogueBackgroundImage = SKSpriteNode(texture: SKTexture(imageNamed: dialogSpriteName), size: totalDialogueSize)
        dialogueBackgroundImage.zPosition = -1
        
        let character = SKSpriteNode(texture: SKTexture(imageNamed: dialogue.character.textureName), size: characterBox)
        character.xScale = -1
        character.zPosition = 100000

        self.characterBoxPosition = CGPoint.alignVertically(character.frame, relativeTo: dialogueBackgroundImage.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: 12, horizontalPadding: -275, translatedToBounds: true)
        
        let characterNameLabel = ParagraphNode(text: dialogue.character.humanReadable, fontSize: 80, fontColor: .white)
        characterNameLabel.position = CGPoint.position(characterNameLabel.frame, inside: dialogueBackgroundImage.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: 150.0, translatedToBounds: true)
            
//            CGPoint.alignVertically(characterNameLabel.frame, relativeTo: character.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: 0,  horizontalPadding: -250,  translatedToBounds: true)
        characterNameLabel.zPosition = 100000
        
        // empty sprite to position the dialog text area
        let emptySprite = SKSpriteNode(color: .clear, size: dialogueBoxSize)
        let fakeChar = SKSpriteNode(color: .clear, size: characterBox)
        fakeChar.position = characterBoxPosition
        emptySprite.position = CGPoint.alignVertically(emptySprite.frame, relativeTo: fakeChar.frame, horizontalAnchor: .right, verticalAlign: .top, verticalPadding: -24.0, translatedToBounds: true)
        
        dialogueFrame = emptySprite.frame
        
        
        super.init(texture: nil, color: .clear, size: .fifty)
        
        containerView.addChild(dialogueBackgroundImage)
        containerView.addChild(characterNameLabel)
        self.addChild(containerView)
        
        showNextSentence()
    }
    
    private func characterImageName(with emotion: Emotion) -> String {
        return "\(dialogue.character.rawValue)-\(emotion.rawValue)"
    }
    
    func showNextCharacter() {
        // remove the old one
        if let oldCharacter = containerView.childNode(withName: dialogCharacterSpriteName) {
            let fadeOut = SKAction.fadeOut(withDuration: 0.125)
            fadeOut.timingMode = .easeIn
            let group = SKAction.group([fadeOut, .removeFromParent()])
            oldCharacter.run(group)
        }
//        containerView.removeChild(with: dialogCharacterSpriteName)
        
        // create the new one
        let emotion = dialogue.sentences[sentenceIndex].emotion
        
        let image = SKSpriteNode(texture: SKTexture(imageNamed: characterImageName(with: emotion)), size: characterBox)
        
        image.name = dialogCharacterSpriteName
        image.position = characterBoxPosition
        image.zPosition = 100000
        image.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.125)
        fadeIn.timingMode = .easeOut
        
        containerView.addChild(image)
        image.run(fadeIn)
        
    }
    
    func dialogBoxPosition(_ thisFrame: CGRect) -> CGPoint {
        return CGPoint.position(thisFrame, inside: dialogueFrame, verticalAlign: .top, horizontalAnchor: .left, translatedToBounds: true)
    }
    
    // Called to skip the typing animation and just show the full sentence
    public func showFullSentence() {
        let sentence = dialogue.sentences[sentenceIndex].text
        
        let dialogueLabel = ParagraphNode(text: String(sentence), paragraphWidth: dialogueFrame.width, fontSize: sentenceFontSize, fontColor: .white)
        
        dialogueLabel.position = dialogBoxPosition(dialogueLabel.frame)
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
    
    // Public function that determines if the dialog is finished or not
    public func canShowNextSentence() -> Bool {
        sentenceIndex += 1
        if sentenceIndex >= dialogue.sentences.count {
            return false
        } else {
            return true
        }
        
    }
    
    func showNextSentence() {
        
        finishedTyping = false
        
        var waitTime = dialogue.delayBeforeTyping
        let waitIncrement = 0.025
        var actions: [SKAction] = []
        
        // build the sentence one more letter each time
        
        for index in 0..<dialogue.sentences[sentenceIndex].text.count {
            let waitAction = SKAction.wait(forDuration: waitTime)
            
            let createLabelAction = SKAction.run { [containerView, sentenceIndex, dialogueLabelName, dialogueFrame, dialogue, sentenceFontSize, weak self] in
                guard let self = self else { return }
                let sentence = dialogue.sentences[sentenceIndex].text
                let endIndex = sentence.index(sentence.startIndex, offsetBy: index+1)
                let subsentence = sentence[sentence.startIndex..<endIndex]
                
                let dialogueLabel = ParagraphNode(text: String(subsentence), paragraphWidth: dialogueFrame.width, fontSize: sentenceFontSize, fontColor: .white)
                
                dialogueLabel.position = self.dialogBoxPosition(dialogueLabel.frame)
                
                if let currentLabel = containerView.childNode(withName: dialogueLabelName) {
                    currentLabel.removeFromParent()
                }
                
                dialogueLabel.name = dialogueLabelName
                dialogueLabel.zPosition = 100000
                
                containerView.addChild(dialogueLabel)
                
                if endIndex == sentence.endIndex {
                    self.finishedTyping = true
                }

            }
            
            actions.append(SKAction.sequence([waitAction, createLabelAction]))
            
            
            waitTime += waitIncrement
        }
        
        containerView.run(SKAction.group(actions))
        
        showNextCharacter()
        
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
        
        // we need these set for some UI code
        let fauxBackpackView = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width, height: playableRect.height * 0.2))
        let backpackposition = CGPoint.position(this: fauxBackpackView.frame, centeredInBottomOf: playableRect)
        fauxBackpackView.position = backpackposition
        
        if (tutorialPhase.showAbovePickaxe) {
            dialogueView.position = CGPoint.alignHorizontally(dialogueView.frame, relativeTo: fauxBackpackView.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: 200.0, translatedToBounds: true)
        } else if tutorialPhase.shouldShowRotateFinger {
            dialogueView.position = CGPoint.alignHorizontally(dialogueView.frame, relativeTo: fauxBackpackView.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: 500.0, translatedToBounds: true)
            
        } else {
            dialogueView.position = CGPoint.position(dialogueView.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: 275)
        }
        self.dialogueView = dialogueView
        
        super.init(texture: nil, color: .clear, size: playableRect.size.fullScreenSize)
        
        self.isUserInteractionEnabled = true
        self.zPosition = 100_000_000_000
        
        let levelGoalsHighlight = SKSpriteNode(texture: SKTexture(imageNamed: highlightLevelGoalsMaskName), color: .white, size: CGSize(width: playableRect.width*4, height: playableRect.height * 2.31 ))
        
        for tileHighlight in tutorialPhase.highlightTileType ?? [] {
            if let position = tileTypeToPosition(tileHighlight) {
                let maskHighlightNode = SKSpriteNode(texture: SKTexture(imageNamed: highlightMaskName), color: .white, size: playableRect.size.scale(by: 6.0))
                maskHighlightNode.position = position
                maskHighlightNode.alpha = 0.75
                if tutorialPhase.shouldDimScreen {
                    self.addChild(maskHighlightNode)
                }
                
            }
        }
        
        if tutorialPhase.shouldHighlightLevelGoalsInHUD {
            levelGoalsHighlight.position = levelGoalViewOrigin
            levelGoalsHighlight.alpha = 0.75
            self.addChild(levelGoalsHighlight)
        }
        
        if tutorialPhase.shouldShowRotateFinger {
            showRotateFinger(playableRect: playableRect)
            let fakeFrame = CGRect(origin: .zero, size: CGSize(width: playableRect.width, height: playableRect.height * 0.2))
            levelGoalsHighlight.position = CGPoint.position(this: fakeFrame, centeredInBottomOf: playableRect, verticalPadding: 275)
            levelGoalsHighlight.setScale(1.1)
            levelGoalsHighlight.alpha = 0.75
            self.addChild(levelGoalsHighlight)
        }
        
        if tutorialPhase.showAbovePickaxe {
            levelGoalsHighlight.position = CGPoint.position(this: CGRect(origin: .zero, size: CGSize(width: playableRect.width, height: playableRect.height * 0.2)), centeredInBottomOf: playableRect, verticalPadding: 30)
            levelGoalsHighlight.setScale(1.1)
            self.addChild(levelGoalsHighlight)
        }
            

        self.addChild(dialogueView)
    }
    
    func showRotateFinger(playableRect: CGRect) {
        // add the diming
        let maskHighlightNode = SKSpriteNode(texture: nil, color: .black, size: playableRect.size.scale(by: 2.0))
        maskHighlightNode.position = position
        maskHighlightNode.alpha = 0.5
        self.addChild(maskHighlightNode)
        
        let fingerSize = CGSize(widthHeight: 125.0)
        let fingerContainerSprite = SKSpriteNode(color: .clear, size: fingerSize)

        // create sprites
        let fingerUnpressed = SKSpriteNode(texture: SKTexture(imageNamed: "finger"), size: fingerSize)
        let fingerPressed = SKSpriteNode(texture: SKTexture(imageNamed: "finger-pressed"), size: fingerSize)
        let fingerSwiping = SKSpriteNode(texture: SKTexture(imageNamed: "finger-swiping"), size: fingerSize)
        
        // create start and end positions
        let fingerY = CGFloat(380)
        let fingerStartPosition = CGPoint.position(fingerContainerSprite.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: 50, yOffset: fingerY)
        let fingerEndPosition = CGPoint.position(fingerContainerSprite.frame, inside: playableRect, verticalAlign: .bottom, horizontalAnchor: .right, xOffset: 40, yOffset: fingerY)
        
        fingerContainerSprite.position = fingerStartPosition

        // show finger (unpressed)
        let showFingerUnpressed = SKAction.run {
            fingerUnpressed.alpha = 1.0
            fingerPressed.alpha = 0.0
            fingerSwiping.alpha = 0.0
        }
        
        let showFingerPressed = SKAction.run {
            fingerUnpressed.alpha = 0.0
            fingerPressed.alpha = 1.0
            fingerSwiping.alpha = 0.0
        }
        
        let showFingerSwiping = SKAction.run {
            fingerUnpressed.alpha = 0.0
            fingerPressed.alpha = 0.0
            fingerSwiping.alpha = 1.0
        }
        // show finger pressed
        // show finger moving
        // and show finger swiping
        // show finger pressed
        // show finger unpress
        // move back to start
        let shortPause = SKAction.wait(forDuration: 0.2)
        let longPause = SKAction.wait(forDuration: 0.5)
        let moveLeftToRight = SKAction.move(to: fingerEndPosition, duration: 0.75)
        let moveUpJustABit = SKAction.moveBy(x: 0.0, y: 15.0, duration: 0.0)
        let moveDownJustABit = moveUpJustABit.reversed()
        moveLeftToRight.timingMode = .easeInEaseOut
        let moveBackToBeginning = SKAction.move(to: fingerStartPosition, duration: 0.5)
        moveBackToBeginning.timingMode = .easeInEaseOut
        
        let seq = SKAction.sequence(showFingerUnpressed, shortPause, moveUpJustABit, showFingerPressed, shortPause, showFingerSwiping, moveLeftToRight, moveDownJustABit, showFingerUnpressed, longPause, moveBackToBeginning)
        
        fingerContainerSprite.addChild(fingerUnpressed)
        fingerContainerSprite.addChild(fingerPressed)
        fingerContainerSprite.addChild(fingerSwiping)
        addChild(fingerContainerSprite)
        
        fingerContainerSprite.run(SKAction.repeatForever(seq))
        
        
        
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
                InputQueue.append(Input(.tutorialPhaseEnd(tutorialPhase)))
            }
        }
    }
    
}
