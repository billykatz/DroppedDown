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
            case .collectItem(_, let item, let totalGold):
                if item.type == .gem {
                    showGem()
                } else if item.type == .gold {
                    incrementGoldCounter(totalGold)
                }
            default:
                ()
            }
        case .boardBuilt:
            //TODO: check this logic out thoroughly
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
        for child in self.children {
//            if child.name == Identifiers.heart ||
//                child.name == Identifiers.gold ||
//                child.name == Identifiers.gem ||
//                child.name == Identifiers.gemSpriteLabel {
            child.removeFromParent()
//            }
        }
        
        
        // create and display the full and empty hearts
        for health in 0..<data.originalHp {
            
            let identifier = health < data.hp ? Identifiers.fullHeart: Identifiers.emptyHeart
            let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier), size: Style.HUD.heartSize)
            heartNode.position = CGPoint.positionThis(heartNode.frame,
                                                      in: self.frame,
                                                      verticaliy: .top,
                                                      anchor: .left,
                                                      xOffset: CGFloat(health) * Style.HUD.heartSize.width)
            heartNode.name = Identifiers.heart
            self.addChild(heartNode)
        }
        
        let goldLabel = ParagraphNode(text: "\(data.carry.total(in: .gold))", paragraphWidth: 200.0, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        goldLabel.position = CGPoint.positionThis(goldLabel.frame, in: self.frame, verticaliy: .bottom, anchor: .left)
        goldLabel.name = Identifiers.goldSpriteLabel
        self.addChild(goldLabel)

        
        let coinNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gold), size: Style.HUD.heartSize)
        coinNode.position = CGPoint.positionThis(coinNode.frame,
                                                 relativeTo: goldLabel.frame,
                                                 verticaliy: .center,
                                                 anchor: .right)
        self.addChild(coinNode)
        
        let gemSpriteLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: 200.0, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        gemSpriteLabel.position = CGPoint.positionThis(gemSpriteLabel.frame,
                                                       relativeTo: coinNode.frame,
                                                       verticaliy: .center,
                                                       anchor: .right)
        gemSpriteLabel.name = Identifiers.gemSpriteLabel
        self.addChild(gemSpriteLabel)
        
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.gemSize)
        gemSprite.position = CGPoint.positionThis(gemSprite.frame, relativeTo: gemSpriteLabel.frame, verticaliy: .center, anchor: .right)
        self.addChild(gemSprite)
        
        
        
    }
    
    func showGem() {
        let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gem1"), size: CGSize(width: 100, height: 100))
        spriteNode.position = CGPoint(x: -300, y: 0)
        self.addChild(spriteNode)
    }
    
    func incrementGoldCounter(_ totalGold: Int) {
        if let goldLabel = self.childNode(withName: Identifiers.goldSpriteLabel) as? ParagraphNode {
            goldLabel.removeFromParent()
            
            let newGoldLabel = ParagraphNode(text: "\(totalGold)", paragraphWidth: 200.0, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
            newGoldLabel.position = CGPoint.positionThis(goldLabel.frame, in: self.frame, verticaliy: .bottom, anchor: .left)
            newGoldLabel.name = Identifiers.goldSpriteLabel
            self.addChild(newGoldLabel)
        }
    }
}

