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
        let header = HUD(texture: nil, color: .clear, size: size)
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
            default:
                ()
            }
        case .collectItem(_, let item):
            if item.type == .gem {
                showGem()
            } else {
                incrementGoldCounter()
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
        for child in self.children {
            if child.name == "heart" {
                child.removeFromParent()
            }
        }
        
        for health in 0..<data.hp {
            let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: "heart"), size: CGSize(width: 100, height: 100))
            heartNode.position = CGPoint(x: -150 + (health * 100), y:0)
            heartNode.name = "heart"
            self.addChild(heartNode)
        }
        
        let coinNode = SKSpriteNode(texture: SKTexture(imageNamed: "gold"), size: CGSize(width: 100, height: 100))
        coinNode.position = CGPoint(x: 250, y: 0)
        self.addChild(coinNode)
        
        if let _ = self.childNode(withName: "goldLabel") {
            
        }
        else {
            let goldLabel = SKLabelNode(fontNamed: "Helvetica")
            goldLabel.fontSize = 75
            goldLabel.position = CGPoint(x: 355, y: -22)
            goldLabel.text = "0"
            goldLabel.fontColor = .lightText
            goldLabel.name = "goldLabel"
            self.addChild(goldLabel)
        }
    }
    
    func showGem() {
        let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gem1"), size: CGSize(width: 100, height: 100))
        spriteNode.position = CGPoint(x: -300, y: 0)
        self.addChild(spriteNode)
    }
    
    func incrementGoldCounter() {
        if let goldLabel = self.childNode(withName: "goldLabel") as? SKLabelNode,
            let text = goldLabel.text,
            let gold = Int(text) {
            goldLabel.text = ""
            goldLabel.text = "\(gold + 1)"
            
        }
    }
}

