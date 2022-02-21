//
//  HUD.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

enum HUDElement: String {
    case health
    case gems
    case dodge
    case luck
}

class HUD: SKSpriteNode {
    
    struct Constants {
        static let levelGoalIndicator = "levelGoalIndicator"
        
        static let dodgeAmountLabelName = "dodgeAmountLabelName"
        static let luckAmountLabelName = "luckAmountLabelName"
        static let currentHealthAmountLabelName = "currentHealthAmountLabelName"
        static let totalHealthAmountLabelName = "toalHealthAmountLabelName"
        static let gemAmountLabelName = "gemAmountLabelName"
    }
    
    static func build(color: UIColor, size: CGSize, delegate: SettingsDelegate?, level: Level) -> HUD {
        let header = HUD(texture: nil, color: .clear, size: size)
        
        let settingsTapTarget = SKSpriteNode(texture: nil, size: Style.HUD.settingsTapTargetSize)
        let setting = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.settings), color: .clear , size: Style.HUD.settingsSize)
        
        settingsTapTarget.name = Identifiers.settings
        settingsTapTarget.position = CGPoint.position(setting.frame,
                                            inside: header.frame,
                                            verticalAlign: .top,
                                            horizontalAnchor: .right,
                                            xOffset: 80.0,
                                            yOffset: -40.0
                                            
        )
        settingsTapTarget.zPosition = 1_000_000
        settingsTapTarget.addChild(setting)
        
        header.addChild(settingsTapTarget)
        
        
        let depthLevelTitle = ParagraphNode(text: "Depth", fontSize: .fontLargeSize, fontColor: .lightText)
        let depthLevelNumber = ParagraphNode(text: level.humanReadableDepth, fontSize: .fontLargeSize, fontColor: .lightText)
        depthLevelNumber.position = CGPoint.position(depthLevelNumber.frame, inside: header.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: 100, yOffset: 10)
        depthLevelNumber.name = Identifiers.depthLevelLabel
        depthLevelTitle.position = CGPoint.alignHorizontally(depthLevelTitle.frame, relativeTo: depthLevelNumber.frame, horizontalAnchor: .center, verticalAlign: .top, translatedToBounds: true)
        depthLevelTitle.name = Identifiers.depthLevelLabel
        header.addChild(depthLevelNumber)
        header.addChild(depthLevelTitle)
        
        header.isUserInteractionEnabled = true
        header.delegate = delegate
        
        
        Dispatch.shared.register { [weak header] in
            header?.handle($0)
        }
        
        return header
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentTotalGem: Int = 0
    let animator = Animator()
    
    var dodgeSprite: SKSpriteNode?
    var healthSprite: SKSpriteNode?
    var luckSprite: SKSpriteNode?
    var gemSpriteNode: SKSpriteNode?
    
    weak var delegate: SettingsDelegate?
    
    //Mark: - Instance Methods
    
    func handle(_ input: Input) {
        switch input.type {
        case .transformation(let trans):
            guard let inputType = trans.first?.inputType else { return }
            switch inputType {
            case .itemUsed, .decrementDynamites, .gameWin, .noMoreMoves, .noMoreMovesConfirm, .attack:
                if let tiles = trans.first?.endTiles,
                   let playerCoord = getTilePosition(.player(.zero), tiles: tiles),
                   case TileType.player(let data) = tiles[playerCoord].type {
                    show(data)
                }
                
            default:
                ()
            }
        case .boardBuilt,. boardLoaded:
            guard let tiles = input.endTilesStruct,
                  let playerPosition = getTilePosition(.player(.zero), tiles: tiles),
                  case let TileType.player(data) = tiles[playerPosition].type else { return }
            show(data)
            
        default:
            ()
        }
    }
    
    func show(_ data: EntityModel) {
        // Remove all the hearts so that we can redraw
        self.removeAllChildren(exclude: [Identifiers.settings, Constants.levelGoalIndicator, Identifiers.depthLevelLabel])
        
        
        let identifier = Identifiers.fullHeart
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                     size: Style.HUD.heartSize)
        healthSprite = heartNode
        heartNode.position = CGPoint.position(heartNode.frame,
                                              inside: self.frame,
                                              verticalAlign: .top,
                                              horizontalAnchor: .left,
                                              xOffset: self.frame.width/8,
                                              yOffset: Style.Padding.most*4)
        
        let currentHealthText = ParagraphNode(text: "\(data.hp)", paragraphWidth: 100.0, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        currentHealthText.position = CGPoint.alignVertically(currentHealthText.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most,  translatedToBounds: true)
        currentHealthText.name = Constants.currentHealthAmountLabelName

        let slashText = ParagraphNode(text: "/", paragraphWidth: 100.0, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        slashText.position = CGPoint.alignVertically(slashText.frame, relativeTo: currentHealthText.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        
        let totalHealthText = ParagraphNode(text: "\(data.originalHp)", paragraphWidth: Style.HUD.heartSize.width*2, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        totalHealthText.position = CGPoint.alignVertically(totalHealthText.frame, relativeTo: slashText.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        totalHealthText.name = Constants.totalHealthAmountLabelName
        
        self.addChildSafely(heartNode)
        addChild(currentHealthText)
        addChild(slashText)
        addChild(totalHealthText)
        
        // the sprite of the gem
        let gemNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.heartSize)
        gemNode.position = CGPoint.alignVertically(gemNode.frame, relativeTo: totalHealthText.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most * 2, translatedToBounds: true)
        gemSpriteNode = gemNode
        
        // the label with the player's amount of gems
        let gemLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        gemLabel.position = CGPoint.alignVertically(gemLabel.frame, relativeTo: gemNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        gemLabel.name = Constants.gemAmountLabelName
        
        // save this data for later
        currentTotalGem = data.carry.total(in: .gem)
        
        // display the player's dodge
        let dodgeNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.dodgeSprite), size: Style.HUD.dodgeLuckStatSize)
        dodgeNode.position = CGPoint.alignVertically(dodgeNode.frame, relativeTo: gemLabel.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most * 2, translatedToBounds: true)
        dodgeSprite = dodgeNode
        
        let dodgeAmountNode = ParagraphNode(text: "\(data.dodge)", paragraphWidth: self.size.width, fontColor: .lightText)
        dodgeAmountNode.position = CGPoint.alignVertically(dodgeAmountNode.frame, relativeTo: dodgeNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds:  true)
        dodgeAmountNode.name = Constants.dodgeAmountLabelName
        // display the player's luck
        let luckNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.luckSprite), size: Style.HUD.dodgeLuckStatSize)
        luckNode.position = CGPoint.alignVertically(luckNode.frame, relativeTo: dodgeAmountNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most * 2, translatedToBounds: true)
        luckSprite = luckNode
        
        
        let luckAmountNode = ParagraphNode(text: "\(data.luck)", paragraphWidth: self.size.width, fontColor: .lightText)
        luckAmountNode.position = CGPoint.alignVertically(luckAmountNode.frame, relativeTo: luckNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
        luckAmountNode.name = Constants.luckAmountLabelName
        

        self.addChild(gemNode)
        self.addChild(gemLabel)
        self.addChild(dodgeNode)
        self.addChild(dodgeAmountNode)
        self.addChild(luckNode)
        self.addChild(luckAmountNode)

    }
    
    func targetSprite(for offerType: StoreOfferType) -> SKSpriteNode? {
        switch offerType {
        case .dodge:
            return dodgeSprite
        case .luck:
            return luckSprite
        case .greaterHeal, .lesserHeal, .plusTwoMaxHealth, .plusOneMaxHealth:
            return healthSprite
        default:
            return nil
        }

    }
    
    func incrementStat(offer: StoreOfferType, updatedPlayerData: EntityModel?, totalToIncrement: Int) {
        switch offer {
        case .dodge(amount: let amount):
            showIncreaseInStat(offerType: offer, amountIncrease: amount)
        case .luck(amount: let amount):
            showIncreaseInStat(offerType: offer, amountIncrease: amount)
        case .greaterHeal:
            guard let updatedPlayerData = updatedPlayerData else {
                return
            }
            let maxHealthGain = min(2, updatedPlayerData.originalHp - updatedPlayerData.hp)
            showIncreaseInStat(offerType: offer, amountIncrease: maxHealthGain)
        case .lesserHeal:
            guard let updatedPlayerData = updatedPlayerData else {
                return
            }
            let maxHealthGain = min(1, updatedPlayerData.originalHp - updatedPlayerData.hp)
            showIncreaseInStat(offerType: offer, amountIncrease: maxHealthGain)
        case .plusTwoMaxHealth:
            showIncreaseInStat(offerType: offer, amountIncrease: 2)
        case .plusOneMaxHealth:
            showIncreaseInStat(offerType: offer, amountIncrease: 1)
        case .gems(let amount):
            showTotalGemGain(amount)
        case .sandals, .runningShoes, .wingedBoots:
            showIncreaseInStat(offerType: offer, amountIncrease: offer.dodgeAmount)
        case .fourLeafClover, .horseshoe, .luckyCat:
            showIncreaseInStat(offerType: offer, amountIncrease: offer.luckAmount)
        case .gemMagnet:
            showIncreaseInStat(offerType: offer, amountIncrease: totalToIncrement)
        default:
            return
        }
    }
    
    private func showIncreaseInStat(offerType: StoreOfferType, amountIncrease: Int) {
        
        showIncreaseInStatByOne(offer: offerType, amountIncrease: amountIncrease)
        let waitTime = Double(amountIncrease) * 0.2 / 2
        
        if let labelNames = labelNameForOfferType(offer: offerType) {
            for labelName in labelNames {
                if let currencyLabel = self.childNode(withName: labelName) as? ParagraphNode {
                    let oldPosition = currencyLabel.position
                    
                    // show exaclty how much gold was gained as well
                    let gainedGoldLabel = ParagraphNode(text: "+\(amountIncrease)", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .goldOutlineBright)
                    gainedGoldLabel.position = oldPosition.translateVertically(40.0)
                    addChildSafely(gainedGoldLabel)
                    let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: AnimationSettings.HUD.goldGainedTime)
                    let moveAndFade = SKAction.group([moveUp, SKAction.fadeOut(withDuration: AnimationSettings.HUD.gemCountFadeTime)])
                    let sequence = SKAction.sequence([SKAction.wait(forDuration: waitTime), moveAndFade, SKAction.removeFromParent()])
                    gainedGoldLabel.run(sequence)
                }
            }
        }
    }
    
