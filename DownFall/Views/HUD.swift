//
//  HUD.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class HUD: SKSpriteNode {
    static func build(color: UIColor, size: CGSize) -> HUD {
        let header = HUD(texture: nil, color: color, size: size)
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
                if let tiles = trans.endTiles, let playerCoord = getTilePosition(.player(.zero), tiles: tiles), case TileType.player(let data) = tiles[playerCoord].type {
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
        removeAllChildren()
        
        // create and display the full and empty hearts
        for health in 0..<data.originalHp {
            
            let identifier = health < data.hp ? Identifiers.fullHeart: Identifiers.emptyHeart
            let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: Style.HUD.heartSize)
            heartNode.position = CGPoint.positionThis(heartNode.frame,
                                                      in: self.frame,
                                                      verticality: .top,
                                                      anchor: .left,
                                                      xOffset: CGFloat(health) * Style.HUD.heartSize.width)
            heartNode.name = Identifiers.heart
            self.addChild(heartNode)
        }
        
        // the label with the palyer's amount of gold
        let goldLabel = ParagraphNode(text: "\(data.carry.total(in: .gold))", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        goldLabel.position = CGPoint.positionThis(goldLabel.frame, in: self.frame, verticality: .bottom, anchor: .left, xOffset: Style.HUD.coinLabelPadding)
        goldLabel.name = Identifiers.goldSpriteLabel
        self.addChild(goldLabel)

        
        // the sprite of the coin
        let coinNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gold), size: Style.HUD.heartSize)
        coinNode.position = CGPoint.positionThis(coinNode.frame,
                                                 relativeTo: goldLabel.frame,
                                                 verticaliy: .center,
                                                 anchor: .right)
        self.addChild(coinNode)
        
        // the label with the player's amount of gems
        let gemSpriteLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        gemSpriteLabel.position = CGPoint.positionThis(gemSpriteLabel.frame,
                                                       relativeTo: coinNode.frame,
                                                       verticaliy: .center,
                                                       anchor: .right,
                                                       xOffset: Style.HUD.coinLabelPadding)
        gemSpriteLabel.name = Identifiers.gemSpriteLabel
        self.addChild(gemSpriteLabel)
        
        // The sprite of the gem
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.gemSize)
        gemSprite.position = CGPoint.positionThis(gemSprite.frame, relativeTo: gemSpriteLabel.frame, verticaliy: .center, anchor: .right, xOffset: Style.HUD.gemSpritePadding)
        self.addChild(gemSprite)
        
        
        
    }
    
    func incrementCurrencyCounter(_ item: Item, total: Int) {
        let currencyLabelIdentifier = item.type == .gold ? Identifiers.goldSpriteLabel : Identifiers.gemSpriteLabel
        
        if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode {
            let oldPosition = currencyLabel.position
            currencyLabel.removeFromParent()
            
            let newCurrencyLabel = ParagraphNode(text: "\(total)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
            newCurrencyLabel.position = oldPosition
            newCurrencyLabel.name = currencyLabelIdentifier
            self.addChild(newCurrencyLabel)
        }
    }
}

