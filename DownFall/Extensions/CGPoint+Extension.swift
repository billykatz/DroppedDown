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
        
        let inset: CGFloat = 15.0
        let bottomPadding: CGFloat = 30.0
        let columnPadding = max(0, (width - (columns * itemSize.width) - (2 * inset)) / (columns-1) )
        let rowPadding = min(30.0, (height - (rows * itemSize.height)) / (rows - 1))
        
        var points: [CGPoint] = []
        for row in 0..<Int(rows) {
            for column in 0..<Int(columns) {
                let rowFloat = CGFloat(row)
                let columnFloat = CGFloat(column)
                let y = bottomLeft.y + bottomPadding + itemSize.height/2 + (rowFloat * rowPadding) + (rowFloat * itemSize.height)
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
                             inBottomOf that: CGRect?,
                             padding: CGFloat = Style.Padding.normal,
                             offset: CGFloat = 0.0) -> CGPoint {
        guard let that = that else { return .zero }
        return CGPoint(x: 0.0 + offset,
                       y: -that.height/2 + this.height/2 + padding)
    }
    
    static func positionThis(_ this: CGRect?,
                             inBottomOf that: CGRect,
                             padding: CGFloat = Style.Padding.normal,
                             anchor: Anchor,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        guard let this = this else { return .zero}
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
                             in that: CGRect,
                             padding: CGFloat = Style.Padding.normal,
                             verticality: Verticality,
                             anchor: Anchor,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        
        
        let y: CGFloat
        switch verticality {
        case .top:
            y = that.height/2 - this.height/2 - padding
        case .center:
            y = that.center.y
        case .bottom:
            y = -that.height/2 + this.height/2 + padding
        }
        
        let x: CGFloat
        switch anchor {
        case .left:
            x = -that.width/2 + this.width/2 + xOffset
        case .right:
            x = that.width/2 - this.width/2 + xOffset
        }
        
        return CGPoint(x: x, y: y)
    }
    
    static func positionThis(_ this: CGRect,
                             relativeTo that: CGRect,
                             verticaliy: Verticality,
                             anchor: Anchor,
                             xOffset: CGFloat = 0.0,
                             yOffset: CGFloat = 0.0) -> CGPoint {
        
        
        let y: CGFloat
        switch verticaliy {
        case .top:
            y = that.center.y + that.height/2 + this.height/2 + yOffset
        case .center:
            y = that.center.y
        case .bottom:
            y = that.center.y - that.height - this.height/2 - yOffset
        }
        
        let x: CGFloat
        switch anchor {
        case .left:
            x = that.center.x - that.width/2 - this.width/2 - xOffset
        case .right:
            x = that.center.x + that.width/2 + this.width/2 + xOffset
        }
        
        return CGPoint(x: x, y: y)
    }
    
    
    
    
    static func positionThis(_ this: CGRect,
                             inTopOf that: CGRect,
                             padding: CGFloat = 0.0,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: 0.0 + xOffset,
                       y: that.height/2 - this.height/2 - padding)
    }
    
    static func positionThis(_ this: CGRect,
                             inTopOfHalf that: CGRect,
                             xOffset: CGFloat = 0.0) -> CGPoint {
        let padding = (that.height - this.height) / 4
        return CGPoint(x: this.center.x,
                       y: that.height/2 - this.height/4 - padding)
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
                       y: that.center.y - (that.height/2) - (this.height/2) - spacing)
    }
    
    static func positionThis(_ this: CGRect?,
                             outsideOf that: CGRect?,
                             verticality: Verticality,
                             spacing: CGFloat = 0.0) -> CGPoint {
        guard let this = this, let that = that else { return .zero}
        switch verticality {
        case .top:
            return CGPoint(x: that.center.x,
                           y: that.center.y + (that.height/2) + (this.height/2) + spacing)
        case .bottom:
            return CGPoint(x: that.center.x,
                           y: that.center.y - (that.height/2) - (this.height/2) - spacing)
        case .center:
            fatalError("This doesnt make sense")
        }
    }
    
    static func positionThis(_ this: CGRect?,
                             outside that: CGRect?,
                             anchor: Anchor,
                             align: Verticality = .center,
                             padding: CGFloat = 0.0,
                             spacing: CGFloat = 0.0) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        switch (anchor, align) {
        case (.left, .top):
            return CGPoint(x: that.minX - this.width/2, y: that.maxY - this.height/2 + padding)
            
        case (.left, .center):
            return CGPoint(x: that.minX - this.width/2, y: that.center.y + padding)
            
        case (.left, .bottom):
            return CGPoint(x: that.minX - this.width/2, y: that.minY + this.height/2 + padding)
            
        case (.right, .top):
            return CGPoint(x: that.maxX + this.width/2, y: that.maxY - this.height/2 + padding)
            
        case (.right, .center):
            return CGPoint(x: that.maxX + this.width/2, y: that.center.y + padding)
            
        case (.right, .bottom):
            return CGPoint(x: that.maxX + this.width/2, y: that.minY + this.height/2 + padding)
        }
    }
    
    
    enum Anchor {
        case left
        case right
    }
    
    enum Verticality {
        case top
        case center
        case bottom
    }
    
    func translateVertically(_ yOffset: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + yOffset)
    }
}

