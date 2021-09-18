//
//  HUD.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class HUD: SKSpriteNode {
    
    struct Constants {
        static let threatIndicator = "threatIndicator"
        static let shuffleBoardButton = "shuffleBoardButton"
        static let levelGoalIndicator = "levelGoalIndicator"
        
        static let dodgeAmountLabelName = "dodgeAmountLabelName"
        static let luckAmountLabelName = "luckAmountLabelName"
        static let currentHealthAmountLabelName = "currentHealthAmountLabelName"
        static let totalHealthAmountLabelName = "toalHealthAmountLabelName"
        static let gemAmountLabelName = "gemAmountLabelName"
    }
    
    static func build(color: UIColor, size: CGSize, delegate: SettingsDelegate?, level: Level) -> HUD {
        let header = HUD(texture: nil, color: .clear, size: size)
        
        let setting = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.settings), color: .clear , size: Style.HUD.settingsSize)
        
        setting.name = Identifiers.settings
        setting.position = CGPoint.position(setting.frame,
                                            inside: header.frame,
                                            verticalAlign: .top,
                                            horizontalAnchor: .right)
        setting.zPosition = 1_000_000
        
        header.addChild(setting)
        
        header.isUserInteractionEnabled = true
        header.delegate = delegate
        
        header.level = level
        
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
    var level: Level?
    
    //Mark: - Instance Methods
    
    private func showAttack(attackInput: Input, endTiles: [[Tile]]?) {
        if case InputType.attack(_,
                                 _,
                                 let defenderPosition,
                                 _,
                                 _,
                                 _) = attackInput.type {
            print("Defender position \(String(describing: defenderPosition))")
        }
        guard let tiles = endTiles else { return }
        
        for tile in tiles.flatMap({ $0 }) {
            if case let TileType.player(playerData) = tile.type {
                show(playerData)
            }
        }
    }
    
    func handle(_ input: Input) {
        switch input.type {
        case .transformation(let trans):
            guard let inputType = trans.first?.inputType else { return }
            switch inputType {
            case .attack:
                showAttack(attackInput: input, endTiles: trans.first!.endTiles)
            case .itemUsed, .decrementDynamites, .shuffleBoard, .collectOffer, .gameWin:
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
        self.removeAllChildren(exclude: [Identifiers.settings, Constants.threatIndicator, Constants.shuffleBoardButton, Constants.levelGoalIndicator])
        
        
        let identifier = Identifiers.fullHeart
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                     size: Style.HUD.heartSize)
        healthSprite = heartNode
        heartNode.position = CGPoint.position(heartNode.frame,
                                              inside: self.frame,
                                              verticalAlign: .top,
                                              horizontalAnchor: .left,
                                              yOffset: Style.Padding.most*4)
        
        let currentHealthText = ParagraphNode(text: "\(data.hp)", paragraphWidth: 50.0, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        currentHealthText.position = CGPoint.alignVertically(currentHealthText.frame, relativeTo: heartNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most,  translatedToBounds: true)
        currentHealthText.name = Constants.currentHealthAmountLabelName

        let slashText = ParagraphNode(text: "/", paragraphWidth: 50.0, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        slashText.position = CGPoint.alignVertically(slashText.frame, relativeTo: currentHealthText.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        
        let totalHealthText = ParagraphNode(text: "\(data.originalHp)", paragraphWidth: Style.HUD.heartSize.width*2, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        totalHealthText.position = CGPoint.alignVertically(totalHealthText.frame, relativeTo: slashText.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        totalHealthText.name = Constants.totalHealthAmountLabelName

        
        self.addChildSafely(heartNode)
        addChild(currentHealthText)
        addChild(slashText)
        addChild(totalHealthText)
        
        // the sprite of the coin
        let gemNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.heartSize)
        gemNode.position = CGPoint.alignVertically(gemNode.frame, relativeTo: totalHealthText.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most * 2, translatedToBounds: true)
        gemSpriteNode = gemNode
        self.addChild(gemNode)
        
        // the label with the palyer's amount of gold
        let gemLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .lightText)
        gemLabel.position = CGPoint.alignVertically(gemLabel.frame, relativeTo: gemNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        gemLabel.name = Constants.gemAmountLabelName
        self.addChild(gemLabel)
        
        // save this data for later
        currentTotalGem = data.carry.total(in: .gem)
        
        
        // display the player's dodge
        let dodgeNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.dodgeSprite), size: Style.HUD.gemSize)
        dodgeNode.position = CGPoint.alignHorizontally(dodgeNode.frame, relativeTo: heartNode.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
        dodgeSprite = dodgeNode
        self.addChild(dodgeNode)
        
        let dodgeAmountNode = ParagraphNode(text: "\(data.dodge)", paragraphWidth: self.size.width)
        dodgeAmountNode.position = CGPoint.alignVertically(dodgeAmountNode.frame, relativeTo: dodgeNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds:  true)
        dodgeAmountNode.name = Constants.dodgeAmountLabelName
        self.addChild(dodgeAmountNode)
        
        // display the player's luck
        let luckNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.luckSprite), size: Style.HUD.gemSize)
        luckNode.position = CGPoint.alignHorizontally(luckNode.frame, relativeTo: gemNode.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: Style.Padding.most, translatedToBounds: true)
        luckSprite = luckNode
        self.addChild(luckNode)
        
        let luckAmountNode = ParagraphNode(text: "\(data.luck)", paragraphWidth: self.size.width)
        luckAmountNode.position = CGPoint.alignVertically(luckAmountNode.frame, relativeTo: luckNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.most, translatedToBounds: true)
        luckAmountNode.name = Constants.luckAmountLabelName
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
    
    func incrementStat(offer: StoreOfferType) {
        switch offer {
        case .dodge(amount: let amount):
            showIncreaseInStat(amountLabelName: Constants.dodgeAmountLabelName, amountIncrease: amount)
        case .luck(amount: let amount):
            showIncreaseInStat(amountLabelName: Constants.luckAmountLabelName, amountIncrease: amount)
        case .greaterHeal:
            showIncreaseInStat(amountLabelName: Constants.currentHealthAmountLabelName, amountIncrease: 2)
        case .lesserHeal:
            showIncreaseInStat(amountLabelName: Constants.currentHealthAmountLabelName, amountIncrease: 1)
        case .plusTwoMaxHealth:
            showIncreaseInStat(amountLabelName: Constants.totalHealthAmountLabelName, amountIncrease: 2)
        case .plusOneMaxHealth:
            showIncreaseInStat(amountLabelName: Constants.totalHealthAmountLabelName, amountIncrease: 1)
        case .gems(let amount):
            showTotalGemGain(amount)
        default:
            return
        }
    }
    
    private func showIncreaseInStat(amountLabelName: String, amountIncrease: Int) {
        if let currencyLabel = self.childNode(withName: amountLabelName) as? ParagraphNode {
            let oldPosition = currencyLabel.position

            // show exaclty how much gold was gained as well
            let gainedGoldLabel = ParagraphNode(text: "+\(amountIncrease)", paragraphWidth: Style.HUD.labelParagraphWidth, fontSize: .fontExtraLargeSize, fontColor: .goldOutlineBright)
            gainedGoldLabel.position = oldPosition.translateVertically(40.0)
            addChildSafely(gainedGoldLabel)
            let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: AnimationSettings.HUD.goldGainedTime)
            let moveAndFade = SKAction.group([moveUp, SKAction.fadeOut(withDuration: AnimationSettings.HUD.gemCountFadeTime)])
            let sequence = SKAction.sequence([moveAndFade, SKAction.removeFromParent()])
            gainedGoldLabel.run(sequence)
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
            let sequence = SKAction.sequence([moveAndFade, SKAction.removeFromParent()])
            gainedGoldLabel.run(sequence)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        for node in self.nodes(at: position) {
            if node.name == Identifiers.settings {
                delegate?.settingsTapped()
            } else if node.name == Constants.threatIndicator {
                print("threatIndicator touched")
            }
        }
    }
    
}

extension HUD: ButtonDelegate {
    func buttonTapped(_ button: ShiftShaft_Button) {
        switch button.identifier {
        case .shuffleBoard:
            InputQueue.append(Input(.shuffleBoard))
        default:
            ()
        }
    }
}
