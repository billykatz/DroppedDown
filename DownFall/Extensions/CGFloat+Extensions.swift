//
//  CGFloat+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 4/11/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    
    /// Font sizes
    static let fontExtraSmallSize: CGFloat = 35.0
    static let fontSmallSize: CGFloat = 45.0
    static let fontMediumSize: CGFloat = 55.0
    static let fontLargeSize: CGFloat = 80.0
    static let fontExtraLargeSize: CGFloat = 96.0
    static let fontGiantSize: CGFloat = 200.0

    
    static let safeAreaHeight = CGFloat(75.0)
    
    static func progressAngle(progress: Int, total: Int) -> CGFloat {
        let ratio = CGFloat(progress)/CGFloat(total)
        return 2 * .pi * ratio
    }
    
    static func hypotenuseDistance(sideALength: CGFloat, sideBLength: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(sideALength*sideALength) + Float(sideBLength*sideBLength)))
    }
    
    static func angle(sideALength: CGFloat, sideBLength: CGFloat) -> CGFloat {
        return atan(sideBLength/sideALength)
    }
    
    
    static func isPositive(_ float: CGFloat) -> Bool {
        return float > 0
    }
    
    static func rotateAngle(startAngle: CGFloat, targetAngle: CGFloat, xDistance: CGFloat, yDistance: CGFloat) -> CGFloat {
        let extraRotate = .pi*2 - startAngle
        switch (isPositive(xDistance), isPositive(yDistance)) {
        case (true, true):
            //top right quadrant
            return targetAngle + extraRotate
        case (true, false):
            //bottom right quadrant
            return .pi/2 - targetAngle
        case (false, true):
            // top left quadrant
            return .pi - targetAngle + extraRotate
        case (false, false):
            //bottom left
            return .pi + targetAngle + extraRotate
        }
    }
}
