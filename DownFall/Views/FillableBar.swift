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
    var horiztonal: Bool { get }
}

struct FillableBarViewModel: FillableBarViewModelable {
    
    var total: Int
    var progress: Int
    var fillColor: UIColor
    var backgroundColor: UIColor?
    var text: String?
    var horiztonal: Bool
}

class FillableBar: SKSpriteNode {
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
        
        if self.viewModel.horiztonal {
            // Subtract the line widths from the actual fill size height
            let height = contentView.frame.height - 2*Style.FillableBar.lineWidth
            
            // Determine how long the filled portion of the bar should be
            let widthRatio: CGFloat = CGFloat(viewModel.progress) / CGFloat(viewModel.total)
            let width = barOutline.frame.width * widthRatio - 3*Style.FillableBar.lineWidth
            
            let size = CGSize(width: width,
                              height: height)
            // create the shape
            var fill = SKShapeNode(rect: CGRect(origin: contentView.frame.origin, size: size), cornerRadius: Style.FillableBar.cornerRadius)
            
            // add the color
            fill.color = viewModel.fillColor
            
            // set the position
            fill.position = CGPoint(x: Style.FillableBar.lineWidth,
                                    y: Style.FillableBar.lineWidth)
            
            return fill
        } else {
            // Subtract the line widths from the actual fill size height
            let width = contentView.frame.width - 2*Style.FillableBar.lineWidth
            
            // Determine how long the filled portion of the bar should be
            let heightRatio: CGFloat = CGFloat(viewModel.progress) / CGFloat(viewModel.total)
            let height = barOutline.frame.height * heightRatio - 3*Style.FillableBar.lineWidth
            
            let size = CGSize(width: width,
                              height: height)
            // create the shape
            var fill = SKShapeNode(rect: CGRect(origin: contentView.frame.origin, size: size),
                                   cornerRadius: Style.FillableBar.cornerRadius)
            
            // add the color
            fill.color = viewModel.fillColor
            
            // set the position
            fill.position = CGPoint(x: Style.FillableBar.lineWidth,
                                    y: Style.FillableBar.lineWidth)
            
            return fill
        }
    }()
    
    private lazy var text: ParagraphNode = {
        let paragraph = ParagraphNode(text: viewModel.text ?? "", paragraphWidth: contentView.size.width, fontSize: UIFont.mediumSize, fontColor: .black)
        paragraph.position = .zero
        return paragraph
    }()
    
    init(size: CGSize, viewModel: FillableBarViewModelable) {
        contentView = SKSpriteNode.init(texture: nil, color: .clear, size: size)
        self.viewModel = viewModel
        super.init(texture: nil, color: .clear, size: size)
        
        setupDisplay()
    }
    
    func setupDisplay() {
        [barOutline, background, fill, text].forEach { self.addChildSafely($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
