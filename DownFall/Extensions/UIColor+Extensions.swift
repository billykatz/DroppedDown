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
    static let storeItemBackground: UIColor = UIColor(rgb: 0x8fa9af)
    static let storeDarkGray = UIColor(rgb: 0x404040)
    static let storeBlack = UIColor(rgb: 0x171717)
    static let highlightGold = UIColor(rgb: 0xfcd833)
    static let highlightGreen = UIColor(rgb: 0x2a4f36)
}
