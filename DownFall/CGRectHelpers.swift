//
//  CGRectHelpers.swift
//  DownFall
//
//  Created by William Katz on 3/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit


extension CGRect{
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
