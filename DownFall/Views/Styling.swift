//
//  Styling.swift
//  DownFall
//
//  Created by William Katz on 12/4/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics


struct Style {
    static let buttonToBottomPadding: CGFloat = 16.0
    static let paragraphPadding: CGFloat = 8.0
    
    struct LevelGoalKey {
        static let keyTextureSize = CGSize(width: 50, height: 50)
        static let keyCircleRadius = CGFloat(15)
    }
    
    struct FillableBar {
        static let cornerRadius: CGFloat = 2.0
        static let lineWidth: CGFloat = 2.5
    }
    
    struct DetailView {
        static let spriteSize = CGSize(width: 200.0, height: 200.0)
        static let closeButtonSize = CGSize(width: 75.0, height: 75.0)
    }
    
    struct Backpack {
        static let heightCoefficient = CGFloat(0.20)
        static let runeInventorySize = CGFloat(300)
        
        struct Toast {
            static let width = CGFloat(600)
            static let height = CGFloat(200)
            static let cornerRadius = CGFloat(50)
        }
    }
    
    struct Store {
        struct InfoPopup {
            static let topPadding: CGFloat = 16.0
            static let sidePadding: CGFloat = 40.0
            static let height: CGFloat = 150    
        }
        
        struct Item {
            static let size: CGSize = CGSize(width: 400.0, height: 400.0)
        }
        
        struct ItemGrid {
            static let height: CGFloat = 450.0
        }
        
        struct Wallet {
            static let viewSize = CGSize(width: 150, height: 50)
            static let currencySize = CGSize(width: 30.0, height: 30.0)
        }
        
        struct CTAButton {
            static let size = CGSize(width: 175, height: 75)
            static let bottomPadding = CGFloat(125)
        }
        
        struct CloseButton {
            static let size = CGSize(width: 100, height: 35)
        }

    }
    
    struct Board {
        static let goldGainSize = CGSize(width: 100, height: 100)
        static let goldGainSizeEnd = CGSize(width: 50, height: 50)
    }
    
        
    struct Padding {
        static let less: CGFloat = 4.0
        static let normal: CGFloat = 8.0
        static let more: CGFloat = 16.0
        static let most: CGFloat = 24.0
        static let safeArea: CGFloat  = 75.0
    }
    
    struct Spacing {
        static let normal: CGFloat = 20.0
    }
    
    struct Offset {
        static let less: CGFloat = 5.0
    }
    
    struct TutorialHighlight {
        static let lineWidth: CGFloat = 7.5
        static let radius: CGFloat = 100.0
        static let fingerSize: CGSize = CGSize(width: 75.0, height: 75.0)
        static let fingerTimeInterval: Double = 0.5
    }
    
    struct Tile {
        static let size: CGFloat = 105.0
    }
    
    struct DFTileSpriteNode {
        struct Exit {
            static let minecartSizeCoefficient: CGFloat = 0.7
        }
    }
    
    struct Header {
        static let height: CGFloat = 200.0
    }
    
    struct Menu {
        static let borderWidth: CGFloat = 20.0
    }
    
    struct RunMenu {
        static let buttonSize = CGSize(width: 300.0, height: 150.0)
    }
    
    struct Button {
        static let size = CGSize(width: 50.0, height: 50.0)
        static let touchzone = CGFloat(12)
    }
    
    struct LevelGoalView {
        static let height = CGFloat(400.0)
    }
    
    struct HUD {
        static let height: CGFloat = 300.0
        static let heartSize = CGSize(width: 100.0, height: 100.0)
        static let gemSize = CGSize(width: 75.0, height: 75.0)
        static let labelParagraphWidth = CGFloat(200.0)
        static let coinLabelPadding = CGFloat (50.0)
        static let gemSpritePadding = CGFloat(16.0)
        static let healthBarWidthRatio = CGFloat(0.50)
        static let healthBarHeight = CGFloat(50.0)
        static let lanternSize = CGSize(width: 150.0, height: 150.0)
    }
}
