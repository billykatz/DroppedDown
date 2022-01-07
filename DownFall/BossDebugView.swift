//
//  BossDebugView.swift
//  DownFall
//
//  Created by Billy on 11/17/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class BossDebugView: SKSpriteNode {
    let playableRect: CGRect
    let containerView: SKSpriteNode
    
    init (playableRect: CGRect) {
        self.playableRect = playableRect
        
        
        containerView = SKSpriteNode(color: .black, size: CGSize(width: 800, height: 275))
        
        super.init(texture: nil, color: .clear, size: playableRect.size)
        
        self.addChild(containerView)
        containerView.zPosition = 10_000
        containerView.position = CGPoint.position(containerView.frame, inside: playableRect, verticalAlign: .top, horizontalAnchor: .center, yOffset: 10)
        
        
        // Testing the spider art
//        let ratio = CGFloat(78.0 / 51.0)
//        let width = playableRect.width * 0.85
//        let height = width / ratio
//        let spiderSprite = SKSpriteNode(texture: SKTexture(imageNamed: "boss-spider"), size: CGSize(width: width, height: height))
//        spiderSprite.position = CGPoint.position(spiderSprite.frame, inside: containerView.frame, verticalAlign: .center, horizontalAnchor: .center)
//        containerView.addChild(spiderSprite)
        
        self.isUserInteractionEnabled = false
        
        Dispatch.shared.register { [weak self] input in
            if case InputType.bossTurnStart(let phase) = input.type {
                self?.showBossPhaseInfo(phase)
            } else if case InputType.bossPhaseStart(let phase) = input.type {
                self?.showBossPhaseInfo(phase)
            }
        }
    }
    
    func showBossPhaseInfo(_ phase: BossPhase) {
        containerView.removeAllChildren()
        let phaseName = phase.bossPhaseType.rawValue
        let bossState = phase.bossState.stateType.description
        let eatenRocks = phase.eatenRocks
        
        let phaseNameLabel = ParagraphNode(text: "Phase: \(phaseName)", fontSize: .fontLargeSize, fontColor: .white)
        phaseNameLabel.position = CGPoint.position(phaseNameLabel.frame, inside: containerView.frame, verticalAlign: .top, horizontalAnchor: .center)
        
        let stateNameLabel = ParagraphNode(text: "State: \(bossState)", fontSize: .fontLargeSize, fontColor: .white)
        stateNameLabel.position = CGPoint.alignHorizontally(stateNameLabel.frame, relativeTo: phaseNameLabel.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        
        let superAttackLabel = ParagraphNode(text: "Super Attack Charge: \(eatenRocks) / \(superAttackChargeNumber)", fontSize: .fontLargeSize, fontColor: .white)
        superAttackLabel.position = CGPoint.alignHorizontally(superAttackLabel.frame, relativeTo: stateNameLabel.frame, horizontalAnchor: .center, verticalAlign: .bottom, translatedToBounds: true)
        
        
        
        containerView.addChild(phaseNameLabel)
        containerView.addChild(stateNameLabel)
        containerView.addChild(superAttackLabel)
        
    }
    
    var center: CGPoint {
        return containerView.frame.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
