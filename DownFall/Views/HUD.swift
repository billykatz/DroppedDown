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
    }
    
    static func build(color: UIColor, size: CGSize, delegate: SettingsDelegate?, level: Level) -> HUD {
        let header = HUD(texture: nil, color: .clear, size: size)
        
        let setting = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.settings), color: .clear , size: Style.HUD.lanternSize)
        
        setting.name = Identifiers.settings
        setting.position = CGPoint.position(setting.frame,
                                            inside: header.frame,
                                            verticalAlign: .top,
                                            horizontalAnchor: .right)
        setting.zPosition = Precedence.foreground.rawValue
        
        header.addChild(setting)
        
        header.isUserInteractionEnabled = true
        header.delegate = delegate
        
        header.level = level
        
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
    
    var currentTotalGem: Int = 0
    let animator = Animator()
    
    var delegate: SettingsDelegate?
    var level: Level?
    
    private var threatIndicator: SKSpriteNode? {
        return nil
    }
    
    //Mark: - Instance Methods
    
    private func showAttack(attackInput: Input, endTiles: [[Tile]]?) {
        if case InputType.attack(_,
                                 _,
                                 let defenderPosition,
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
            case .collectItem(_, let item, let total):
                incrementCurrencyCounter(item, total: total)
            case .itemUsed, .decrementDynamites, .shuffleBoard:
                if let tiles = trans.first?.endTiles,
                    let playerCoord = getTilePosition(.player(.zero), tiles: tiles),
                    case TileType.player(let data) = tiles[playerCoord].type {
                    show(data)
                }
            default:
                ()
            }
        case .boardBuilt:
            guard let tiles = input.endTilesStruct,
                let playerPosition = getTilePosition(.player(.zero), tiles: tiles),
                case let TileType.player(data) = tiles[playerPosition].type else { return }
            show(data)
            updateThreatIndicator()
        case .newTurn:
            updateThreatIndicator()
        default:
            ()
        }
    }
    
    func updateThreatIndicator() {
        for child in children {
            if child.name == Constants.threatIndicator {
                child.removeFromParent()
            }
        }
        
        addChildSafely(threatIndicator)
    }
    
    func show(_ data: EntityModel) {
        // Remove all the hearts so that we can redraw
        self.removeAllChildren(exclude: [Identifiers.settings, Constants.threatIndicator, Constants.shuffleBoardButton, Constants.levelGoalIndicator])
        
        
        let identifier = Identifiers.fullHeart
        let heartNode = SKSpriteNode(texture: SKTexture(imageNamed: identifier),
                                     size: Style.HUD.heartSize)
        heartNode.position = CGPoint.position(heartNode.frame,
                                              inside: self.frame,
                                              verticalAlign: .bottom,
                                              horizontalAnchor: .left)
        
        let viewModel = FillableBarViewModel(total: data.originalHp,
                                             progress: data.hp,
                                             fillColor: .red,
                                             backgroundColor: .clayRed,
                                             text: "",
                                             horiztonal: true)
        let healthBar = FillableBar(size: CGSize(width: self.size.width * Style.HUD.healthBarWidthRatio, height: Style.HUD.healthBarHeight), viewModel: viewModel)
        healthBar.position = CGPoint.position(healthBar.frame, inside: frame, verticalAlign: .bottom, horizontalAnchor: .left, xOffset: heartNode.frame.width + Style.Padding.normal, yOffset: heartNode.frame.height/2 - Style.HUD.healthBarHeight/2)
        
        let healthText = ParagraphNode(text: "\(data.hp)/\(data.originalHp)", paragraphWidth: Style.HUD.heartSize.width*2, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        healthText.position = CGPoint.position(healthText.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .right, yOffset: heartNode.frame.height/2 - healthText.frame.height/2 + Style.Padding.normal)
        
        self.addChildSafely(heartNode)
        self.addChildSafely(healthBar)
        self.addChildSafely(healthText)
        
        // the sprite of the coin
        let gemNode = SKSpriteNode(texture: SKTexture(imageNamed: Identifiers.gem), size: Style.HUD.heartSize)
        gemNode.position = CGPoint.alignHorizontally(gemNode.frame, relativeTo: heartNode.frame, horizontalAnchor: .center, verticalAlign: .top, translatedToBounds: true)
        self.addChild(gemNode)
        
        // the label with the palyer's amount of gold
        let gemLabel = ParagraphNode(text: "\(data.carry.total(in: .gem))", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
        gemLabel.position = CGPoint.alignVertically(gemLabel.frame, relativeTo: gemNode.frame, horizontalAnchor: .right, verticalAlign: .center, horizontalPadding: Style.Padding.more, translatedToBounds: true)
        gemLabel.name = Identifiers.gemSpriteLabel
        self.addChild(gemLabel)
        
        // save this data for later        currentTotalGem = data.carry.total(in: .gem)
    }
    
    func incrementCurrencyCounter(_ item: Item, total: Int) {
        let currencyLabelIdentifier = item.type == .gold ? Identifiers.goldSpriteLabel : Identifiers.gemSpriteLabel
        
        let localCurrenTotal = currentTotalGem
        
        if let currencyLabel = self.childNode(withName: currencyLabelIdentifier) as? ParagraphNode {
            let oldPosition = currencyLabel.position
            currencyLabel.removeFromParent()
            
            var animations: [(SKSpriteNode, SKAction)] = []
            let goldGained = total-localCurrenTotal
            for gain in 1..<goldGained+1 {
                let newCurrencyLabel = ParagraphNode(text: "\(localCurrenTotal + gain)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
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
            
            
            // animate everything we just created
            animator.animate(animations)
            
            // update our current total
            currentTotalGem = total
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
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .shuffleBoard:
            InputQueue.append(Input(.shuffleBoard))
        default:
            ()
        }
    }
}
