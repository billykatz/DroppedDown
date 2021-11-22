//
//  BossView.swift
//  DownFall
//
//  Created by Billy on 11/18/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

class BossView: SKSpriteNode {
    
    struct Constants {
        static let yellowReticleName = "yellowReticle"
        static let redReticleName = "redReticle"
        static let poisonReticleName = "poisonReticle"
        static let poisonReticleSize = CGSize(width: 34, height: 292)
    }
    
    private let tileSize: CGFloat
    private let playableRect: CGRect
    private let spriteProvider: () -> [[DFTileSpriteNode]]
    private lazy var sprites: [[DFTileSpriteNode]] = {
        return spriteProvider()
    }()
    
    // all sprites are added to this container
    private let containerView: SKSpriteNode
    
    // state variables to reset the reticles when needed
    private var dynamiteTargetToAttack: [SKSpriteNode] = []
    private var poisonColumnsTargetToAttack: [SKSpriteNode] = []
    private var spawnSpiderTargetToAttack: [SKSpriteNode] = []
    
    init(playableRect: CGRect,tileSize: CGFloat, spriteProvider: @escaping () -> [[DFTileSpriteNode]]) {
        self.playableRect = playableRect
        self.spriteProvider = spriteProvider
        self.tileSize = tileSize
        
        self.containerView = SKSpriteNode(color: .clear, size: playableRect.size)
        containerView.zPosition = 5_000
        
        super.init(texture: nil, color: .clear, size: playableRect.size)
        
        self.isUserInteractionEnabled = false
        
        addChild(containerView)
        
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleInput(_ input: Input) {
        switch input.type {
        case .transformation(let trans):
            if let firstTrans = trans.first {
                switch firstTrans.inputType {
                case .bossTurnStart(let phase):
                    handleBossTurnStart(phase: phase, transformation: firstTrans)
                default:
                    break
                }
            }
        case .bossTurnStart(let phase):
            handleBossTurnStart(phase: phase)
        case .bossPhaseStart(let phase):
                handleBossPhaseStart(phase: phase)
        default:
            break
        }
    }
    
    func resetReticles() {
        dynamiteTargetToAttack.forEach { $0.removeFromParent() }
        poisonColumnsTargetToAttack.forEach { $0.removeFromParent() }
        spawnSpiderTargetToAttack.forEach { $0.removeFromParent() }
    }
    
    func handleBossPhaseStart(phase: BossPhase) {
        resetReticles()
    }
    
    func handleBossTurnStart(phase: BossPhase, transformation: Transformation? = nil) {
        switch phase.bossState.stateType {
        case .targetAttack:
            if let dynamiteTargets = phase.bossState.targets.whatToAttack?[.dynamite] {
                showDynamiteReticles(dynamiteTargets)
            }
            
            if let poisonTargets = phase.bossState.poisonAttackColumns {
                showPoisonReticles(poisonTargets)
            }
            
            if let spawnSpiderTargets = phase.bossState.targets.whatToAttack?[.spawnSpider] {
                showSpawnSpiderReticles(spawnSpiderTargets)
            }
            
        case .attack:
            if (transformation != nil) {
                resetReticles()
            }
        default:
            break
        }
    }
    
    func showDynamiteReticles(_ dynamiteTargets: [TileCoord]) {
        for target in dynamiteTargets {
            let redReticle = SKSpriteNode(texture: SKTexture(imageNamed: Constants.redReticleName), size: CGSize(width: tileSize, height: tileSize))
            let targetedTilePosition = sprites[target].position
            redReticle.position = targetedTilePosition
            dynamiteTargetToAttack.append(redReticle)
            containerView.addChild(redReticle)
        }
    }
    
    func showPoisonReticles(_ poisonColumns: [Int]) {
        for column in poisonColumns {
            let poisonReticle = SKSpriteNode(texture: SKTexture(imageNamed: Constants.poisonReticleName), size: Constants.poisonReticleSize.scale(by: tileSize/32))
            let bottomSprite = sprites[0][column]
            
            poisonReticle.position = CGPoint.position(poisonReticle.frame, inside: bottomSprite.frame, verticalAlign: .bottom, horizontalAnchor: .left, translatedToBounds: true)
            
            poisonColumnsTargetToAttack.append(poisonReticle)
            containerView.addChild(poisonReticle)
        }
    }
    
    func showSpawnSpiderReticles(_ spiderTargets: [TileCoord]) {
        for target in spiderTargets {
            let yellowReticle = SKSpriteNode(texture: SKTexture(imageNamed: Constants.yellowReticleName), size: CGSize(width: tileSize, height: tileSize))
            let targetedTilePosition = sprites[target].position
            yellowReticle.position = targetedTilePosition
            spawnSpiderTargetToAttack.append(yellowReticle)
            containerView.addChild(yellowReticle)
        }

    }
    
}
