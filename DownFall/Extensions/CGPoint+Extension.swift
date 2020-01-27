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
        case .center:
            return CGPoint(x: that.center.x,
                           y: -that.height/2 + this.height/2 + padding)
        }
    }
    
    
    
    static func position(_ this: CGRect?,
                            anchoredLeftToThat that: CGRect) -> CGPoint {
        guard let this = this else { return .zero}
        return CGPoint(x: that.minX + this.width/2,
                       y: this.height/2)
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
        case .center:
            x = that.center.x
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
            y = that.maxY + this.height/2 + yOffset
        case .center:
            y = that.center.y
        case .bottom:
            y = that.minY - this.height/2 - yOffset
        }
        
        let x: CGFloat
        switch anchor {
        case .left:
            x = that.minX - this.width/2 - xOffset
        case .right:
            x = that.maxX + this.width/2 + xOffset
        case .center:
            x = that.center.x
        }
        
        return CGPoint(x: x, y: y)
    }
    
    
    static func position(_ this: CGRect,
                         inside that: CGRect,
                         verticaliy: Verticality,
                         anchor: Anchor,
                         xOffset: CGFloat = 0.0,
                         yOffset: CGFloat = 0.0) -> CGPoint {
        
        
        let y: CGFloat
        switch verticaliy {
        case .top:
            y = that.height/2 - this.height/2 - yOffset
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 + this.height/2 + yOffset
        }
        
        let x: CGFloat
        switch anchor {
        case .left:
            x = -that.width/2 + this.width/2 + xOffset
        case .center:
            x = 0.0
        case .right:
            x = that.width/2 - this.width/2 - xOffset
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
    
    static func position(this: CGRect,
                         centeredVerticallyInTopHalfOf that: CGRect,
                         xOffset: CGFloat = 0.0) -> CGPoint {
        let padding = (that.height - this.height) / 4
        return CGPoint(x: 0.0,
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
        return CGPoint(x: 0.0,
                       y: -that.height/2 - this.height/2 - spacing)
    }
    
    static func positionThis(_ this: CGRect?,
                             outsideOf that: CGRect?,
                             verticality: Verticality,
                             align: Anchor = .center,
                             spacing: CGFloat = 0.0) -> CGPoint {
        guard let this = this, let that = that else { return .zero}
        var y = CGFloat(0.0)
        var x = CGFloat(0.0)
        switch verticality {
        case .top:
            y = that.height/2 + this.height/2 + spacing
        case .bottom:
            y = -that.height/2 - this.height/2 - spacing
        case .center:
            y = 0.0
        }
        
        switch align {
        case .left:
            x = that.width/2 - this.width/2
        case .right:
            x = that.width/2 + this.width/2
        case .center:
            x = 0.0
        }
        
        return CGPoint(x: x, y: y)
    }
    
    /// Align horizontally on the left right or center but place the position on the outside
    static func alignHorizontally(_ this: CGRect?,
                      relativeTo that: CGRect?,
                      anchor: Anchor,
                      verticalAlign: Verticality,
                      padding : CGFloat = 0.0,
                      spacing: CGFloat = 0.0,
                      translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        var x = CGFloat(0.0)
        var y = CGFloat(0.0)
        
        switch anchor {
        case .center:
            x = 0.0
        case .left:
            x = -that.width/2 + this.width/2 + spacing
        case .right:
            x = that.width/2 - this.width/2 - spacing
        }
        
        switch verticalAlign {
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 - this.height/2 - padding
        case .top:
            y = that.height/2 + this.height/2 + padding
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        return CGPoint(x: x, y: y)
        
    }
    
    
    /// Align vertically on the top, bottom or center baseline but place the position on the outside
    static func alignVertically(_ this: CGRect?,
                      relativeTo that: CGRect?,
                      anchor: Anchor,
                      verticalAlign: Verticality,
                      padding : CGFloat = 0.0,
                      spacing: CGFloat = 0.0,
                      translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        var x = CGFloat(0.0)
        var y = CGFloat(0.0)
        
        switch anchor {
        case .center:
            x = 0.0
        case .left:
            x = -that.width/2 - this.width/2 - spacing
        case .right:
            x = that.width/2 + this.width/2 + spacing
        }
        
        switch verticalAlign {
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 + this.height/2 + padding
        case .top:
            y = that.height/2 - this.height/2 - padding
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        return CGPoint(x: x, y: y)
        
    }
    
    /// Position this outside of that.
    /// Anchor represents the left, right or center of that
    /// Align is the vertical alignment, top, bottom or center
    static func positionThis(_ this: CGRect?,
                             outside that: CGRect?,
                             anchor: Anchor,
                             align: Verticality = .center,
                             padding: CGFloat = 0.0,
                             spacing: CGFloat = 0.0,
                             translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        
        var x = CGFloat(0.0)
        var y = CGFloat(0.0)
        
        switch anchor {
        case .center:
            x = that.center.x
        case .left:
            x = -that.width/2 - this.width/2 - spacing
        case .right:
            x = that.width/2 + this.width/2 + spacing
        }
        
        switch align {
        case .center:
            y = that.center.y
        case .bottom:
            y = -that.height/2 - this.height/2 + padding
        case .top:
            y = that.height/2 - this.height/2 + padding
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        return CGPoint(x: x, y: y)
    }
    
    
    enum Anchor {
        case left
        case right
        case center
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

