//
//  CGSize+Extension.swift
//  DownFall
//
//  Created by William Katz on 11/7/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGSize {
    var playableRect: CGRect {
        /// This is a special ratio based on the iPhoneX ratio.  However we also account for the safe areas so we dont show anything too close to the top or bottom of the screen.  The side safe areas are ignored because we dont put anything useful in those areas to begin with
//        let maxAspectRatio : CGFloat = 17.60/9.0
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
}
