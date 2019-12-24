//
//  CGPoint+Extension.swift
//  DownFall
//
//  Created by William Katz on 8/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics
import Foundation

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
    
    static func positionThis(_ this: CGRect,
                             inTopRightOf that: CGRect,
                             padding: CGFloat = Style.Padding.normal) -> CGPoint {
        return CGPoint(x: that.width/2 - this.width/2 - padding,
                       y: that.height/2 - this.height/2 - padding)
    }
    
    
    static func positionThis(_ this: CGRect,
                             inBottomOf that: CGRect,
                             padding: CGFloat = Style.Padding.normal,
                             offset: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: 0.0 + offset,
                       y: -that.height/2 + this.height/2 + padding)
    }
    
    static func positionThis(_ this: CGRect,
                             inBottomOf that: CGRect,
                             padding: CGFloat = Style.Padding.normal,
                             anchor: Anchor,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        switch anchor {
        case .left:
            return CGPoint(x: -that.width/2 + this.width/2 + xOffset,
                           y: -that.height/2 + this.height/2 + padding)
        case .right:
            return CGPoint(x: that.width/2 - this.width/2 + xOffset,
                           y: -that.height/2 + this.height/2 + padding)
        }
    }

    
    static func positionThis(_ this: CGRect,
                             inTopOf that: CGRect,
                             padding: CGFloat = 0.0,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: 0.0 + xOffset,
                       y: that.height/2 - this.height/2 - padding)
    }
    
    static func positionThis(_ this: CGRect,
                        toTheRightOf that: CGRect,
                        padding: CGFloat = 0.0,
                        yOffset: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: that.width/2 - this.width/2 - padding,
                       y: 0.0 + yOffset)
    }
    
    static func positionThis(_ this: CGRect,
                             below that: CGRect,
                             spacing: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: that.center.x,
                       y: that.center.y - this.height - spacing)
    }
    
    enum Anchor {
        case left
        case right
    }
}
