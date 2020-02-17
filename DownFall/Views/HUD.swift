//
//  HUD.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class HUD: SKSpriteNode {
    static func build(color: UIColor, size: CGSize, delegate: SettingsDelegate?) -> HUD {
        let header = HUD(texture: nil, color: color, size: size)
        
        let setting = SKSpriteNode(imageNamed: Identifiers.settings)
        setting.name = Identifiers.settings
        setting.position = CGPoint.position(setting.frame,
                                            centeredOnTheRightOf: header.frame,
                                            horizontalOffset: Style.Padding.more)
        setting.zPosition = Precedence.foreground.rawValue
        
        header.addChild(setting)
        
        header.isUserInteractionEnabled = true
        header.delegate = delegate
        
        Dispatch.shared.register {
            header.handle($0)
        }
        
        return header
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentTotalGold: Int = 0
    let animator = Animator()
    
    var delegate: SettingsDelegate?
    
    //Mark: - Instance Methods
    
    private func showAttack(attackInput: Input, endTiles: [[Tile]]?) {
        if case InputType.attack(_,
                                 _,
                                 let defenderPosition,
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
            guard let inputType = trans.inputType else { return }
            switch inputType {
            case .attack:
                showAttack(attackInput: input, endTiles: trans.endTiles)
            case .collectItem(_, let item, let total):
                incrementCurrencyCounter(item, total: total)
            case .itemUsed:
                if let tiles = trans.endTiles,
                    let playerCoord = getTilePosition(.player(.zero), tiles: tiles),
                    case TileType.player(let data) = tiles[playerCoord].type {
                    show(data)
                }
            default:
                ()
            }
        case .boardBuilt:
            //TODO: check this logic out thoroughly.
            // Update 12/28: not sure why I wrote this/
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
        for child in children {
            if child.name != Identifiers.settings {
                child.removeFromParent()
            }
        }
        
        // create and display the full and empty hearts
        for health in 0..<data.originalHp {
            
            let identifier = health < data.hp ? Identifiers.fullHeart: Identifiers.emptyHeart
            let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: Style.HUD.heartSize)
            heartNode.position = CGPoint.position(heartNode.frame, inside: frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: CGFloat(health) * Style.HUD.heartSize.width)
            heartNode.name = Identifiers.heart
            self.addChild(heartNode)
        }
        
        // the label with the palyer's amount of gold
        let goldLabel = ParagraphNode(text: "\(data.carry.total(in: .gold))", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        goldLabel.position = CGPoint.position(goldLabel.frame, inside: frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: Style.HUD.coinLabelPadding)
        goldLabel.name = Identifiers.goldSpriteLabel
        self.addChild(goldLabel)
        
        // save this data for later
        currentTotalGold = data.carry.total(in: .gold)
        
        // the sprite of the coin
        let coinNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gold), size: Style.HUD.heartSize)
        coinNode.position = CGPoint.alignVertically(coinNode.frame, relativeTo: goldLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        self.addChild(coinNode)
        
        // the label with the player's amount of gems
        let gemSpriteLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        gemSpriteLabel.position = CGPoint.alignVertically(gemSpriteLabel.frame, relativeTo: coinNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding:  Style.HUD.coinLabelPadding, translatedToBounds: true)
        gemSpriteLabel.name = Identifiers.gemSpriteLabel
        self.addChild(gemSpriteLabel)
        
        // The sprite of the gem
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.gemSize)
        gemSprite.position = CGPoint.alignVertically(gemSprite.frame, relativeTo: gemSpriteLabel.frame, horizontalAnchor: .right, verticalAlign: .center, translatedToBounds: true)
        self.addChild(gemSprite)
        
        
        
    }
    
    func incrementCurrencyCounter(_ item: Item, total: Int) {
        let currencyLabelIdentifier = item.type == .gold ? Identifiers.goldSpriteLabel : Identifiers.gemSpriteLabel
        
        if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode {
            let oldPosition = currencyLabel.position
            currencyLabel.removeFromParent()
            
            var animations: [(SKSpriteNode, SKAction)] = []
            let goldGained = total-currentTotalGold
            for gain in 1..<goldGained+1 {
                let newCurrencyLabel = ParagraphNode(text: "\(currentTotalGold + gain)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
                newCurrencyLabel.position = oldPosition
                newCurrencyLabel.name = currencyLabelIdentifier
                newCurrencyLabel.isHidden = true
                addChildSafely(newCurrencyLabel)
                // construct the ticker animation
                
                var actions: [SKAction] = []
                // wait before adding it
                let waitTime = AnimationSettings.Board.goldWaitTime
                actions.append(SKAction.wait(forDuration: Double(gain) * waitTime))
                // actually add it
                actions.append(SKAction.unhide())
                if gain < goldGained {
                    // wait before removing it
                    actions.append(SKAction.wait(forDuration: waitTime))
                    //remove all but the last one
                    actions.append(SKAction.removeFromParent())
                }
                
                animations.append((newCurrencyLabel, SKAction.sequence(actions)))
            }
            
            // show exaclty how much gold was gained as well
            let gainedGoldLabel = ParagraphNode(text: "+\(goldGained)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .highlightGold)
            gainedGoldLabel.position = oldPosition.translateVertically(40.0)
            addChildSafely(gainedGoldLabel)
            let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: AnimationSettings.HUD.goldGainedTime)
            let sequence = SKAction.sequence([moveUp, SKAction.removeFromParent()])
            gainedGoldLabel.run(sequence)
                
            
            animator.animate(animations)
            currentTotalGold = total
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
