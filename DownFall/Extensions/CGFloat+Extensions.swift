//
//  CGFloat+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 4/11/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    static func progressAngle(progress: Int, total: Int) -> CGFloat {
        let ratio = CGFloat(progress)/CGFloat(total)
        return 2 * .pi * ratio
    }
}
