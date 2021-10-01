//
//  ParagraphNode.swift
//  DownFall
//
//  Created by William Katz on 11/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

//TODO: find what we used as a resource and credit it here

class ParagraphNode: SKSpriteNode {
    static let defaultFontName = "Alterebro-Pixel-Font"
    static let defaultFontColor = UIColor.white
    static let defaultFontSize: CGFloat = .fontExtraLargeSize
    
    var fontName: String
    var fontColor: UIColor
    var fontSize: CGFloat
    var text: String
    var paragraphWidth: CGFloat
    
    func fontName(newValue: String) {
        self.fontName = newValue
        retexture()
    }
    
    func fontColor(newValue: UIColor) {
        self.fontColor = newValue
        retexture()
    }

    func text(newValue: String) {
        self.text = newValue
        retexture()
    }
    
    func fontSize(newValue: CGFloat) {
        self.fontSize = newValue
        retexture()
    }
    
    func paragraphWidth(newValue: CGFloat) {
        self.paragraphWidth = newValue
        retexture()
    }
    
    init(text: String,
         paragraphWidth: CGFloat,
         fontName: String = ParagraphNode.defaultFontName,
         fontSize: CGFloat = ParagraphNode.defaultFontSize,
         fontColor: UIColor = ParagraphNode.defaultFontColor
         ) {
        self.fontName = fontName
        self.text = text
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.paragraphWidth = paragraphWidth - 2 * Style.paragraphPadding
        super.init(texture: nil, color: .clear, size: .zero)
        
        retexture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func labelNode(text: String,
                          paragraphWidth: CGFloat,
                          fontName: String = ParagraphNode.defaultFontName,
                          fontSize: CGFloat = ParagraphNode.defaultFontSize,
                          fontColor: UIColor = ParagraphNode.defaultFontColor
                          ) -> ParagraphNode {
        return ParagraphNode(
            text: text,
            paragraphWidth: paragraphWidth,
            fontName: fontName,
            fontSize: fontSize,
            fontColor: fontColor
        )
    }
    
    func retexture() {
        guard let image = imageFrom(text: self.text as NSString) else { return }
        let texture = SKTexture(image: image)
        self.texture = texture
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
    }
    
    lazy var customFont: UIFont = {
        guard let customFont = UIFont(name: "Alterebro-Pixel-Font", size: fontSize) else {
            fatalError("""
                Failed to load the "pixel-font" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return customFont

    }()
    
    func imageFrom(text: NSString) -> UIImage? {
        
        // paragraph styling
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.lineSpacing = 1;

        // attributes
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = customFont
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        attributes[NSAttributedString.Key.foregroundColor] = fontColor


        let size = CGSize(width: paragraphWidth, height: 2000.0)
        let textRect = text.boundingRect(with: size,
                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                         attributes: attributes,
                                         context: nil)
        
        //update out size
        self.size = textRect.size
        
        //draw the image
        UIGraphicsBeginImageContextWithOptions(textRect.size, false, 0.0)
        
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
}
