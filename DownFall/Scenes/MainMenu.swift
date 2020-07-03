//
//  MainMenu.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol MainMenuDelegate: class {
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?, level: LevelType)
    func didSelectStartTutorial(_ playerModel: EntityModel?)
    var mainViewController: UIViewController { get }
}

class MainMenu: SKScene {
    
    struct Constants {
        static let offerSlabPadding = CGFloat(35)
    }
    
    private var background: SKSpriteNode!
    private var header: Header?
    private var difficultyLabel: ParagraphNode?
    private var levelLabel: ParagraphNode?
    private var levelSelectButton: Button?
    private var profileSelectButton: Button?
    private var newProfileButton:Button?
    private var profileSaving: ProfileSaving = ProfileViewModel()
    private var gems: Int = 0
    weak var mainMenuDelegate: MainMenuDelegate?
    var playerModel: EntityModel?
    
    private var levelTypeIndex = 0 {
        didSet {
            levelLabel?.removeFromParent()
            levelLabel = ParagraphNode(text: "\(LevelType.gameCases[levelTypeIndex])",
                paragraphWidth: 300,
                fontColor: .white)
            levelLabel?.zPosition = Precedence.menu.rawValue
            levelLabel?.position = CGPoint.alignHorizontally(levelLabel?.frame, relativeTo: levelSelectButton?.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: Style.Padding.most, translatedToBounds: true)
            addOptionalChild(levelLabel)
            
        }
    }
    
    override func didMove(to view: SKView) {
        
        // start to authenticate
        profileSaving.authenticate(mainMenuDelegate!.mainViewController)
        
        background = self.childNode(withName: "background") as? SKSpriteNode
        background.color = UIColor.clayRed
        
        
        let startButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .newGame,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white,
                                 backgroundColor: .menuPurple)
        
        startButton.position = CGPoint.position(startButton.frame,
                                                inside: size.playableRect,
                                                verticalAlign: .bottom,
                                                horizontalAnchor: .right,
                                                xOffset: 50.0,
                                                yOffset: 100.0
        )
        addChild(startButton)
        
