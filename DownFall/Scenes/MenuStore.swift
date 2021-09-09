//
//  MenuStore.swift
//  DownFall
//
//  Created by Katz, Billy on 8/9/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MenuStoreSceneDelegate: AnyObject {
    func mainMenuTapped(updatedPlayerData: EntityModel)
}

class MenuStoreScene: SKScene, ButtonDelegate {
    
    struct Constants {
        static let offerSlabPadding = CGFloat(35)
    }
    
    private weak var coordinatorDelegate: MenuStoreSceneDelegate?
    private var foreground: SKSpriteNode!
    private var gems: Int
    private var playerModel: EntityModel
    private let playableRect: CGRect
    
    private lazy var backButton: ShiftShaft_Button = {
        
        let button = ShiftShaft_Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .back)
        return button
        
        
    }()
    
    init(size: CGSize,
         playerData: EntityModel,
         coordinatorDelegate: MenuStoreSceneDelegate) {
        
        self.playerModel = playerData
        self.gems = playerModel.carry.total(in: .gem)
        self.playableRect = size.playableRect
        self.coordinatorDelegate = coordinatorDelegate
        
        /// Super init'd
        super.init(size: size)
        
        //acnhor point
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let foreground = SKSpriteNode(color: .backgroundGray, size: playableRect.size)
        self.foreground = foreground
        addChildSafely(foreground)
        
        backButton.position = .position(backButton.frame, inside: foreground.frame, verticalAlign: .top, horizontalAnchor: .right, yOffset: .safeAreaHeight)
        
        foreground.addChildSafely(backButton)
        
        gemContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200.0, height: 250.0))
        gemContainer?.position = CGPoint.position(gemContainer?.frame, inside: playableRect, verticalAlign: .top, horizontalAnchor: .center, yOffset: 250.0)
        
        
        let heightToWidthRatio = CGFloat(2.66)
        let height = CGFloat(275.0)
        
        // health offer container
        healthOfferContainer = SKSpriteNode(texture: SKTexture(imageNamed: "offerSlab"),
                                            color: .clear,
                                            size: CGSize(width: height * heightToWidthRatio,
                                                         height: height))
        healthOfferContainer?.position = CGPoint.alignHorizontally(healthOfferContainer?.frame, relativeTo: gemContainer?.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Constants.offerSlabPadding, translatedToBounds: true)
        
        
        /// luck offer container
        luckOfferContainer = SKSpriteNode(texture: SKTexture(imageNamed: "offerSlab"),
                                          color: .clear,
                                          size: CGSize(width: height * heightToWidthRatio,
                                                       height: height))
        luckOfferContainer?.position = CGPoint.alignHorizontally(luckOfferContainer?.frame, relativeTo: healthOfferContainer?.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Constants.offerSlabPadding, translatedToBounds: true)
        
        
        /// dodge offer container
        dodgeOfferContainer = SKSpriteNode(texture: SKTexture(imageNamed: "offerSlab"),
                                           color: .clear,
                                           size: CGSize(width: height * heightToWidthRatio,
                                                        height: height))
        dodgeOfferContainer?.position = CGPoint.alignHorizontally(dodgeOfferContainer?.frame, relativeTo: luckOfferContainer?.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Constants.offerSlabPadding, translatedToBounds: true)
        
        
        addChildSafely(gemContainer)
        addChildSafely(luckOfferContainer)
        addChildSafely(dodgeOfferContainer)
        addChildSafely(healthOfferContainer)
        updateGemLabel(gems)
        createHealthOffer()
        createLuckOffer()
        createDodgeOffer()
    }
    
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .buyHealth:
            if gems >= healthCost && !disableHealthBuy {
                gems -= healthCost
                playerModel = playerModel.spend(amount: healthCost)
                playerModel = playerModel.addEffect(healthEffect)
                createHealthOffer()
                updateGemLabel(gems)
            }
            
        case .sellHealth:
            if playerModel.hasEffect(healthEffect) {
                playerModel = playerModel.earn(amount: healthCost)
                playerModel = playerModel.removeEffect(healthEffect)
                gems += healthCost
                createHealthOffer()
                updateGemLabel(gems)
            }
            
        case .buyLuck:
            if gems >= luckCost && !disableLuckBuy {
                gems -= luckCost
                playerModel = playerModel.spend(amount: luckCost)
                playerModel = playerModel.addEffect(luckEffect)
                createLuckOffer()
                updateGemLabel(gems)
            }
             
        case .sellLuck:
            if playerModel.hasEffect(luckEffect) {
                playerModel = playerModel.earn(amount: luckCost)
                playerModel = playerModel.removeEffect(luckEffect)
                gems += luckCost
                createLuckOffer()
                updateGemLabel(gems)
            }
            
        case .buyDodge:
            if gems >= dodgeCost && !disableDodgeBuy {
                gems -= dodgeCost
                playerModel = playerModel.spend(amount: dodgeCost)
                playerModel = playerModel.addEffect(dodgeEffect)
                createDodgeOffer()
                updateGemLabel(gems)
            }
            
        case .sellDodge:
            if playerModel.hasEffect(dodgeEffect) {
                playerModel = playerModel.earn(amount: dodgeCost)
                playerModel = playerModel.removeEffect(dodgeEffect)
                gems += dodgeCost
                createDodgeOffer()
                updateGemLabel(gems)
            }
            
        case .back:
            coordinatorDelegate?.mainMenuTapped(updatedPlayerData: playerModel .previewAppliedEffects().revive())
            
        default: break
        }
    }
    
    private var gemContainer: SKSpriteNode?
    
    func updateGemLabel(_ gems: Int?) {
        gemContainer?.removeAllChildren()
        let gemLabel = ParagraphNode(text: "\(gems ?? 0 )", paragraphWidth: 200.0)
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: "crystals"), size: .oneHundred)
        let text = (disableDodgeBuy && disableLuckBuy && disableHealthBuy) ?
            """
            🎊 Congrats. You've unlocked everything.  🎊
            """
            :
            """
            Spend gems you've collected to permanently boost your stats.
            """
        let spendDescription = ParagraphNode(text: text, paragraphWidth: playableRect.width)
        
        spendDescription.position = CGPoint.position(spendDescription.frame, inside: gemContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        gemSprite.position = CGPoint.position(gemSprite.frame, inside: gemContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .left)
        gemLabel.position = CGPoint.position(gemLabel.frame, inside: gemContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .right, yOffset: Style.Padding.more)
        
        gemContainer?.addChild(spendDescription)
        gemContainer?.addChild(gemLabel)
        gemContainer?.addChild(gemSprite)
    }
    
    
    private var healthOfferContainer: SKSpriteNode?
    func createHealthOffer() {
        healthOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellHealth,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(healthEffect)
        )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyHealth,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableHealthBuy
        )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "fullHeart"), size: .oneHundred)
        let description = ParagraphNode(text: "Max Health \(playerModel.previewAppliedEffects().originalHp)", paragraphWidth: 400.0, fontSize: .fontLargeSize)
        let costDescription = ParagraphNode(text: "Cost: \(healthCost) gems", paragraphWidth: 800.0, fontSize: .fontLargeSize)
        
        
        minusButton.position = CGPoint.position(minusButton.frame,
                                                inside: healthOfferContainer?.frame,
                                                verticalAlign: .center,
                                                horizontalAnchor: .left,
                                                xOffset: Style.Padding.most
        )
        plusButton.position = CGPoint.position(plusButton.frame,
                                               inside: healthOfferContainer?.frame,
                                               verticalAlign: .center,
                                               horizontalAnchor: .right,
                                               xOffset: Style.Padding.most
        )
        
        description.position = CGPoint.position(description.frame, inside: healthOfferContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        heartNode.position = .zero
        costDescription.position = CGPoint.position(costDescription.frame, inside: healthOfferContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.more)
        
        healthOfferContainer?.addChild(minusButton)
        healthOfferContainer?.addChild(plusButton)
        healthOfferContainer?.addChild(heartNode)
        healthOfferContainer?.addChild(description)
        healthOfferContainer?.addChild(costDescription)
        
        healthOfferContainer?.addZPositionToChildren(Precedence.menu.rawValue)
        
    }
    
    private var luckOfferContainer: SKSpriteNode?
    func createLuckOffer() {
        luckOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellLuck,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(luckEffect)
        )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyLuck,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableLuckBuy
        )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "luck"), size: .oneHundred)
        let description = ParagraphNode(text: "Luck: \(playerModel.previewAppliedEffects().luck)", paragraphWidth: 400.0, fontSize: .fontLargeSize)
        let costDescription = ParagraphNode(text: "Cost: \(luckCost) gems", paragraphWidth: 800.0, fontSize: .fontLargeSize)
        
        
        minusButton.position = CGPoint.position(minusButton.frame,
                                                inside: luckOfferContainer?.frame,
                                                verticalAlign: .center,
                                                horizontalAnchor: .left,
                                                xOffset: Style.Padding.most
        )
        plusButton.position = CGPoint.position(plusButton.frame,
                                               inside: luckOfferContainer?.frame,
                                               verticalAlign: .center,
                                               horizontalAnchor: .right,
                                               xOffset: Style.Padding.most
        )
        
        description.position = CGPoint.position(description.frame, inside: luckOfferContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        heartNode.position = .zero
        costDescription.position = CGPoint.position(costDescription.frame, inside: luckOfferContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.more)
        
        luckOfferContainer?.addChild(minusButton)
        luckOfferContainer?.addChild(plusButton)
        luckOfferContainer?.addChild(heartNode)
        luckOfferContainer?.addChild(description)
        luckOfferContainer?.addChild(costDescription)
        
        luckOfferContainer?.addZPositionToChildren(Precedence.menu.rawValue)
        
    }
    
    
    private var dodgeOfferContainer: SKSpriteNode?
    func createDodgeOffer() {
        dodgeOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellDodge,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(dodgeEffect)
        )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = ShiftShaft_Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyDodge,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableDodgeBuy
        )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "dodge"), size: .oneHundred)
        let description = ParagraphNode(text: "Dodge: \(playerModel.previewAppliedEffects().dodge)", paragraphWidth: 400.0, fontSize: .fontLargeSize)
        let costDescription = ParagraphNode(text: "Cost: \(dodgeCost) gems", paragraphWidth: 800.0, fontSize: .fontLargeSize)
        
        
        minusButton.position = CGPoint.position(minusButton.frame,
                                                inside: dodgeOfferContainer?.frame,
                                                verticalAlign: .center,
                                                horizontalAnchor: .left,
                                                xOffset: Style.Padding.most
        )
        plusButton.position = CGPoint.position(plusButton.frame,
                                               inside: dodgeOfferContainer?.frame,
                                               verticalAlign: .center,
                                               horizontalAnchor: .right,
                                               xOffset: Style.Padding.most
        )
        
        description.position = CGPoint.position(description.frame, inside: dodgeOfferContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        heartNode.position = .zero
        costDescription.position = CGPoint.position(costDescription.frame, inside: dodgeOfferContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.more)
        
        dodgeOfferContainer?.addChild(minusButton)
        dodgeOfferContainer?.addChild(plusButton)
        dodgeOfferContainer?.addChild(heartNode)
        dodgeOfferContainer?.addChild(description)
        dodgeOfferContainer?.addChild(costDescription)
        
        dodgeOfferContainer?.addZPositionToChildren(Precedence.menu.rawValue)
        
    }
    
    private let dodgeCost = 5
    private let luckCost = 5
    private let healthCost = 15
    
    private let luckEffect = EffectModel(kind: .buff, stat: .luck, amount: 2, duration: 0, offerTier: 1)
    private let dodgeEffect = EffectModel(kind: .buff, stat: .dodge, amount: 2, duration: 0, offerTier: 1)
    private let healthEffect = EffectModel(kind: .buff, stat: .maxHealth, amount: 1, duration: 0, offerTier: 1)
    
    var disableHealthBuy: Bool {
        return playerModel.previewAppliedEffects().originalHp >= EntityModel.maxPlayerHealth
    }
    
    var disableLuckBuy: Bool {
        return playerModel.previewAppliedEffects().luck >= EntityModel.maxPlayerLuck
    }
    
    var disableDodgeBuy: Bool {
        return playerModel.previewAppliedEffects().dodge >= EntityModel.maxPlayerDodge
    }
    
}
