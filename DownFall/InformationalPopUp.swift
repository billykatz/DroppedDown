//
//  InformationalPopUp.swift
//  DownFall
//
//  Created by William Katz on 9/20/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

//TODO: Turns this into a sprite node that lets the player/programmer reset or let them know that they have won and can play again on a bigger board???
protocol InformationalPopupDelegate

class InformationalPopup : SKNode {
    let backgroundColor = UIColor.black
    let opacity = 0.5
    
    func configure(width: Int,
                   height: Int,
                   message: String,
                   button: [String],
                   delegate: InformationalPopupDelegate) {
        
    }
    
    
}
