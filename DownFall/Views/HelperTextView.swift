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
        var descriptionText = ""
        switch input.type {
        case .gameLose(let text):
            descriptionText = text
        case .gameWin:
            descriptionText = "You won, you are a masterful miner!\n Make sure to leave feedback :)"
        case .transformation(let trans):
            guard let inputType = trans.inputType else { return }
            switch inputType {
            case .attack(_, let attackerPosition, let defenderPosition, _):
                if let tiles = trans.endTiles {
                    if let defenderPosition = defenderPosition {
                        let attacker = tiles[attackerPosition]
                        let defender = tiles[defenderPosition]
                        
                        if case let TileType.monster(monsterData) = attacker.type,
                            case TileType.player = defender.type {
                            // monster attacked player
                            
                            descriptionText = "You've been attacked by a\n monster for \(monsterData.attack.damage) damage."
                        } else if case TileType.monster = defender.type,
                            case TileType.player = attacker.type {
                            // we attacked the monster
                            descriptionText = "You slayed a monster,\n you're a worthy champion indeed!"
                        }
                    }
                }
            default:
                descriptionText = ""
            }
        case .touch(_, let type):
            switch type {
            case .blackRock, .blueRock, .greenRock:
                descriptionText = "Remove rocks by tapping on groups\n of 3 or more anywhere on the board."
            case .exit:
                descriptionText = "That's the mine shaft,\n but you cant exit until you find the gem!"
                showGem = true
            case .player:
                descriptionText = "That's you! Stay alive and find the exit"
            case .monster(let data):
                descriptionText = "\(data)"
            case .empty:
                descriptionText = "How in the hell did you tap on an empty tile?"
            case .item(let item):
                descriptionText = "That's \(item.textureName), cool!"
            case .fireball:
                descriptionText = ""
            }
        case .boardBuilt, .pause:
            ()
        case .rotateLeft, .rotateRight:
            descriptionText = "Try swiping up or down on the\n right side of the screen!!"
        default:
            descriptionText = ""
        }

        if descriptionText.count == 0 { return }
        self.removeAllChildren()
        
        
        
        let descLabel = SKLabelNode(text: descriptionText)
        descLabel.fontSize = 45
        descLabel.zPosition = 11
        descLabel.fontColor = .lightText
        descLabel.fontName = "Helvetica"
        descLabel.position = CGPoint(x: 0, y: -45)
        descLabel.numberOfLines = 0
        
        self.addChild(descLabel)
        
        if showGem {
            let spriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gem1"), size: CGSize(width: 100, height: 100))
            spriteNode.position = CGPoint(x: 300, y: 20)
            self.addChild(spriteNode)
        }
    }
}
