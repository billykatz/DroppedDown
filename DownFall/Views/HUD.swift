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
    
    private func showAttack(_ attackerPosition: TileCoord,
                               _ defenderPosition: TileCoord,
                               _ endTiles: [[TileType]]?) {
        guard let tiles = endTiles else { return }
        let attacker = tiles[attackerPosition]
        let defender = tiles[defenderPosition]
        
        if case TileType.greenMonster(_) = attacker,
            case let TileType.player(playerData) = defender{
            // monster attacked player
            show(playerData)
        }
    }
    
    func handle(_ input: Input) {
        switch input.type {
        case .transformation(let trans):
            guard let inputType = trans.inputType else { return }
            switch inputType {
            case .attack(let attacker, let defender):
                showAttack(attacker, defender, trans.endTiles)
            default:
                ()
            }
        case .collectGem:
            showGem()
        case .boardBuilt:
            guard let tiles = input.endTiles,
                let playerPosition = getTilePosition(.player(), tiles: tiles),
                case let TileType.player(data) = tiles[playerPosition] else { return }
            show(data)
        default:
            ()
        }
    }

    func show(_ data: CombatTileData) {
        for child in self.children {
            if child is SKLabelNode {
                child.removeFromParent()
            }
        }
        
        let playerHealthString =
        """
        Health: \(data.hp)
        """
        let weaponDamageString =
        """
        Pickaxe Damage: \(data.weapon.damage)
        """
        let weaponDirectionString = "Pickaxe Attacks: Down"
        
        let titleLabel = SKLabelNode(text: "Player 1")
        titleLabel.fontSize = 40
        titleLabel.zPosition = 11
        titleLabel.fontColor = .black
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.position = CGPoint(x: 0, y: 38)
        
        
        let label = SKLabelNode(text: playerHealthString)
        label.fontSize = 30
        label.zPosition = 11
        label.fontColor = .black
        label.fontName = "Helvetica-Bold"
        label.numberOfLines = 2
        label.position = CGPoint(x: 0, y: 0)
        
        let label1 = SKLabelNode(text: weaponDamageString)
        label1.fontSize = 30
        label1.zPosition = 11
        label1.fontColor = .black
        label1.fontName = "Helvetica-Bold"
        label1.numberOfLines = 2
        label1.position = CGPoint(x: 0, y: -30)

        
        let label2 = SKLabelNode(text: weaponDirectionString)
        label2.fontSize = 30
        label2.zPosition = 11
        label2.fontColor = .black
        label2.fontName = "Helvetica-Bold"
        label2.numberOfLines = 2
        label2.position = CGPoint(x: 0, y: -60)

        
        self.addChild(titleLabel)
        self.addChild(label)
        self.addChild(label1)
        self.addChild(label2)
    }
    
    func showGem() {
        let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gem1"), size: CGSize(width: 100, height: 100))
        spriteNode.position = CGPoint(x: -300, y: 0)
        self.addChild(spriteNode)
    }
}

