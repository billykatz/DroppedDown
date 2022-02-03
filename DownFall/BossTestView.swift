//
//  BossTestView.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class BossTestView: ButtonDelegate {
    
    let foreground: SKNode
    let testSpriteForeground: SKNode
    let playableRect: CGRect
    
    let bossView: BossView
    let animator: Animator
    
    init(foreground: SKNode, playableRect: CGRect) {
        self.foreground = foreground
        self.playableRect = playableRect
        
        bossView = BossView(playableRect: playableRect, tileSize: 100, numberOfPreviousBossWins: 0, spriteProvider: { [] })
        bossView.position = bossView.position.translateVertically(-100)
        
        testSpriteForeground = SKNode()
        self.foreground.addChild(testSpriteForeground)
        self.animator = Animator(foreground: foreground, tileSize: 64, bossSprite: bossView.bossSprite,  playableRect: playableRect)
        
        let verticalPadding = 20.0
        
        foreground.addChild(bossView)
        let buttonZPosition: CGFloat = 10_000
        let buttonSize: CGSize = .buttonExtralarge
        let fontSize: CGFloat = .fontMediumSize
        
        let echoEffectButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .echoEffect, fontSize: fontSize)
        echoEffectButton.zPosition = buttonZPosition
        foreground.addChild(echoEffectButton)
        
        let walkEffectButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .walkEffect, fontSize: fontSize)
        walkEffectButton.position = CGPoint.alignHorizontally(walkEffectButton.frame, relativeTo: echoEffectButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding)
        walkEffectButton.zPosition = buttonZPosition
        foreground.addChild(walkEffectButton)
        
        let tiltHeadButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .tiltHead, fontSize: fontSize)
        tiltHeadButton.position = CGPoint.alignHorizontally(tiltHeadButton.frame, relativeTo: walkEffectButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        tiltHeadButton.zPosition = buttonZPosition
        foreground.addChild(tiltHeadButton)
        
        let toothChompButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .chompTeeth, fontSize: fontSize)
        toothChompButton.position = CGPoint.alignHorizontally(toothChompButton.frame, relativeTo: tiltHeadButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        toothChompButton.zPosition = buttonZPosition
        foreground.addChild(toothChompButton)
        
        let tootleBiteButton = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .lightBite, fontSize: fontSize)
        tootleBiteButton.position = CGPoint.alignHorizontally(tootleBiteButton.frame, relativeTo: toothChompButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        tootleBiteButton.zPosition = buttonZPosition
        foreground.addChild(tootleBiteButton)


        let angryEyelid = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .angryEyes, fontSize: fontSize)
        angryEyelid.position = CGPoint.alignHorizontally(angryEyelid.frame, relativeTo: tootleBiteButton.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        angryEyelid.zPosition = buttonZPosition
        foreground.addChild(angryEyelid)
        
        // Left column buttons
        let idlePhase1 = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .idlePhase1, fontSize: fontSize)
        idlePhase1.position = CGPoint.alignVertically(idlePhase1.frame, relativeTo: echoEffectButton.frame, horizontalAnchor: .left, verticalAlign: .center, verticalPadding: 0.0, horizontalPadding: 20.0, translatedToBounds: true)
        idlePhase1.zPosition = buttonZPosition
        foreground.addChild(idlePhase1)
        
        let rockTrio = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .rockTrio, fontSize: fontSize)
        rockTrio.position = CGPoint.alignHorizontally(rockTrio.frame, relativeTo: idlePhase1.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        rockTrio.zPosition = buttonZPosition
        foreground.addChild(rockTrio)
        
        let rearUp = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .rearUp, fontSize: fontSize)
        rearUp.position = CGPoint.alignHorizontally(rearUp.frame, relativeTo: rockTrio.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        rearUp.zPosition = buttonZPosition
        foreground.addChild(rearUp)
        
        let groundPound = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .groundPound, fontSize: fontSize)
        groundPound.position = CGPoint.alignHorizontally(groundPound.frame, relativeTo: rearUp.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        groundPound.zPosition = buttonZPosition
        foreground.addChild(groundPound)
        
        let poisonBeamAttack = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .poisonBeamAttack, fontSize: fontSize)
        poisonBeamAttack.position = CGPoint.alignHorizontally(poisonBeamAttack.frame, relativeTo: groundPound.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        poisonBeamAttack.zPosition = buttonZPosition
        foreground.addChild(poisonBeamAttack)
        
        let webAttack = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .webAttack, fontSize: fontSize)
        webAttack.position = CGPoint.alignHorizontally(webAttack.frame, relativeTo: poisonBeamAttack.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        webAttack.zPosition = buttonZPosition
        foreground.addChild(webAttack)
        
        // right column buttons
        let resetPositions = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .resetPositions, fontSize: fontSize)
        resetPositions.position = CGPoint.alignVertically(resetPositions.frame, relativeTo: echoEffectButton.frame, horizontalAnchor: .right, verticalAlign: .center, verticalPadding: 0.0, horizontalPadding: 20.0, translatedToBounds: true)
        resetPositions.zPosition = buttonZPosition
        foreground.addChild(resetPositions)
        
        let allEyesRed = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .eyesTurnRed, fontSize: fontSize)
        allEyesRed.position = CGPoint.alignHorizontally(allEyesRed.frame, relativeTo: resetPositions.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        allEyesRed.zPosition = buttonZPosition
        foreground.addChild(allEyesRed)
        
        let oneEyeYellow = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .oneEyeTurnsYellow, fontSize: fontSize)
        oneEyeYellow.position = CGPoint.alignHorizontally(oneEyeYellow.frame, relativeTo: allEyesRed.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        oneEyeYellow.zPosition = buttonZPosition
        foreground.addChild(oneEyeYellow)
        
        let bossWorried = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .worried, fontSize: fontSize)
        bossWorried.position = CGPoint.alignHorizontally(bossWorried.frame, relativeTo: oneEyeYellow.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        bossWorried.zPosition = buttonZPosition
        foreground.addChild(bossWorried)
        
        let bossStomps = ShiftShaft_Button(size: buttonSize, delegate: self, identifier: .bossStomps, fontSize: fontSize)
        bossStomps.position = CGPoint.alignHorizontally(bossStomps.frame, relativeTo: bossWorried.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: verticalPadding, translatedToBounds: true)
        bossStomps.zPosition = buttonZPosition
        foreground.addChild(bossStomps)
    }
    
    var rearUpToggle = false
    var worriedToggle = false
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .echoEffect:
            animator.animateEchoEffect { }
        case .walkEffect:
            animator.animateLegMovement { }
        case .tiltHead:
            animator.animateTwistingHead { }
        case .chompTeeth:
            animator.animateToothChomp { }
        case .lightBite:
            animator.animateToothSmallChomp { }
        case .angryEyes:
            animator.animateAngryFace { }
        case .idlePhase1:
            animator.animateIdlePhase1(timerBeforeDelay: 0.0) { }
        case .rockTrio:
            animator.animateWaitingToEat(delayBefore: 0.0) { }
        case .rearUp:
            animator.animateBossRearingUp(delayBefore: 0.0, reversed: rearUpToggle) {
                self.rearUpToggle.toggle()
            }
        case .groundPound:
            animator.animateGroundPound(delayBefore: 0.0) {
                
            }
        case .resetPositions:
            testSpriteForeground.removeAllChildren()
            animator.animateResetToOriginalPositions(delayBefore: 0.0) {
                
            }
            
        case .poisonBeamAttack:
            animator.animateGettingReadyToPoisonAttack(delayBefore: 0.0) {
                
            }
            
        case .webAttack:
            animator.testAnimateShootingWebs {
                
            }
        
        case .eyesTurnRed:
            animator.animateBossGettingReadyToAttack(delayBefore: 0.0) { [bossView] in
                bossView.bossSprite.numberOfRedEyes = 8
                
            }
            
        case .oneEyeTurnsYellow:
            bossView.bossSprite.numberOfRedEyes -= 1
            
            let eyeIndex = 8 - bossView.bossSprite.numberOfRedEyes
            animator.animateSingleEyeBecomingYellow(delayBefore: 0.0, eyeNumber: eyeIndex) {
                
            }
            
        case .worried:
            animator.animateBossPhaseChange {
                
            }
//            animator.animateBossWorried(delayBefore: 0.0, reversed: worriedToggle) {
//                self.worriedToggle.toggle()
//            }
        
        case .bossStomps:
            let rockAttacks = [BossTileAttack(.rock(color: .brown, holdsGem: false, groupCount: 1), .zero)]
            let monsterAttacks = [BossTileAttack(.monster(.monsterWithRandomType()) , .zero)]
            animator.animateBossPhaseChangeAnimation(spriteForground: testSpriteForeground, sprites: [[DFTileSpriteNode.init(type: .empty, height: 75, width: 75)]], bossPhaseChangeTargets: BossPhaseTargets(createPillars: nil, spawnMonsters: monsterAttacks, throwRocks: rockAttacks), delayBefore: 0.0, positionInForeground: { _ in  return .zero }) {
                
            }
        default:
            fatalError()
        }
    }
    
}
