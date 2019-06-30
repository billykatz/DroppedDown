//
//  HelperTextView.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class HelperTextView: SKSpriteNode {
    static func build(color: UIColor, size: CGSize) -> HelperTextView {
        let header = HelperTextView(texture: nil, color: color, size: size)
        Dispatch.shared.register { input in
            header.show(input)
        }
        return header
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ input: Input) {
        var showGem = false
        var showExit = false
        var descriptionText = ""
        switch input.type {
        case .gameLose(let text):
            descriptionText = text
        case .gameWin:
            descriptionText = "You won, you are a masterful miner!"
        case .transformation(let trans):
            guard let inputType = trans.inputType else { return }
            switch inputType {
            case .attack(let attackerPosition, let defenderPosition):
                if let tiles = trans.endTiles {
                    let attacker = tiles[attackerPosition]
                    let defender = tiles[defenderPosition]
                    
                    if case let TileType.monster(monsterData) = attacker,
                        case TileType.player = defender{
                        // monster attacked player
                        
                        descriptionText = "You've been attacked by a monster for \(monsterData.attack.damage) damage.\n If you fall to 0 hp you lose"
                    } else if case TileType.monster = defender,
                        case TileType.player = attacker {
                        // we attacked the monster
                        descriptionText = "You slayed a monster, you're a worthy champion indeed!"
                    }
                } else {
                    descriptionText = ""
                }
            case .touch(_, let type):
                switch type {
                case .blueRock, .blackRock, .greenRock:
                    descriptionText = "Nice, keep destroying those rocks!"
                default:
                    descriptionText = ""
                }
            default:
                descriptionText = ""
            }
            
        case .touch(_, let type):
            switch type {
            case .blackRock, .blueRock, .greenRock:
                descriptionText = "Remove rocks by tapping on groups of 3 or more."
            case .exit:
                descriptionText = "That's the mine shaft,\n but you cant exit until you find the gem!"
                showGem = true
            case .player:
                descriptionText = "That's you! Stay alive and find the exit"
            case .monster(let data):
                descriptionText = "That's a monster! It has \(data.hp) hp and attacks sideways  "
            case .empty:
                descriptionText = "How in the hell did you tap on an empty tile?"
            case .item(let item):
                descriptionText = "That's \(item.textureName), cool!"
            }
        case .boardBuilt:
            descriptionText = "Hello there Adventurer\nYou'll need to navigate these mines \nand find the magical gem before \ncontinuing down the mine shaft"
            showExit = true
        default:
            descriptionText = ""
        }

        if descriptionText.count == 0 { return }
        self.removeAllChildren()
        
        
        
        let descLabel = SKLabelNode(text: descriptionText)
        descLabel.fontSize = 30
        descLabel.zPosition = 11
        descLabel.fontColor = .black
        descLabel.fontName = "Helvetica-Bold"
        descLabel.position = CGPoint(x: 0, y: -45)
        descLabel.numberOfLines = 0
        self.addChild(descLabel)
        
        if showGem {
            let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gem1"), size: CGSize(width: 100, height: 100))
            spriteNode.position = CGPoint(x: 300, y: 25)
            self.addChild(spriteNode)
        }
        
        if showExit {
            let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "exit"), size: CGSize(width: 100, height: 100))
            spriteNode.position = CGPoint(x: 325, y: 25)
            self.addChild(spriteNode)
        }

        
    }


}