//    public func positionOfHUDElement(_ hudELement: HUDElement) -> CGPoint {
//        let position: CGPoint?
//        switch hudELement {
//        case .health:
//            position = self.childNode(withName: Constants.currentHealthAmountLabelName)?.position
//        case .gems:
//            position = self.childNode(withName: Constants.gemAmountLabelName)?.position
//        case .dodge:
//            position = self.childNode(withName: Constants.dodgeAmountLabelName)?.position
//        case .luck:
//            position = self.childNode(withName: Constants.luckAmountLabelName)?.position
//        }
//
//        return position ?? .zero
//    }
//
//    private func labelNameForHUDElement(_ hudElement: HUDElement) -> [String]? {
//        switch hudElement {
//        case .health:
//            return [Constants.currentHealthAmountLabelName]
//        case .gems:
//            return [Constants.gemAmountLabelName]
//        case .dodge:
//            return [Constants.dodgeAmountLabelName]
//        case .luck:
//            return [Constants.luckAmountLabelName]
//        }
//    }
    
    private func labelNameForOfferType(offer: StoreOfferType) -> [String]? {
        switch offer {
        case .dodge, .sandals, .runningShoes, .wingedBoots:
            return [Constants.dodgeAmountLabelName]
        case .luck, .fourLeafClover, .horseshoe, .luckyCat:
            return [Constants.luckAmountLabelName]
        case .greaterHeal:
            return [Constants.currentHealthAmountLabelName]
        case .lesserHeal:
            return [Constants.currentHealthAmountLabelName]
        case .plusTwoMaxHealth:
            return [Constants.currentHealthAmountLabelName, Constants.totalHealthAmountLabelName]
        case .plusOneMaxHealth:
            return [Constants.currentHealthAmountLabelName, Constants.totalHealthAmountLabelName]
        case .gemMagnet:
            return [Constants.gemAmountLabelName]
        default:
            return nil
        }
    }
    
    private func showIncreaseInStatByOne(offer: StoreOfferType, amountIncrease: Int) {
        if let currencyLabelIdentifiers = labelNameForOfferType(offer: offer) {
            for currencyLabelIdentifier in currencyLabelIdentifiers {
                
                // some items tick up multiple stats like +1 max health
                var actions: [SKAction] = []
                var waitTime = 0.05
                for _ in 1..<amountIncrease+1 {
                    let addNewLabel = SKAction.run {
                        if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode,
                           let currentTotal = Int(currencyLabel.text) {
                            
                            let parent = currencyLabel.parent
                            
                            let newCurrencyLabel = ParagraphNode(text: "\(currentTotal + 1)", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .lightText)
                            newCurrencyLabel.position = currencyLabel.position
                            newCurrencyLabel.name = currencyLabelIdentifier
                            
                            // remove it
                            currencyLabel.removeFromParent()
                            
                            //add the new one
                            parent?.addChildSafely(newCurrencyLabel)
                        }
                    }
                    
                    let sequence = SKAction.sequence([SKAction.wait(forDuration: waitTime), addNewLabel ])
                    sequence.timingMode = .easeOut
                    actions.append(sequence)
                    
                }
                waitTime += 0.05
                
                if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode {
                    currencyLabel.parent?.run(SKAction.sequence(actions))
                }
                
            }
        }
    }
    
    func incrementCurrencyCountByOne() {
        let currencyLabelIdentifier = Constants.gemAmountLabelName
        
        let localCurrenTotal = currentTotalGem
        
        if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode {
            // get the position and save it
            let oldPosition = currencyLabel.position
            // remove it
            currencyLabel.removeFromParent()
            
            let newCurrencyLabel = ParagraphNode(text: "\(localCurrenTotal + 1)", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .lightText)
            newCurrencyLabel.position = oldPosition
            newCurrencyLabel.name = currencyLabelIdentifier
            addChildSafely(newCurrencyLabel)

        }
        
        currentTotalGem += 1
    }
    
    func showTotalGemGain(_ totalGained: Int) {
        if let currencyLabel = self.childNode(withName: Constants.gemAmountLabelName) as? ParagraphNode {
            let oldPosition = currencyLabel.position

            // show exaclty how much gold was gained as well
            let gainedGoldLabel = ParagraphNode(text: "+\(totalGained)", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .goldOutlineBright)
            gainedGoldLabel.position = oldPosition.translateVertically(40.0)
            addChildSafely(gainedGoldLabel)
            let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: AnimationSettings.HUD.goldGainedTime)
            let moveAndFade = SKAction.group([moveUp, SKAction.fadeOut(withDuration: AnimationSettings.HUD.gemCountFadeTime)])
            let sequence = SKAction.sequence([moveAndFade, .removeFromParent()])
            sequence.timingMode = .easeIn
            gainedGoldLabel.run(sequence)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if node.name == Identifiers.settings {
                delegate?.settingsTapped()
            }
        }
    }
    
}

//extension HUD: ButtonDelegate {
//    func buttonTapped(_ button: ShiftShaft_Button) {
//        switch button.identifier {
//        default:
//            ()
//        }
//    }
//}
