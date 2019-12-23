//
//  StoreScene.swift
//  DownFall
//
//  Created by William Katz on 7/31/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit


protocol StoreSceneDelegate: class {
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel)
}

protocol StoreSceneInventory {
    var items: [Ability] { get }
}

class StoreScene: SKScene {
    
    struct Constants {
        static let closeButton = "closeButton"
        static let buyButton = "buyButton"
        static let sellButton = "sellButton"
        static let goldWallet = "goldWallet"
        static let gemWallet = "gemWallet"
        static let popup  = "popup"
    }
    
    private let background: SKSpriteNode
    private var playerData: EntityModel
    private var items: [StoreItem] = []
    private let level: Level
    var selectedItem: StoreItem? {
        didSet {
            guard oldValue != selectedItem else { return }
            toggleUI()
        }
    }
    
    weak var storeSceneDelegate: StoreSceneDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    init(size: CGSize,
         playerData: EntityModel,
         inventory: StoreSceneInventory,
         level: Level) {
        //playable rect
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        
        background = SKSpriteNode(color: .clayRed,
                                  size: CGSize(width: playableWidth,
                                               height: size.height))
        
        self.playerData = playerData
        self.level = level
        super.init(size: size)
        self.backgroundColor = .clayRed
        
        
        
        let button = Button(size: Button.large,
                            delegate: self,
                            identifier: .leaveStore,
                            precedence: .foreground,
                            fontSize:  UIFont.mediumSize,
                            fontColor: .black)
        
        button.position = CGPoint.positionThis(button.frame, inBottomOf: self.frame, padding: Style.buttonToBottomPadding)
        
        
        items = createStoreItems(from: level)
        positionStore(items, playableWidth)
        items.forEach {
            addChild($0)
        }
        
        
        background.addChild(button)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
        let goldWallet = walletView(.gold, order: 0)
        let gemWallet = walletView(.gem, order: 1)
        addChild(goldWallet)
        addChild(gemWallet)
    }
    
    private func createStoreItems(from level: Level) -> [StoreItem] {
        var items: [StoreItem] = []
        for item in level.abilities {
            items.append(StoreItem(ability: item,
                                   size: Style.Store.Item.size,
                                   delegate: self,
                                   identifier: .storeItem,
                                   precedence: .foreground,
                                   fontSize: UIFont.smallSize))
        }
        return items
    }
    
    private func positionStore(_ items: [StoreItem],_ playableWidth: CGFloat) {
        let gridPoints = CGPoint.gridPositions(
            rows: 3,
            columns: 3,
            itemSize: Style.Store.Item.size,
            width: playableWidth,
            height: Style.Store.ItemGrid.height,
            bottomLeft: CGPoint(x: -frame.width/2, y: 0)
        )
        for (index, position) in gridPoints.enumerated() {
            if items.count - 1 >= index {
                items[index].position = position
            }
            
        }
    }
    
    func walletView(_ currency: Currency, order: CGFloat) -> SKSpriteNode {
        let walletView = SKSpriteNode(color: .storeBlack, size: Style.Store.Wallet.viewSize)
        walletView.position = CGPoint.positionThis(walletView.frame,
                                                   inBottomOf: frame,
                                                   padding: (2 + order) * walletView.frame.height,
                                                   anchor: .left)
        
        let currencySprite = SKSpriteNode(texture: SKTexture(imageNamed: currency.rawValue), size: Style.Store.Wallet.currencySize)
        currencySprite.position = CGPoint.positionThis(currencySprite.frame, toTheRightOf: walletView.frame)
        
        let amountLabel = Label(text:
            """
            \(playerData.carry.total(in: currency))
            """,
                                width: self.frame.width,
                                delegate: nil, precedence: .foreground,
                                identifier: .wallet,
                                fontSize: UIFont.largeSize,
                                fontColor: .white)
        
        walletView.addChild(currencySprite)
        walletView.addChild(amountLabel)
        walletView.name = currencyWalletName(currency)
        return walletView

    }
    
    private var transactionButton: Button {
        let purchased = selectedItem?.isPurchased ?? false
        let purchaseButton = Button(size: CGSize(width: 200, height: 50),
                                    delegate: self,
                                    textureName: purchased ? Constants.sellButton : Constants.buyButton,
                                    precedence: .foreground)
        purchaseButton.position = CGPoint(x: frame.maxX, y: -200)
        return purchaseButton
    }
    
    private func toggleUI() {
        toggleSelect()
        togglePopup()
        toggleTransactionButton()
    }
    
    
    private func informationPopup(with text: String) -> SKSpriteNode {
        let popupNode = SKSpriteNode(color: .storeItemBackground,
                                     size: CGSize(width: self.frame.width - Style.Store.InfoPopup.sidePadding, height: Style.Store.InfoPopup.height))
        popupNode.position = CGPoint(x: frame.midX,
                                     y: frame.maxY - (popupNode.frame.height / 2) - Style.Store.InfoPopup.topPadding)
        
        let descriptionLabel = Label(text: text,
                                     width: popupNode.frame.width,
                                     delegate: nil,
                                     precedence: .foreground,
                                     identifier: .infoPopup,
                                     fontSize: UIFont.mediumSize,
                                     fontColor: .white)
        popupNode.addChild(descriptionLabel)
        
        let closeBtn = Button(size: Style.CloseButton.size,
                              delegate: self,
                              textureName: Constants.closeButton,
                              precedence: .menu)
        closeBtn.position = CGPoint.positionThis(closeBtn.frame, inTopRightOf: popupNode.frame)
        popupNode.addChild(closeBtn)
        popupNode.name = Constants.popup
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
            for item in items {
                item.deselect()
            }
        }
        
        func select() {
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
            } else if child.name == Constants.buyButton {
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
    
    func currencyWalletName(_ currency: Currency) -> String {
        return (currency == Currency.gold) ? Constants.goldWallet : Constants.gemWallet
    }
    
    private func reloadWalletView(_ currency: Currency) {
        let newWalletView = walletView(currency, order: CGFloat(Currency.allCases.firstIndex(of: currency) ?? 0))
        
        for child in children {
            if child.name == currencyWalletName(currency) {
                removeFromParent()
            }
        }
        
        show(newWalletView)
    }
    
    private func buy(_ storeItem: StoreItem) {
        let ability = storeItem.ability
        if playerData.canAfford(ability.cost, inCurrency: ability.currency) {
            playerData = playerData.add(ability)
            playerData = playerData.buy(ability)
            storeItem.purchase()
            reloadWalletView(ability.currency)
        }
    }
    
    private func sell(_ storeItem: StoreItem) {
        playerData = playerData.remove(storeItem.ability)
        playerData = playerData.sell(storeItem.ability)
        storeItem.sell()
        reloadWalletView(storeItem.ability.currency)
    }
    
    private func toggleTransactionButton() {
        hideButton(with: Constants.buyButton)
        hideButton(with: Constants.sellButton)
        if let selectedItem = selectedItem {
            showButton(selectedItem.isPurchased ? Constants.sellButton : Constants.buyButton)
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
    
    func wasTransactedOn(_ storeItem: StoreItem) {
        toggleUI()
    }
}

extension StoreScene: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        if button.name == "leaveStore" {
            storeSceneDelegate?.leave(self, updatedPlayerData: playerData)
        } else if button.name == Constants.buyButton,
            let storeItem = selectedItem {
            buy(storeItem)
        } else if button.name == Constants.sellButton,
            let storeItem = selectedItem {
            sell(storeItem)
        } else if button.name == Constants.closeButton {
            selectedItem = nil
        }
        
    }
}
