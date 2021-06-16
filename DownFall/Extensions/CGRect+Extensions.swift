//
//  CGRectHelpers.swift
//  DownFall
//
//  Created by William Katz on 3/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    /**
     Creates a new CGRect by removing area from the bottom of the rect that calls this method
     
     - Parameters areaRatio: The ratio that should be subtracted form the bottom.  The value must be less than or equal 1
     */
    
    func subtractBottom(_ areaRatio: CGFloat) -> CGRect{
        assert(areaRatio <= 1, "The areaRatio must be less than or equal to 1")
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.width, height: self.height - self.height * areaRatio)
    }
    
    
    /// Scale a rect by an factor on the x and y scale.  It keeps the same center
    func scale(by xAmount: CGFloat, andYAmount yAmount: CGFloat) -> CGRect {
        return CGRect(
            x: center.x,
            y: center.y,
            width: width + xAmount,
            height: height + yAmount
        )
    }
    
    static var one: CGRect {
        return CGRect(x: 1, y: 1, width: 1, height: 1)
    }
}
