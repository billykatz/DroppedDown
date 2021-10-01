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
    case menu = 20000
    case aboveMenu = 30
    case floating = 100
    case flying = 200
}

func compare(_ a: [[DFTileSpriteNode]], _ b: [[DFTileSpriteNode]]) {
    var output = ""
    for (ridx, _) in a.enumerated() {
        for (cidx, _) in a[ridx].enumerated() {
            if a[ridx][cidx].type !=  b[ridx][cidx].type {
                output += "\n-----\nRow \(ridx), Col \(cidx) are different.\nBefore is \(a[ridx][cidx].type) \nAfter is \(b[ridx][cidx].type)"
            }
        }
    }
    if output == "" { output = "\n-----\nThere are no differences" }
    print(output)
}

