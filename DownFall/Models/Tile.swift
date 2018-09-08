//
//  DFTileSpriteNode.swift
//  DownFall
//
//  Created by William Katz on 5/11/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

protocol Tappable {
    func isTappable() -> Bool
}

enum Search : Int {
    case white
    case gray
    case black
}

struct RockData {
    let textureName : String
    
}

enum Type {
    case rock(RockData)
    case player
    case empty
    case exit
}

extension Type: Equatable {
    static func == (lhs: Type, rhs: Type) -> Bool {
        switch lhs{
        case .rock(let lhsData):
            switch rhs{
            case .rock(let rhsData):
                return lhsData.textureName == rhsData.textureName
            default:
                return false
            }
        case .player:
            switch rhs{
            case .player: return true
            default: return false
            }
        case .empty:
            switch rhs{
            case .empty: return true
            default: return false
            }
        case .exit:
            switch rhs{
            case .exit: return true
            default: return false
            }
        }

    }
}

enum TextureName : String {
    case blue = "blueRock"
    case black = "blackRock"
    case green = "greenRock"
    case empty = "emptyTexture"
    case player = "player"
    case exit = "exit"
    
    static let allValues = [blue, black, green, empty, player, exit]
}

extension DFTileSpriteNode: Tappable {
    func isTappable() -> Bool {
        return type != .player && type != .exit
    }
}

class DFTileSpriteNode : SKSpriteNode {
    
    
    var type : Type
    var search : Search
    var selected : Bool = false
    
    init(type: Type, search: Search = .white) {
        self.type = type
        self.search = search
        let texture : SKTexture
        switch type {
        case .rock(let data):
            texture = SKTexture.init(imageNamed: data.textureName)
        case .empty:
            texture = SKTexture.init(imageNamed: TextureName.allValues[3].rawValue)
        case .player:
            texture = SKTexture.init(imageNamed: TextureName.allValues[4].rawValue)
        case .exit:
            texture = SKTexture.init(imageNamed: TextureName.allValues[5].rawValue)
        }
        super.init(texture: texture, color: .clear, size: CGSize.init(width: 75.0, height: 75.0))
    }

    class func randomRock() -> DFTileSpriteNode {
        let randomNumber = Int.random(3)
        let textureName = TextureName.allValues[randomNumber].rawValue
        let type = Type.rock(RockData.init(textureName: textureName))
        return DFTileSpriteNode.init(type: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Aint implemented")
    }
    
    static func == (lhs: DFTileSpriteNode, rhs: DFTileSpriteNode) -> Bool {
        return lhs.type == rhs.type
    }
}

