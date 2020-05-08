//
//  Util.swift
//  DownFall
//
//  Created by William Katz on 5/17/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import CoreGraphics

enum Precedence: CGFloat {
    case underground = -10
    case background = 0
    case foreground = 10
    case menu = 20
    case aboveMenu = 30
    case floating = 100
}

