//
//  UIColor+Extensions.swift
//  DownFall
//
//  Created by William Katz on 6/30/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let clayRed: UIColor = UIColor(rgb: 0x9c461f)
    static let darkClayRed = UIColor(rgb: 0x743110)
    static let storeItemBackgroundNotSelected = UIColor(rgb: 0x8fa9af)
    static let storeDarkGray = UIColor(rgb: 0x404040)
    static let storeBlack = UIColor(rgb: 0x171717)
    static let highlightGold = UIColor(rgb: 0xfcd833)
    static let highlightGreen = UIColor(rgb: 0x2a4f36)
    static let menuPurple = UIColor(rgb: 0x4c2f84)
    static let foregroundBlue = UIColor(rgb: 0x6885ac)
    static let eggshellWhite = UIColor(rgb: 0xc7c6c2)
    static let storeSceneGreen = UIColor(rgb: 0x3b6518)
    
    /// Fillable Bar Colors
    static let lightBarPurple = UIColor(rgb: 0x603c8d)
    static let darkBarPurple = UIColor(rgb: 0x322049)
    static let lightBarRed = UIColor(rgb: 0xae4510)
    static let darkBarRed = UIColor(rgb: 0x803608)
    static let lightBarBlue = UIColor(rgb: 0x8fb7ea)
    static let darkBarBlue = UIColor(rgb: 0x4b4f7c)
    static let backgroundGray = UIColor(rgb: 0x262626)
    static let darkBarMonster = UIColor(rgb: 0x930505)
    static let lightBarMonster = UIColor(rgb: 0xe11a1a)
    static let darkBarGem = UIColor(rgb: 0x65b596)
    static let lightBarGem = UIColor(rgb: 0x9edfc6)

    /// Rune colors
    static let goldOutlineDull = UIColor(rgb: 0x9E8B2C)
    static let goldOutlineBright = UIColor(rgb: 0xFDD300)
    static let runeBackgroundColor = UIColor(rgb: 0x522B28)
    
    /// Rune Deteail color
    static let runeDetailColor = UIColor(rgb: 0x572d29)
    
    /// Confirmation button
    static let confirmButtonColor = UIColor(rgb: 0x177a31)
//    static let cancelButtonColor = UIColor(rgb: 0x)
}
