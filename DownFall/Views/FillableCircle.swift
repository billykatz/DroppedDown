//
//  FillableCircle.swift
//  DownFall
//
//  Created by Katz, Billy on 4/11/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol FillableCircleViewModelable {
    var radius: CGFloat { get }
    var darkFillColor: UIColor { get }
}

struct FillableCircleViewModel: FillableCircleViewModelable & FillableBarViewModelable {
    var radius: CGFloat
    var total: Int
    var progress: Int
    var fillColor: UIColor
    var darkFillColor: UIColor
    var text: String?
    var backgroundColor: UIColor?
}

class FillableCircleBar: SKSpriteNode {
    let viewModel: FillableCircleViewModel
    let contentView: SKSpriteNode
    
    struct Constants {
        static let lineWidth = CGFloat(30.0)
        static let overlapLineWidth = lineWidth*1.5
        static let halfLineWidth = lineWidth / 2
    }
    
    /// Calculates the inner radius
    private var innerCircleRadius: CGFloat {
        return viewModel.radius - Constants.lineWidth
    }
    
    
    init(size: CGSize, viewModel: FillableCircleViewModel) {
        contentView = SKSpriteNode.init(texture: nil, color: .clear, size: size)
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(contentView)
        
        createView()
    }

    
    /// The CGPath that describes the shape that overlaps the bottom left quadrant of the circle
    private lazy var bottomLeftPath: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -viewModel.radius + Constants.halfLineWidth, y: 0.0))
        let endPoint = CGPoint(x: 0.0, y: -viewModel.radius + Constants.halfLineWidth)
        let midPoint = CGPoint(x: -viewModel.radius + Constants.halfLineWidth, y: -viewModel.radius + Constants.halfLineWidth)
        path.addQuadCurve(to: endPoint, control: midPoint)
        return path
    }()
    
    /// The CGPath that describes the shape that overlaps the bottom right quadrant of the circle
    private lazy var bottomRightPath: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: -viewModel.radius + Constants.halfLineWidth))
        let endPoint = CGPoint(x: viewModel.radius - Constants.halfLineWidth, y: 0.0)
        let midPoint = CGPoint(x: viewModel.radius - Constants.halfLineWidth, y: -viewModel.radius + Constants.halfLineWidth)
        path.addQuadCurve(to: endPoint, control: midPoint)
        return path
    }()
    
    
    /// The CGPath that describes the shape that overlaps the top right quadrant of the circle
    private lazy var topRightPath: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: viewModel.radius - Constants.halfLineWidth, y: 0.0))
        let endPoint = CGPoint(x: 0.0, y: viewModel.radius - Constants.halfLineWidth)
        let midPoint = CGPoint(x: viewModel.radius - Constants.halfLineWidth, y: viewModel.radius - Constants.halfLineWidth)
        path.addQuadCurve(to: endPoint, control: midPoint)
        return path
    }()
    
    /// The CGPath that describes the shape that overlaps the top left quadrant of the circle
    private lazy var topLeftPath: CGPath = {
        let path = CGMutablePath()
        let adjustedStartPoint = CGPoint(x: -10, y: viewModel.radius - Constants.halfLineWidth)
        path.move(to: adjustedStartPoint)
        let endPoint = CGPoint(x: -viewModel.radius + Constants.halfLineWidth, y: 0.0)
        let midPoint = CGPoint(x: -viewModel.radius + Constants.halfLineWidth, y: viewModel.radius - Constants.halfLineWidth)
        path.addQuadCurve(to: endPoint, control: midPoint)
        return path
    }()
    
    /// This is the shape that gets revealed and shows progress
    private lazy var outline: SKShapeNode = {
        let outline = SKShapeNode(circleOfRadius: viewModel.radius)
        outline.color = viewModel.fillColor
        let innerOutLine = SKShapeNode(circleOfRadius: innerCircleRadius)
        innerOutLine.color = viewModel.backgroundColor ?? . clear

        outline.addChildSafely(innerOutLine)

        return outline
    }()
    
    /// This is the semi-circle shape on the left half of the sprite.  It "crops" the path shape that reveals the outline
    private lazy var overLayOutline: SKShapeNode = {
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .pi/2, endAngle: .pi * 3/2, clockwise: false)
        let shape = SKShapeNode(path: path)
        shape.color = viewModel.fillColor
        shape.zPosition = Precedence.menu.rawValue
        
        let innerOutLine = SKShapeNode(circleOfRadius: innerCircleRadius)
        innerOutLine.color = viewModel.backgroundColor ?? . clear

        shape.addChildSafely(innerOutLine)
        
        return shape
    }()
    
    /// Create the shape the will cover fill bar.
    /// When the progress enters a new quarter of the circle, we remove the overlapping shape and add this shape instead.  This shape moves along the path of the circle and reveals the underlying progress bar.
    private func createOverlap(progress: CGFloat) -> CGPath {
        let path = CGMutablePath()
        
        // the line width actually makes it the center of the line is at a radius minus half the line width
        let adjustRadius = viewModel.radius - Constants.halfLineWidth
        
        /// we start at the top of the unit circle
        let adjustment = CGFloat.pi / 2
        
        /// calculate the circumference
        let circumference = .pi * adjustRadius * 2
        
        /// the distance from the top of the unit circle
        let arcLength = progress * circumference
        
        /// the angle from the top of the unit circle to our current position
        let radians = arcLength / adjustRadius + adjustment
        
        /// the x and y of our current position
        let x = adjustRadius * cos(radians)
        let y = adjustRadius * sin(radians)
        let startPoint = CGPoint(x: x, y: y)
        
        
        /// add a pretty circle
        addCircle(radius: Constants.halfLineWidth * 1.5, position: startPoint)
        
        /// move us to the start point before calculating the end point
        path.move(to: startPoint)
        
        /// determine the end point that is an extra 1/4 arc length away
        let endArcLength = arcLength + (1.05 * circumference / 4)
        let endRadians = endArcLength / adjustRadius + adjustment
        let endX = adjustRadius * cos(endRadians)
        let endY = adjustRadius * sin(endRadians)
        let endPoint = CGPoint(x: endX, y: endY)
        
        /// determine the mid point that is an extra 1/12 arc length away
        let midArcLength = arcLength + (circumference / 12)
        let midRadians = midArcLength / adjustRadius + adjustment
        let midX = adjustRadius * cos(midRadians) * 1.1
        let midY = adjustRadius * sin(midRadians) * 1.1
        let midPoint = CGPoint(x: midX, y: midY)
        
        /// determine the mid point that is an extra 1/6 arc length away
        let mid2ArcLength = arcLength + (circumference / 6)
        let mid2Radians = mid2ArcLength / adjustRadius + adjustment
        let mid2X = adjustRadius * cos(mid2Radians) * 1.1
        let mid2Y = adjustRadius * sin(mid2Radians) * 1.1
        let midPoint2 = CGPoint(x: mid2X, y: mid2Y)
        
        path.addCurve(to: endPoint, control1: midPoint, control2: midPoint2)
        
        return path
    }
    
    private func addCircle(radius: CGFloat, position: CGPoint, addCheckmark: Bool = false) {
        /// add a pretty circle
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = position
        circle.color = viewModel.darkFillColor
        circle.zPosition = Precedence.menu.rawValue
        
        if addCheckmark {
            let checkmark = SKSpriteNode(texture: SKTexture(imageNamed: "checkMark"), color: .clear, size: CGSize(width: Constants.lineWidth, height: Constants.lineWidth))
            checkmark.zPosition = 1
            circle.addChildSafely(checkmark)
        }
        
        addChildSafely(circle)
        return
    }
    
    private func createOverlap() {
        let progress = CGFloat(viewModel.progress) / CGFloat(viewModel.total)
        var paths: [CGPath]
        if progress < 0.25 {
            paths = [topRightPath, bottomRightPath, bottomLeftPath]
        } else if progress < 0.50 {
            paths = [bottomRightPath, topRightPath]
        } else if progress < 0.75 {
            paths = [topRightPath]
        } else if progress < 1.0 {
            paths = []
            addChildSafely(overLayOutline)
        } else {
            /// add a pretty circle
            addCircle(radius: Constants.halfLineWidth * 1.5,
                      position: CGPoint(x: 0.0, y: viewModel.radius - Constants.halfLineWidth),
                      addCheckmark: true)
            return
        }
        
        /// Append the shape that overlaps the curent progress
        paths.append(createOverlap(progress: progress))
        
        /// Create the shape nodes
        let shapes = paths.map { path -> SKNode in
            let shape = SKShapeNode(path: path)
            shape.color = viewModel.backgroundColor ?? .clayRed
            shape.lineWidth = Constants.overlapLineWidth
            return shape
        }
        
        /// add each shape to the content view
        shapes.forEach { contentView.addChildSafely($0) }
    }
    
    private func createView() {
        contentView.addChildSafely(outline)
        createOverlap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





