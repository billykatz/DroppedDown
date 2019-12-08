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
    
    struct Store {
        struct InfoPopup {
            static let topPadding: CGFloat = 16.0
            static let sidePadding: CGFloat = 40.0
            static let height: CGFloat = 150    
        }
    }
    
    struct CloseButton {
        static let size = CGSize(width: 35, height: 35)
    }
}
