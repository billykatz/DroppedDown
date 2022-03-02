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
    
     // Menu
    static let menuPurple = UIColor(rgb: 0x4c2f84)
    static let menuBorderGray = UIColor(rgb: 0x6C717E)
    
    // Buttons
    static let buttonDestructiveRed = UIColor(rgb: 0xCA0000)
    static let buttonGray = UIColor(rgb: 0xc4c4c4)
    
    // BG Gray
    static let backgroundGray = UIColor(rgb: 0x262626)
    static let clayRed: UIColor = UIColor(rgb: 0x9c461f)
    
    static let foregroundBlue = UIColor(rgb: 0x6885ac)
    static let tileDetailViewBackground = UIColor(rgb: 0xB2B5C2)
    static let eggshellWhite = UIColor(rgb: 0xc7c6c2)
    static let storeItemBackgroundNotSelected = UIColor(rgb: 0x8fa9af)

    
    /// Fillable Bar Colors
    static let lightBarPurple = UIColor(rgb: 0x603c8d)
    static let darkBarPurple = UIColor(rgb: 0x322049)
    static let lightBarRed = UIColor(rgb: 0xae4510)
    static let darkBarRed = UIColor(rgb: 0x803608)
    static let lightBarBlue = UIColor(rgb: 0x8fb7ea)
    static let darkBarBlue = UIColor(rgb: 0x4b4f7c)
    static let darkBarMonster = UIColor(rgb: 0x930505)
    static let lightBarMonster = UIColor(rgb: 0xe11a1a)
    static let darkBarGem = UIColor(rgb: 0x65b596)
    static let lightBarGem = UIColor(rgb: 0x9edfc6)
    static let lightBarRune = UIColor(rgb: 0xafafaf)
    static let darkBarRune = UIColor(rgb: 0x817e7e)
    static let lightBarPillar = UIColor(rgb: 0xA0D398)
    static let darkBarPillar = UIColor(rgb: 0x4C7D44)
    static let lightBarBlood = UIColor(rgb: 0xD22E35)
    static let darkBarBlood = UIColor(rgb: 0x9A1F2F)

    /// Rune colors
    static let goldOutlineDull = UIColor(rgb: 0x9E8B2C)
    static let goldOutlineBright = UIColor(rgb: 0xFDD300)
    static let runeBackgroundColor = UIColor(rgb: 0x522B28)
    
    /// Rune Detail color
    static let runeDetailFillColor = UIColor(rgb: 0x572d29)
    static let runeDetailBorderColor = UIColor(rgb: 0x512F2A)
    
    /// Confirmation button
    static let confirmButtonColor = UIColor(rgb: 0x177a31)
    
    // Codex
    static let codexItemBackgroundBlue = UIColor(rgb: 0x314768)
    static let codexItemBackgroundLightGray = UIColor(rgb: 0x747474)
    static let codexItemBackgroundBlack = UIColor.black
    static let codexItemStrokeBlue = UIColor(rgb: 0x8091AB)
    static let codexItemStrokeGray = UIColor(rgb: 0x626262)
    static let codexRedText = UIColor(rgb: 0xFF5050)
    static let codexDarkGray = UIColor(rgb: 0x999999)
    static let codexButtonLightGray = UIColor(rgb: 0xDEDEDE)
    
    // Rune replacement
    static let runeInfoBorder = UIColor(rgb: 0x924A29)
    static let runeReplacementBackgroundFillBlue = UIColor(rgb: 0x314768)
    static let runeReplacementBackgroundStrokeBlue = UIColor(rgb: 0x8091AB)
    static let runeReplacementEmptyPanelBackground = UIColor(rgb: 0x182334)
    
    // Rune Use colors
    static let runeChargedYellow = UIColor(rgb: 0xFDD300)
    static let runeIllegalTargetsRed = UIColor(rgb: 0xFF0909)
    
    
    // Dialogue
    static let dialogueBoxBackground = UIColor(rgb: 0x508D9A)
    
    // GAme recap
    static let gameRecapBlue = UIColor(rgb: 0x566C8F)
    
}
