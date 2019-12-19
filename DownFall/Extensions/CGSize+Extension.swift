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
        let maxAspectRatio : CGFloat = 19.5/9.0
        let playableWidth = height / maxAspectRatio
        return CGRect(x: -playableWidth/2,
                      y: -height/2,
                      width: playableWidth,
                      height: height)

    }
    
    func adjusted(by coefficient: CGFloat) -> CGSize {
        return CGSize(width: width * coefficient, height: height * coefficient)
    }
}
