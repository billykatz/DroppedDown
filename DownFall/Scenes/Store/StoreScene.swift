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
                            fontColor: .black,
                            backgroundColor: .menuPurple)
        
        button.position = CGPoint.position(button.frame, inside: frame, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: Style.Padding.most)
        
        
        items = createStoreItems(from: level)
        positionStore(items, playableWidth)
        items.forEach {
            addChild($0)
        }
        
        
        background.addChild(button)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
        let goldWallet = walletView(.gold, order: 0)
        addChild(goldWallet)
        
        
        let inventoryButton = Button(size: Button.medium,
                                     delegate: self,
                                     identifier: .seeInventory,
                                     precedence: .foreground,
                                     fontSize:  UIFont.smallSize,
                                     fontColor: .black,
                                     backgroundColor: .foregroundBlue)
        
        inventoryButton.position = CGPoint.alignHorizontally(inventoryButton.frame, relativeTo: goldWallet.frame, horizontalAnchor: .left, verticalAlign: .top, verticalPadding: Style.Padding.normal, translatedToBounds: true)
        addChild(inventoryButton)
        
        
        if level.type == .first {
            let infoPopup = informationPopup(with: "\"Welcome, first one is on the house!\"")
            show(infoPopup)
        }
        
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
            bottomLeft: CGPoint(x: -frame.width/2, y: 0 - Style.Store.InfoPopup.height/2)
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
                                                   anchored: .left,
                                                   verticalPadding: (2 + order) * walletView.frame.height)
        
        let currencySprite = SKSpriteNode(texture: SKTexture(imageNamed: currency.rawValue), size: Style.Store.Wallet.currencySize)
        currencySprite.position = CGPoint.position(currencySprite.frame, centeredOnTheRightOf: walletView.frame)
        
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
        
        let canAfford = playerData.canAfford(selectedItem?.ability.cost ?? 0, inCurrency: .gold)
        
        
        let purchaseButton = Button(size: Style.Store.CTAButton.size,
                                    delegate: self,
                                    identifier: !purchased ? .purchase : .sell,
                                    precedence: .foreground,
                                    fontSize: UIFont.mediumSize,
                                    fontColor: .white,
                                    backgroundColor: !purchased ? (canAfford ? .storeSceneGreen : .lightGray) : .black,
                                    showSelection: purchased || canAfford,
                                    disable: !purchased && !canAfford)
        purchaseButton.position = CGPoint.positionThis(purchaseButton.frame,
                                                       inBottomOf: frame,
                                                       anchored: .right,
                                                       verticalPadding: Style.Store.CTAButton.bottomPadding)
        return purchaseButton
    }
    
    private func toggleUI() {
        toggleSelect()
        togglePopup()
        toggleTransactionButton()
    }
    
    
    private func informationPopup(with text: String) -> SKSpriteNode {
        let popupNode = SKSpriteNode(color: .storeItemBackgroundNotSelected,
                                     size: CGSize(width: self.frame.width - Style.Store.InfoPopup.sidePadding, height: Style.Store.InfoPopup.height))
        
        popupNode.position = CGPoint.position(popupNode.frame, centeredInTopOf: frame, verticalOffset: Style.Store.InfoPopup.topPadding)
        
        let descriptionLabel = Label(text: text,
                                     width: popupNode.frame.width,
                                     delegate: nil,
                                     precedence: .foreground,
                                     identifier: .infoPopup,
                                     fontSize: UIFont.mediumSize,
                                     fontColor: .white)
        popupNode.addChild(descriptionLabel)
        
        let closeButton = Button(size: Style.Store.CloseButton.size,
                                 delegate: self,
                                 identifier: .close,
                                 precedence: .foreground,
                                 fontSize: UIFont.smallSize,
                                 fontColor: .white,
                                 backgroundColor: .darkGray)
        closeButton.position = CGPoint.position(closeButton.frame, inside: popupNode.frame, verticalAnchor: .top, horizontalAnchor: .right)
        popupNode.addChild(closeButton)
        popupNode.name = Constants.popup
        return popupNode
    }
    
    private func show(_ node: SKNode) {
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
            } else if child.name == ButtonIdentifier.purchase.rawValue {
                let slideOut = SKAction.moveTo(x: frame.maxX + child.frame.width/2,
                                               duration: 0.3)
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
                                               duration: 0.3)
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
        let newWalletView = walletView(currency, order: 0)
        
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
        hideButton(with: ButtonIdentifier.purchase.rawValue)
        hideButton(with: ButtonIdentifier.sell.rawValue)
        if let selectedItem = selectedItem {
            showButton(selectedItem.isPurchased ? ButtonIdentifier.sell.rawValue : ButtonIdentifier.purchase.rawValue)
        }
    }
    
    private func showButton(_ buttonName: String) {
        let button = transactionButton
        let slideIn = SKAction.moveTo(x: frame.maxX - transactionButton.frame.width/2,
                                      duration: 0.5)
        show(button)
        button.run(slideIn)
    }
    
    private var inventoryHidden: Bool = true {
        didSet {
            showInventory()
        }
    }
    private lazy var inventoryView: SKSpriteNode = {
        let width = frame.width*0.7
        let inventoryView = SKSpriteNode(color: .foregroundBlue, size: CGSize(width: width, height: frame.width*0.8))
        inventoryView.position = .zero
        inventoryView.zPosition = 1000
        
        return inventoryView
        
    }()
    
    private func showInventory() {
        if inventoryHidden {
            inventoryView.removeAllChildren()
            inventoryView.removeFromParent()
        } else if inventoryView.parent == nil {
            
            let border = SKShapeNode(rect: inventoryView.frame)
            border.strokeColor = UIColor.darkGray
            border.lineWidth = Style.Menu.borderWidth
            border.zPosition = Precedence.menu.rawValue + 100
            border.position = .zero
            inventoryView.addChild(border)
            
            let playerInventoryNames = playerData.abilities.map { ($0.type.humanReadable, $0.count) }
            var string = ""
            for (name, count) in playerInventoryNames {
                string += "\(name) \(count > 1 ? "x\(count)" : "" )"
                string += "\n"
            }
            if string.isEmpty {
                string = "None"
            }
            
            let paragraph = ParagraphNode(text: string, paragraphWidth: frame.width*0.7, fontSize: UIFont.smallSize, fontColor: .black)
            inventoryView.addChild(paragraph)
            
            addChild(inventoryView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !inventoryHidden {
            inventoryHidden = true
        }
        
        
    }
}

extension StoreScene: StoreItemDelegate {
    func storeItemTapped(_ storeItem: StoreItem, ability: Ability) {
        inventoryHidden = true
        selectedItem = storeItem
    }
    
    func wasTransactedOn(_ storeItem: StoreItem) {
        toggleUI()
    }
}

extension StoreScene: ButtonDelegate {
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .leaveStore:
            storeSceneDelegate?.leave(self, updatedPlayerData: playerData)
        case .purchase:
            if let storeItem = selectedItem { buy(storeItem) }
            
            if level.type == .first {
                for item in items {
                    item.isPurchased = true
                }
            }
        case .sell:
            if level.type == .first {
                for item in items {
                    sell(item)
                }
            } else {
                if let storeItem = selectedItem {
                    sell(storeItem)
                }
            }
            
        case .close:
            selectedItem = nil
        case .seeInventory:
            inventoryHidden = !inventoryHidden
        default:
            fatalError("You must add a case for added buttons here")
        }
    }
}
