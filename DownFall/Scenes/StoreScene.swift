//
//  StoreScene.swift
//  DownFall
//
//  Created by William Katz on 7/31/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

let closeButton = "closeButton"
let buyButton = "buyButton"
let sellButton = "sellButton"
let wallet = "wllet"

protocol StoreSceneDelegate: class {
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel)
}

class StoreScene: SKScene {
    let background: SKSpriteNode
    var playerData: EntityModel
    var items: [StoreItem] = []
    var selectedItem: StoreItem? {
        didSet {
            guard oldValue != selectedItem else { return }
            toggleUI()
        }
    }
    
    func toggleUI() {
        toggleSelect()
        togglePopup()
        toggleTransactionButton()
    }
    weak var storeSceneDelegate: StoreSceneDelegate?
    
    init(size: CGSize, playerData: EntityModel) {
        //playable rect
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        background = SKSpriteNode(color: .clayRed,
                                  size: CGSize(width: playableWidth,
                                               height: size.height))
        
        self.playerData = playerData
        super.init(size: size)
        
        
        
        let button = Button(size: CGSize(width: 150, height: 50),
                            delegate: self,
                            identifier: .leaveStore,
                            precedence: .foreground,
                            fontSize:  25)
        button.position = CGPoint(x: 0, y: -300)

        let doubleAttackItem = StoreItem(ability: DoubleAttack(),
                                         size: CGSize(width: 50, height: 50),
                                         delegate: self,
                                         identifier: .storeItem,
                                         precedence: .foreground,
                                         fontSize: 25)
        
        let shieldEastItem = StoreItem(ability: ShieldEast(),
                                   size: CGSize(width: 50, height: 50),
                                   delegate: self,
                                   identifier: .storeItem,
                                   precedence: .foreground,
                                   fontSize: 25)
        doubleAttackItem.position = CGPoint(x: 45, y: 0)
        shieldEastItem.position = CGPoint(x: -45, y: 0)
        items.append(doubleAttackItem)
        items.append(shieldEastItem)
        background.addChild(doubleAttackItem)
        background.addChild(shieldEastItem)
        background.addChild(button)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        addChild(walletView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var walletView: SKSpriteNode {
        let walletView = SKSpriteNode(color: .storeBlack, size: CGSize(width: 150, height: 50))
        walletView.position = CGPoint(x: frame.minX + walletView.size.width/2, y: -200)
        
        let coin = SKSpriteNode(texture: SKTexture(imageNamed: "gold"), size: CGSize(width: 35, height: 35))
        coin.position = CGPoint(x: walletView.size.width/2 - coin.size.width/2, y: 0)
        
        let coinLabel = Label(text: "\(playerData.carry.totalGold)",
                              precedence: .foreground,
                              font: UIFont.storeItemDescription,
                              fontColor: .storeDarkGray,
                              maxWidth: walletView.frame.width)
        coinLabel.horizontalAlignmentMode = .center
        coinLabel.verticalAlignmentMode = .center
        
        
        walletView.addChild(coin)
        walletView.addChild(coinLabel)
        walletView.name = wallet
        return walletView
    }
    
    var transactionButton: Button {
        let purchased = selectedItem?.isPurchased ?? false
        let purchaseButton = Button(size: CGSize(width: 200, height: 50),
                                    delegate: self,
                                    textureName: purchased ? sellButton : buyButton,
                                    precedence: .foreground)
        purchaseButton.position = CGPoint(x: frame.maxX, y: -200)
        return purchaseButton
    }
    
    
    private func informationPopup(with text: String) -> SKSpriteNode {
        let popupNode = SKSpriteNode(color: .storeItemBackground,
                                     size: CGSize(width: self.frame.width - 100, height: 200))
        popupNode.position = CGPoint(x: frame.midX, y: frame.maxY - 200)
        let descriptionLabel = Label(text: text,
                                     precedence: .foreground,
                                     font: UIFont.storeItemDescription,
                                     fontColor: .storeDarkGray,
                                     maxWidth: popupNode.frame.width - 8)
        descriptionLabel.horizontalAlignmentMode = .center
        descriptionLabel.verticalAlignmentMode = .center
        popupNode.addChild(descriptionLabel)
        
        let closeBtn = Button(size: CGSize(width: 35, height: 35),
                                 delegate: self,
                                 textureName: closeButton,
                                 precedence: .menu)
        closeBtn.position = CGPoint(x: popupNode.frame.width/2 - closeBtn.frame.width/2, y: popupNode.frame.height/2 - closeBtn.frame.height/2)
        popupNode.addChild(closeBtn)
        popupNode.name = "popup"
        return popupNode
    }
    
    private func show(_ node: SKSpriteNode) {
        children.forEach {
            if $0.name == node.name {
                $0.removeFromParent()
            }
        }
        addChild(node)
    }
    
    private func toggleSelect() {
        func deselect() {
            //deselect store item
            for item in items {
                item.deselect()
            }
        }
        func select() {
            //deselect store item
            for item in items {
                if item == selectedItem {
                    item.select()
                }
            }
        }
        
        deselect()
        select()
        
    }
    
    private func togglePopup() {
        func hidePopup() {
            for child in self.children {
                if child.name == "popup" {
                    child.removeAllChildren()
                    child.removeFromParent()
                }
            }
        }
        
        func showPopup() {
            guard let description = selectedItem?.ability.description else { return }
            let infoPopup = informationPopup(with: description)
            show(infoPopup)
        }
        
        hidePopup()
        showPopup()
    }
    

    
    private func hidePopup() {
        for child in self.children {
            if child.name == "popup" {
                child.removeAllChildren()
                child.removeFromParent()
            } else if child.name == buyButton {
                let slideOut = SKAction.moveTo(x: frame.maxX + child.frame.width/2,
                                              duration: TimeInterval(exactly: 0.3)!)
                child.run(slideOut) {
                    child.removeFromParent()
                }

            }
        }
    }
    
    private func hideButton(with name: String) {
        for child in self.children {
            if child.name == name {
                let slideOut = SKAction.moveTo(x: frame.maxX + child.frame.width/2,
                                               duration: TimeInterval(exactly: 0.3)!)
                child.run(slideOut) {
                    child.removeFromParent()
                }
                
            }
        }

    }
    
    func reloadWalletView() {
        let newWalletView = walletView
        
        for child in children {
            if child.name == wallet {
                removeFromParent()
            }
        }
        
        show(newWalletView)
    }
    
    //TODO add actualy transaction with player money!
    private func buy(_ storeItem: StoreItem) {
        let ability = storeItem.ability
        if playerData.canAfford(ability.cost) {
            playerData = playerData.add(ability)
            playerData = playerData.buy(ability)
            storeItem.purchase()
            reloadWalletView()
        }
    }
    
    private func sell(_ ability: Ability) {
        playerData = playerData.remove(ability)
        playerData = playerData.sell(ability)
        reloadWalletView()
    }
    
    private func toggleTransactionButton() {
        hideButton(with: buyButton)
        hideButton(with: sellButton)
        if let selectedItem = selectedItem {
            showButton(selectedItem.isPurchased ? sellButton : buyButton)
        }
    }
    
    private func showButton(_ buttonName: String) {
        let button = transactionButton
        let slideIn = SKAction.moveTo(x: frame.maxX - transactionButton.size.width/2,
                                      duration: TimeInterval(exactly: 0.5)!)
        show(button)
        button.run(slideIn)
    }
}

extension StoreScene: StoreItemDelegate {
    func storeItemTapped(_ storeItem: StoreItem, ability: Ability) {
        selectedItem = storeItem
    }
    
    func wasPurchased(_ storeItem: StoreItem) {
        toggleUI()
    }
}

extension StoreScene : ButtonDelegate {
    func buttonPressed(_ button: Button) {
        if button.name == "leaveStore" {
            storeSceneDelegate?.leave(self, updatedPlayerData: playerData)
        } else if button.name == buyButton, let storeItem = selectedItem {
            buy(storeItem)
        } else if button.name == closeButton {
            selectedItem = nil
        } else if button.name == sellButton {
            guard let selectedItem = selectedItem else { return }
            self.selectedItem = selectedItem
            sell(selectedItem.ability)
            selectedItem.sell()
        }

    }
}
