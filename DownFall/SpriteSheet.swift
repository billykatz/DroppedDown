//
//  SpriteSheet.swift
//  DownFall
//
//  Created by William Katz on 6/13/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class SpriteSheet {
    let texture: SKTexture
    let rows: Int
    let columns: Int
    var margin: CGFloat = 0
    var spacing: CGFloat = 0
    var frameSize: CGSize {
        let width = (texture.size().width-(margin*2+spacing*CGFloat(columns-1)))/CGFloat(columns)
        let height = (texture.size().height-(margin*2+spacing*CGFloat(rows-1)))/CGFloat(rows)
        return CGSize(width: width,
                      height: height)
    }
    
    init(texture: SKTexture,
         rows: Int,
         columns: Int,
         spacing: CGFloat,
         margin: CGFloat) {
        self.texture = texture
        self.rows = rows
        self.columns = columns
        self.spacing = spacing
        self.margin = margin
        
    }
    
    convenience init(texture: SKTexture, rows: Int, columns: Int) {
        self.init(texture: texture, rows: rows, columns: columns, spacing: 0, margin: 0)
    }
    
    func textureForColumn(column: Int, row: Int)->SKTexture? {
        if !(0...self.rows ~= row && 0...self.columns ~= column) {
            //location is out of bounds
            return nil
        }
        
        var textureRect = CGRect(x: margin+CGFloat(column)*(frameSize.width+spacing)-spacing,
                                 y: margin+CGFloat(row)*(frameSize.height+spacing)-spacing,
                                 width: frameSize.width,
                                 height: frameSize.height)
        
        textureRect = CGRect(x: textureRect.origin.x/texture.size().width,
                             y: textureRect.origin.y/texture.size().height,
                             width: textureRect.size.width/texture.size().width,
                             height: textureRect.size.height/texture.size().height)
        return SKTexture(rect: textureRect, in: texture)
    }
    
    func animationsFrames() -> [SKTexture] {
        var textures: [SKTexture] = []
        for col in 0..<columns {
            guard let texture = textureForColumn(column: col, row: 0) else { continue }
            textures.append(texture)
        }
        return textures
    }
    
}

