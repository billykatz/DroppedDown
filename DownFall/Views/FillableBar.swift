//
//  FillableBar.swift
//  DownFall
//
//  Created by Katz, Billy on 4/11/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol FillableBarViewModelable {
    var total: Int { get }
    var progress: Int { get }
    var fillColor: UIColor { get }
    var text: String? { get }
    var backgroundColor: UIColor? { get }
    var direction: BarDirection { get }
}

enum BarDirection {
    case leftToRight
    case rightToLeft
    case upToDown
    case downToUp
}

struct FillableBarViewModel: FillableBarViewModelable {
    
    var total: Int
    var progress: Int
    var fillColor: UIColor
    var backgroundColor: UIColor?
    var text: String?
    var direction: BarDirection
}

class FillableBar: SKSpriteNode {
    
    struct Constants {
        static let fillBar = "fillBar"
    }
    
    let viewModel: FillableBarViewModelable
    let contentView: SKSpriteNode
    
    private lazy var barOutline: SKShapeNode = {
        var outline = SKShapeNode(rect: CGRect(origin: contentView.frame.origin, size: contentView.size), cornerRadius: Style.FillableBar.cornerRadius)
        outline.lineWidth = Style.FillableBar.lineWidth
        outline.strokeColor = .storeBlack
        outline.position = .zero
        return outline
    }()
    
    private lazy var background: SKShapeNode = {
        var background = SKShapeNode(rect: CGRect(origin: contentView.frame.origin, size: contentView.size), cornerRadius: Style.FillableBar.cornerRadius)
        background.fillColor = viewModel.backgroundColor ?? .clear
        background.strokeColor = .clear
        background.position = .zero
        return background
    }()

    private lazy var fill: SKShapeNode = {
        let width: CGFloat
        let height: CGFloat
        let fillRect: CGRect
        
        if viewModel.direction == .leftToRight || viewModel.direction == .rightToLeft   {
            // Subtract the line widths from the actual fill size height
            height = contentView.frame.height - 2*Style.FillableBar.lineWidth
            
            // Determine how long the filled portion of the bar should be
            let widthRatio: CGFloat = CGFloat(viewModel.progress) / CGFloat(viewModel.total)
            width = barOutline.frame.width * widthRatio - 3*Style.FillableBar.lineWidth
        } else {
            // Subtract the line widths from the actual fill size height
            width = contentView.frame.width - 2*Style.FillableBar.lineWidth
            
            // Determine how long the filled portion of the bar should be
            let heightRatio: CGFloat = CGFloat(viewModel.progress) / CGFloat(viewModel.total)
            height = barOutline.frame.height * heightRatio - 3*Style.FillableBar.lineWidth
        }
        
        
        /// determine the size of the fill
        let size = CGSize(width: width,
                          height: height)
        
        if viewModel.direction == .leftToRight || viewModel.direction == .downToUp {
            fillRect = CGRect(origin: contentView.frame.origin, size: size)
        } else {
            let progress = 1.0 - (CGFloat(viewModel.progress) / CGFloat(viewModel.total))
            if viewModel.direction == .rightToLeft {
                let difference = progress * barOutline.frame.width
                fillRect = CGRect(origin: CGPoint(x: contentView.frame.origin.x + difference, y: contentView.frame.origin.y), size: size)
            } else {
                // up to down
                let difference = progress * barOutline.frame.height
                fillRect = CGRect(origin: CGPoint(x: contentView.frame.origin.x, y: contentView.frame.origin.y + difference), size: size)
            }
        }
        
        // create the shape
        var fill = SKShapeNode(rect: fillRect,
                               cornerRadius: Style.FillableBar.cornerRadius)
        
        // add the color
        fill.color = viewModel.fillColor
        
        // set the position
        fill.position = CGPoint(x: Style.FillableBar.lineWidth,
                                y: Style.FillableBar.lineWidth)
        
        // give a name so that we can flash later on
        fill.name = Constants.fillBar
        
        return fill
    }()
    
    private lazy var text: ParagraphNode = {
        let paragraph = ParagraphNode(text: viewModel.text ?? "", paragraphWidth: contentView.size.width, fontSize: .fontMediumSize, fontColor: .black)
        paragraph.position = .zero
        return paragraph
    }()
    
    init(size: CGSize, viewModel: FillableBarViewModelable) {
        contentView = SKSpriteNode(texture: nil, color: .clear, size: size)
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupDisplay()
    }
    
    func setupDisplay() {
        [barOutline, background, fill, text].forEach { self.addChildSafely($0) }
    }
    
    func flash() {
        guard let node = self.childNode(withName: Constants.fillBar) as? SKShapeNode else { return }
        
        let background = viewModel.backgroundColor
        let blinkOff = SKAction.run {
            node.color = background ?? .clear
        }
        
        
        let originalFillColor = viewModel.fillColor
        let originalColorAction = SKAction.run {
            node.color = originalFillColor
        }
        
        let wait = SKAction.wait(forDuration: 0.1)
        let longerWait = SKAction.wait(forDuration: 0.3)
        
        node.run(SKAction.sequence([blinkOff, wait,
                                    originalColorAction, longerWait,
                                    blinkOff, wait,
                                    originalColorAction, longerWait,
                                    blinkOff, wait,
                                    originalColorAction]))
        
    }
    
    func addCheckmark(radius: CGFloat, position: CGPoint) {
        let checkmark = SKSpriteNode(texture: SKTexture(imageNamed: "checkMark"), color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        checkmark.zPosition = Precedence.menu.rawValue
        checkmark.position = position
        addChildSafely(checkmark)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