        let levelButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .cycleLevel,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white,
                                 backgroundColor: .menuPurple)
        
        levelButton.position = CGPoint.alignVertically(levelButton.frame,
                                                       relativeTo: startButton.frame,
                                                       horizontalAnchor: .left,
                                                       verticalAlign: .center,
                                                       horizontalPadding: 200.0,
                                                       translatedToBounds: true)
        levelSelectButton = levelButton
        
        addChild(levelButton)
        
        
        let profileButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .selectProfile,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white,
                                 backgroundColor: .menuPurple)
        
        profileButton.position = CGPoint.position(profileButton.frame,
                                                    inside: size.playableRect,
                                                    verticalAlign: .top,
                                                    horizontalAnchor: .right,
                                                    xOffset: 50.0,
                                                    yOffset: 100.0)
        profileSelectButton = profileButton
        
        addChild(profileButton)
        
        
        let newProfileButton = Button(size: Style.RunMenu.buttonSize,
                                 delegate: self,
                                 identifier: .newProfile,
                                 precedence: .menu,
                                 fontSize: UIFont.largeSize,
                                 fontColor: UIColor.white,
                                 backgroundColor: .menuPurple)
        
        newProfileButton.position = CGPoint.alignVertically(levelButton.frame,
                                                            relativeTo: profileSelectButton?.frame,
                                                            horizontalAnchor: .left,
                                                            verticalAlign: .center,
                                                            horizontalPadding: 200.0,
                                                            translatedToBounds: true)

        self.newProfileButton = newProfileButton
        
        addChild(newProfileButton)

        
        levelTypeIndex = 0
        
        let playableRect = size.playableRect
        
        header = Header.build(color: .black,
                              size: CGSize(width: playableRect.width, height: Style.Header.height),
                              precedence: .foreground,
                              delegate: self)
        header?.position = CGPoint.position(this: header?.frame ?? .zero, centeredInBottomOf: playableRect, verticalPadding: 25.0)
        
        self.gems = playerModel?.carry.total(in: .gem) ?? 0
        playerModel = playerModel?.resetToBaseStats()
        
        gemContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200.0, height: 250.0))
        gemContainer?.position = CGPoint.position(gemContainer?.frame, inside: playableRect, verticalAlign: .top, horizontalAnchor: .center, yOffset: 75.0)
        
        
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
        
        //rune slot offer container
        runeSlotOfferContainer = SKSpriteNode(texture: SKTexture(imageNamed: "offerSlab"),
                                              color: .clear,
                                              size: CGSize(width: height * heightToWidthRatio,
                                                           height: height))
        runeSlotOfferContainer?.position = CGPoint.alignHorizontally(runeSlotOfferContainer?.frame, relativeTo: dodgeOfferContainer?.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: Constants.offerSlabPadding, translatedToBounds: true)
        
        
        if gems > 0 {
            addChildSafely(gemContainer)
            addChildSafely(luckOfferContainer)
            addChildSafely(dodgeOfferContainer)
            addChildSafely(healthOfferContainer)
            addChildSafely(runeSlotOfferContainer)
            updateGemLabel(gems)
            createHealthOffer()
            createLuckOffer()
            createDodgeOffer()
            createRuneSlotOffer()
        }
        
    }
    
    private var gemContainer: SKSpriteNode?
    
    func updateGemLabel(_ gems: Int?) {
        gemContainer?.removeAllChildren()
        let gemLabel = ParagraphNode(text: "\(gems ?? 0 )", paragraphWidth: 200.0)
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: "crystals"), size: .oneHundred)
        let spendDescription = ParagraphNode(text: "Spend gems you collected last run", paragraphWidth: 600.0)
        
        spendDescription.position = CGPoint.position(spendDescription.frame, inside: gemContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        gemSprite.position = CGPoint.position(gemSprite.frame, inside: gemContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .left)
        gemLabel.position = CGPoint.position(gemLabel.frame, inside: gemContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .right, yOffset: Style.Padding.more)
        
        gemContainer?.addChild(spendDescription)
        gemContainer?.addChild(gemLabel)
        gemContainer?.addChild(gemSprite)
    }
    
    
    private var healthOfferContainer: SKSpriteNode?
    func createHealthOffer() {
        guard let playerModel = playerModel else { return }
        healthOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellHealth,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(healthEffect)
                                 )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyHealth,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableHealthBuy
        )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "fullHeart"), size: .oneHundred)
        let description = ParagraphNode(text: "Max Health \(playerModel.previewAppliedEffects().originalHp)", paragraphWidth: 400.0, fontSize: UIFont.largeSize)
        let costDescription = ParagraphNode(text: "Cost: 2 gems ( Max \(maxHealthBuys) )", paragraphWidth: 800.0, fontSize: UIFont.largeSize)
        
        
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
        guard let playerModel = playerModel else { return }
        luckOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellLuck,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(luckEffect)
                                 )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyLuck,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableLuckBuy
                                )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "luck"), size: .oneHundred)
        let description = ParagraphNode(text: "Luck: \(playerModel.previewAppliedEffects().luck)", paragraphWidth: 400.0, fontSize: UIFont.largeSize)
        let costDescription = ParagraphNode(text: "Cost: 3 gems ( Max \(maxLuckBuys) )", paragraphWidth: 800.0, fontSize: UIFont.largeSize)
        
        
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
        guard let playerModel = playerModel else { return }
        dodgeOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellDodge,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(dodgeEffect)
                                 )
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyDodge,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: disableDodgeBuy
                                )
        
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "dodge"), size: .oneHundred)
        let description = ParagraphNode(text: "Dodge: \(playerModel.previewAppliedEffects().dodge)", paragraphWidth: 400.0, fontSize: UIFont.largeSize)
        let costDescription = ParagraphNode(text: "Cost: 3 gems ( Max \(maxDodgeBuys) )", paragraphWidth: 800.0, fontSize: UIFont.largeSize)
        
        
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
    
    private var runeSlotOfferContainer: SKSpriteNode?
    func createRuneSlotOffer() {
        guard let playerModel = playerModel else { return }
        runeSlotOfferContainer?.removeAllChildren()
        let minusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "minusButton"), size: .oneHundred)
        let minusButton = Button(size: CGSize(width: 80, height: 80),
                                 delegate: self,
                                 identifier: .sellRuneSlot,
                                 image: minusTexture,
                                 shape: .rectangle,
                                 disable: !playerModel.hasEffect(runeSlotEffect))
        
        let plusTexture = SKSpriteNode(texture: SKTexture(imageNamed: "plusButton"), size: .oneHundred)
        let plusButton = Button(size: CGSize(width: 80, height: 80),
                                delegate: self,
                                identifier: .buyRuneSlot,
                                image: plusTexture,
                                shape: .rectangle,
                                disable: playerModel.hasEffect(runeSlotEffect))
        

        let description = ParagraphNode(text: "Rune Slots: \(playerModel.previewAppliedEffects().pickaxe?.runeSlots ?? 0)", paragraphWidth: 400.0, fontSize: UIFont.largeSize)
        let costDescription = ParagraphNode(text: "Cost: \(runeSlotCost) gems ( Max \(maxRuneSlotBuys) )", paragraphWidth: 800.0, fontSize: UIFont.largeSize)
        
        
        minusButton.position = CGPoint.position(minusButton.frame,
                                                inside: runeSlotOfferContainer?.frame,
                                                verticalAlign: .center,
                                                horizontalAnchor: .left,
                                                xOffset: Style.Padding.most
        )
        plusButton.position = CGPoint.position(plusButton.frame,
                                               inside: runeSlotOfferContainer?.frame,
                                               verticalAlign: .center,
                                               horizontalAnchor: .right,
                                               xOffset: Style.Padding.most
        )
        
        description.position = CGPoint.position(description.frame, inside: runeSlotOfferContainer?.frame, verticalAlign: .top, horizontalAnchor: .center)
        //        heartNode.position = .zero
        costDescription.position = CGPoint.position(costDescription.frame, inside: runeSlotOfferContainer?.frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.more)
        
        runeSlotOfferContainer?.addChild(minusButton)
        runeSlotOfferContainer?.addChild(plusButton)
        runeSlotOfferContainer?.addChild(description)
        runeSlotOfferContainer?.addChild(costDescription)
        
        runeSlotOfferContainer?.addZPositionToChildren(Precedence.menu.rawValue)
        
    }
    
    
    private let maxHealthBuys = 3
    private let maxLuckBuys = 5
    private let maxDodgeBuys = 5
    private let maxRuneSlotBuys = 1
    
    private let runeSlotCost = 5
    private let dodgeCost = 3
    private let luckCost = 3
    private let healthCost = 2
    
    private let runeSlotEffect = EffectModel(kind: .buff, stat: .runeSlot, amount: 1, duration: 0, offerTier: 1)
    private let luckEffect = EffectModel(kind: .buff, stat: .luck, amount: 5, duration: 0, offerTier: 1)
    private let dodgeEffect = EffectModel(kind: .buff, stat: .dodge, amount: 5, duration: 0, offerTier: 1)
    private let healthEffect = EffectModel(kind: .buff, stat: .maxHealth, amount: 1, duration: 0, offerTier: 1)
    
    var disableHealthBuy: Bool {
        guard let playerModel = playerModel else { return false }
        return playerModel.numberOfEffects(healthEffect) >= maxHealthBuys
    }
    
    var disableLuckBuy: Bool {
        guard let playerModel = playerModel else { return false }
        return playerModel.numberOfEffects(luckEffect) >= maxLuckBuys
    }
    
    var disableDodgeBuy: Bool {
        guard let playerModel = playerModel else { return false }
        return playerModel.numberOfEffects(dodgeEffect) >= maxDodgeBuys
    }
}



