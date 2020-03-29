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
    
    static func -(_ lhs: CGPoint, _ rhs: CGPoint) -> CGVector {
        return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }
    
    static func gridPositions(rows: CGFloat,
                              columns: CGFloat,
                              itemSize: CGSize,
                              width: CGFloat,
                              height: CGFloat,
                              bottomLeft: CGPoint) -> [CGPoint] {
        
        let inset: CGFloat = 15.0
        let bottomPadding: CGFloat = 30.0
        let columnPadding = max(0, (width - (columns * itemSize.width) - (2 * inset)) / (columns-1) )
        let rowPadding = min(45.0, (height - (rows * itemSize.height)) / (rows - 1))
        
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
    
    static func position(this: CGRect,
                         centeredInBottomOf that: CGRect?,
                         verticalPadding: CGFloat = Style.Padding.normal) -> CGPoint {
        return CGPoint.position(this, inside: that, verticalAlign: .bottom, horizontalAnchor: .center, yOffset: verticalPadding)
    }
    
    static func positionThis(_ this: CGRect?,
                             inBottomOf that: CGRect,
                             anchored anchor: Anchor,
                             verticalPadding: CGFloat = Style.Padding.normal,
                             horinztonalPadding: CGFloat = 0.0) -> CGPoint {
        return CGPoint.position(this, inside: that, verticalAlign: .bottom, horizontalAnchor: anchor, xOffset: horinztonalPadding, yOffset: verticalPadding)
    }
    
    
    /// Convenience to placing a view in side another view with equal vorizontal and vetical padding
    static func position(_ this: CGRect?,
                         inside that: CGRect?,
                         verticalAnchor: Verticality,
                         horizontalAnchor: Anchor,
                         padding: CGFloat = 0.0) -> CGPoint {
        
        return CGPoint.position(this, inside: that, verticalAlign: verticalAnchor, horizontalAnchor: horizontalAnchor, xOffset: padding, yOffset: padding)
    }
    
    /// Position a view insde relative to another view.
    /// The anchor is the horizontal align.
    /// Note: this does not translte to a parent coord system.  If 
    static func position(_ this: CGRect?,
                         inside that: CGRect?,
                         verticalAlign: Verticality,
                         horizontalAnchor: Anchor,
                         xOffset: CGFloat = 0.0,
                         yOffset: CGFloat = 0.0,
                         translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        var y: CGFloat
        switch verticalAlign {
        case .top:
            y = that.height/2 - this.height/2 - yOffset
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 + this.height/2 + yOffset
        }
        
        var x: CGFloat
        switch horizontalAnchor {
        case .left:
            x = -that.width/2 + this.width/2 + xOffset
        case .center:
            x = 0.0
        case .right:
            x = that.width/2 - this.width/2 - xOffset
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        
        return CGPoint(x: x, y: y)
    }
    
    /// Center a view in the top of another view with their top edges aligned
    static func position(_ this: CGRect,
                         centeredInTopOf that: CGRect,
                         verticalOffset: CGFloat = 0.0,
                         horizontalOffset: CGFloat = 0.0) -> CGPoint {
        return CGPoint.position(this, inside: that, verticalAlign: .top, horizontalAnchor: .center, xOffset: horizontalOffset, yOffset: verticalOffset)
    }
    
    /// Very specific to certain UI elements where we visually cut off the bottom half of the node and there want to center text vertically in the other half.
    static func position(this: CGRect,
                         centeredVerticallyInTopHalfOf that: CGRect,
                         xOffset: CGFloat = 0.0) -> CGPoint {
        let padding = (that.height - this.height) / 4
        return CGPoint(x: 0.0,
                       y: that.height/2 - this.height/4 - padding)
    }
    
    
    /// Use this to center a view within another view with the right edges aligned
    static func position(_ this: CGRect,
                         centeredOnTheRightOf that: CGRect,
                         horizontalOffset: CGFloat = 0.0,
                         verticalOffset: CGFloat = 0.0) -> CGPoint {
        return CGPoint.position(this, inside: that, verticalAlign: .center, horizontalAnchor: .right, xOffset: horizontalOffset, yOffset: verticalOffset)
    }
    
    /// Align horizontally on the left right or center but position on the outside
    static func alignHorizontally(_ this: CGRect?,
                                  relativeTo that: CGRect?,
                                  horizontalAnchor: Anchor,
                                  verticalAlign: Verticality,
                                  verticalPadding : CGFloat = 0.0,
                                  horizontalPadding: CGFloat = 0.0,
                                  translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        var x = CGFloat(0.0)
        var y = CGFloat(0.0)
        
        switch horizontalAnchor {
        case .center:
            x = 0.0
        case .left:
            x = -that.width/2 + this.width/2 + horizontalPadding
        case .right:
            x = that.width/2 - this.width/2 - horizontalPadding
        }
        
        switch verticalAlign {
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 - this.height/2 - verticalPadding
        case .top:
            y = that.height/2 + this.height/2 + verticalPadding
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        return CGPoint(x: x, y: y)
        
    }
    
    
    /// Align vertically on the top, bottom or center baseline but position on the outside of `that`
    static func alignVertically(_ this: CGRect?,
                                relativeTo that: CGRect?,
                                horizontalAnchor: Anchor,
                                verticalAlign: Verticality,
                                verticalPadding : CGFloat = 0.0,
                                horizontalPadding: CGFloat = 0.0,
                                translatedToBounds: Bool = false) -> CGPoint {
        guard let this = this, let that = that else { return .zero }
        
        var x = CGFloat(0.0)
        var y = CGFloat(0.0)
        
        switch horizontalAnchor {
        case .center:
            x = 0.0
        case .left:
            x = -that.width/2 - this.width/2 - horizontalPadding
        case .right:
            x = that.width/2 + this.width/2 + horizontalPadding
        }
        
        switch verticalAlign {
        case .center:
            y = 0.0
        case .bottom:
            y = -that.height/2 + this.height/2 + verticalPadding
        case .top:
            y = that.height/2 - this.height/2 - verticalPadding
        }
        
        if translatedToBounds {
            x = that.center.x + x
            y = that.center.y + y
        }
        return CGPoint(x: x, y: y)
        
    }
    
    /// an enum to represent the horizontal anchors for positioning
    enum Anchor {
        case left
        case right
        case center
    }
    
    /// an enum to represent the vertical anchors for positioning
    enum Verticality {
        case top
        case center
        case bottom
    }
    
    func translateVertically(_ yOffset: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + yOffset)
    }
}

