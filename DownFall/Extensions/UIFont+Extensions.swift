//
//  UIFont+Extensions.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIFont {
    static let pixel = UIFont(name: UIFont.pixelFontName, size: .fontExtraSmallSize)
    static let storeItemDescription = UIFont(name: UIFont.pixelFontName, size: .fontExtraSmallSize)!
    static let pixelFontName = "Alterebro-Pixel-Font"
    
    static let highPixelFontName = "PixelHigh"
    static let middlePixelFontName = "PixelMiddle"
    static let smallPixelFontName = "PixelSmallv2"
    
    static let codexFont = UIFont(name: UIFont.pixelFontName, size: 30.0)!
    static let buttonFont = UIFont(name: UIFont.pixelFontName, size: 40.0)!
    static let titleCodexFont = UIFont(name: UIFont.pixelFontName, size: 45.0)!
    static let bigTitleCodexFont = UIFont(name: UIFont.middlePixelFontName, size: 55.0)!
    static let bigSubtitleCodexFont = UIFont(name: UIFont.pixelFontName, size: 55.0)!
    
    static let creditsTitleCodexFont = UIFont(name: UIFont.middlePixelFontName, size: 60.0)!
    static let creditsSubTitleCodexFont = UIFont(name: UIFont.smallPixelFontName, size: 45.0)!
    static let creditsNameCodexFont = UIFont(name: UIFont.smallPixelFontName, size: 40.0)!
    static let creditsBigNameCodexFont = UIFont(name: UIFont.middlePixelFontName, size: 60.0)!
    
}

enum UIFontType: String {
    case legacy = "Alterebro-Pixel-Font"
    case high = "PixelHigh"
    case middle = "PixelMiddle"
    case small = "PixelSmallv2"
}
