//
//  CGPoint+Extension.swift
//  DownFall
//
//  Created by William Katz on 8/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    static func gridPositions(rows: CGFloat,
                              columns: CGFloat,
                              itemSize: CGSize,
                              width: CGFloat,
                              height: CGFloat,
                              bottomLeft: CGPoint) -> [CGPoint] {
        
        let inset: CGFloat = 10.0
        let columnPadding = (width - (columns * itemSize.width) - (2 * inset)) / (columns-1)
        let rowPadding = (height - (rows * itemSize.height)) / (rows - 1)
        
        
        var points: [CGPoint] = []
        for row in 0..<Int(rows) {
            for column in 0..<Int(columns) {
                let rowFloat = CGFloat(row)
                let columnFloat = CGFloat(column)
                let y = bottomLeft.y + itemSize.height/2 + (rowFloat * rowPadding)
                let x = bottomLeft.x + inset + itemSize.width/2 + (columnFloat * columnPadding) + (columnFloat * itemSize.width)
                points.append(CGPoint(x: x, y: y))
            }
        }
        
        return points
    }
    
    static func positionThis(_ this: CGRect, inTopRightOf that: CGRect) -> CGPoint {
        return CGPoint(x: that.width/2 - this.width/2,
                       y: that.height/2 - this.height/2)
    }
}
