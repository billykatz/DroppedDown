//
//  SwipeRecognizerView.swift
//  DownFall
//
//  Created by William Katz on 11/6/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class SwipeRecognizerView: SKView {
    
    init(frame: CGRect,
         target: Any,
         swiped: Selector)
    
    {
        super.init(frame: frame)
        
        let swipeUpGestureReconizer = UISwipeGestureRecognizer(target: target, action: swiped)
        swipeUpGestureReconizer.direction = .up
        
        self.addGestureRecognizer(swipeUpGestureReconizer)
        
        let swipeDownGestureReconizer = UISwipeGestureRecognizer(target: target, action: swiped)
        swipeDownGestureReconizer.direction = .down
        self.addGestureRecognizer(swipeDownGestureReconizer)
        
        let swipeLeftGestureReconizer = UISwipeGestureRecognizer(target: target, action: swiped)
        swipeLeftGestureReconizer.direction = .left
        self.addGestureRecognizer(swipeLeftGestureReconizer)
        
        let swipeRightGestureReconizer = UISwipeGestureRecognizer(target: target, action: swiped)
        swipeRightGestureReconizer.direction = .right
        self.addGestureRecognizer(swipeRightGestureReconizer)

        self.alpha = 0.05
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
