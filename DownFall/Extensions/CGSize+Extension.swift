//
//  CGSize+Extension.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGSize {
    static var twentyFive = CGSize(width: 25, height: 25)
    static var fifty = CGSize(width: 50, height: 50)
    static var oneHundred = CGSize(width: 100, height: 100)
    static var oneFifty = CGSize(width: 150, height: 150)
    static let universalSize = CGSize(width: 1536, height: 2048)
    
    /// Button sizes
    static let buttonSmall = CGSize(width: 75, height: 30)
    static let buttonMedium = CGSize(width: 110, height: 50)
    static let buttonLarge = CGSize(width: 150, height: 75)
    static let buttonExtralarge = CGSize(width: 300, height: 150)
    
    static let buttonMainMenu = CGSize(width: 410, height: 202.5)
    
    var playableRect: CGRect {
        /// This is a special ratio based on the iPhoneX ratio.  However we also account for the safe areas so we dont show anything too close to the top or bottom of the screen.  The side safe areas are ignored because we dont put anything useful in those areas to begin with
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = height / maxAspectRatio
        return CGRect(x: -playableWidth/2,
                      y: -height/2,
                      width: playableWidth,
                      height: height)

    }
    
    func scale(by coefficient: CGFloat) -> CGSize {
        return CGSize(width: width * coefficient, height: height * coefficient)
    }
    
    func scaleWidth(by coefficient: CGFloat) -> CGSize {
        return CGSize(width: width * coefficient, height: height)
    }
    
    init(widthHeight: CGFloat) {
        self.init(width: widthHeight, height: widthHeight)
    }
}


extension CGSize: Comparable {
    // only good at comparing sizes with equal width and height
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        precondition(lhs.width == lhs.height && rhs.width == rhs.height, "You should only use this to compare sizes with equal width and height")
        return lhs.width < rhs.width && lhs.height < rhs.height
    }
    
    
}
