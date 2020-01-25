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
    
    struct Backpack {
        static let heightCoefficient = CGFloat(0.20)
        static let backpackViewSizeCoefficient = CGFloat(0.75)
        static let itemSize = CGSize(width: 150, height: 150)
        static let ctaButton = CGFloat(200)
        
        struct Toast {
            static let width = CGFloat(800)
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
            static let size: CGSize = CGSize(width: 75.0, height: 75.0)
        }
        
        struct ItemGrid {
            static let height: CGFloat = 450.0
        }
        
        struct Wallet {
            static let viewSize = CGSize(width: 150, height: 50)
            static let currencySize = CGSize(width: 30.0, height: 30.0)
        }
        
        struct CTAButton {
            static let size = CGSize(width: 200, height: 50)
            static let bottomPadding = CGFloat(200)
        }
        
        struct CloseButton {
            static let size = CGSize(width: 100, height: 35)
        }

    }
    
        
    struct Padding {
        static let less: CGFloat = 4.0
        static let normal: CGFloat = 8.0
        static let more: CGFloat = 16.0
        static let most: CGFloat = 24.0
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
        static let borderWidth: CGFloat = 10.0
    }
    
    struct RunMenu {
        static let buttonSize = CGSize(width: 300.0, height: 150.0)
    }
    
    struct Button {
        static let size = CGSize(width: 50.0, height: 50.0)
        static let touchzone = CGFloat(12)
    }
    
    struct HUD {
        static let height: CGFloat = 200.0
        static let heartSize = CGSize(width: 100.0, height: 100.0)
        static let gemSize = CGSize(width: 75.0, height: 75.0)
        static let labelParagraphWidth = CGFloat(200.0)
        static let coinLabelPadding = CGFloat (50.0)
        static let gemSpritePadding = CGFloat(16.0)
    }
}