extension MainMenu: SettingsDelegate {
    func settingsTapped() {
        let difficultyIndex = GameScope.shared.difficulty.rawValue - 1
        GameScope.shared.difficulty = Difficulty.allCases[(difficultyIndex + 1) % Difficulty.allCases.count]
    }
}

extension MainMenu: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        guard let playerModel = self.playerModel else { return }
        switch button.identifier {
        case .newGame:
            mainMenuDelegate?.newGame(GameScope.shared.difficulty,
                                      playerModel.previewAppliedEffects().healFull(),
                                      level: LevelType.gameCases[levelTypeIndex])
        case .startTutorial:
            mainMenuDelegate?.didSelectStartTutorial(playerModel)
        case .selectProfile:
            profileSaving.loadProfile(name: "Billy") {
                print($0?.name)
            }
        case .newProfile:
            profileSaving.saveProfile(name: "Billy") { (success) in
                print(success)
            }
        case .cycleLevel:
            if levelTypeIndex + 1 == LevelType.gameCases.count {
                levelTypeIndex = 0
            } else {
                levelTypeIndex += 1
            }
            
        case .buyHealth:
            if gems >= healthCost && playerModel.numberOfEffects(healthEffect) < maxHealthBuys {
                gems -= healthCost
                self.playerModel = playerModel.addEffect(healthEffect)
                createHealthOffer()
                updateGemLabel(gems)
            }
            
        case .sellHealth:
            if playerModel.hasEffect(healthEffect) {
                self.playerModel = playerModel.removeEffect(healthEffect)
                gems += healthCost
                createHealthOffer()
                updateGemLabel(gems)
            }
            
        case .buyLuck:
            if gems >= luckCost && playerModel.numberOfEffects(luckEffect) < maxLuckBuys {
                gems -= luckCost
                self.playerModel = playerModel.addEffect(luckEffect)
                createLuckOffer()
                updateGemLabel(gems)
            }
            
        case .sellLuck:
            if playerModel.hasEffect(luckEffect) {
                self.playerModel = playerModel.removeEffect(luckEffect)
                gems += luckCost
                createLuckOffer()
                updateGemLabel(gems)
            }
            
        case .buyDodge:
            if gems >= dodgeCost && playerModel.numberOfEffects(dodgeEffect) < maxDodgeBuys {
                gems -= dodgeCost
                self.playerModel = playerModel.addEffect(dodgeEffect)
                createDodgeOffer()
                updateGemLabel(gems)
            }
            
        case .sellDodge:
            if playerModel.hasEffect(dodgeEffect) {
                self.playerModel = playerModel.removeEffect(dodgeEffect)
                gems += dodgeCost
                createDodgeOffer()
                updateGemLabel(gems)
            }
            
        case .buyRuneSlot:
            if gems >= runeSlotCost  && playerModel.numberOfEffects(runeSlotEffect) < maxRuneSlotBuys {
                gems -= runeSlotCost
                self.playerModel = playerModel.addEffect(runeSlotEffect)
                createRuneSlotOffer()
                updateGemLabel(gems)
            }

        case .sellRuneSlot:
            if playerModel.hasEffect(runeSlotEffect) {
                self.playerModel = playerModel.removeEffect(runeSlotEffect)
                gems += runeSlotCost
                createRuneSlotOffer()
                updateGemLabel(gems)
            }

        default:
            ()
        }
    }
}
