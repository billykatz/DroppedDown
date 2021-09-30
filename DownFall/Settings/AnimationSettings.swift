//
//  AnimationSettings.swift
//  DownFall
//
//  Created by William Katz on 5/17/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import CoreGraphics

struct AnimationSettings {
    static let rotateSpeed = 0.4
    static let fallSpeed = 0.2
    static let wiggleSpeed = 0.1
    
    struct RotatePreview {
        static let finishRotateSpeed = 0.07
        static let finishQuickRotateSpeed = 0.25
    }
    
    struct WinSprite {
        static let moveVector: CGVector = CGVector(dx: 0.0, dy: 20.0)
        static let shrinkCoefficient: CGFloat = 0.2
    }
    
    struct Store {
        static let itemFrameRate = Double(0.3)
    }
    
    struct Backpack {
        static let itemDetailMoveRate = Double(0.15)
    }
    
    struct Board {
        static let goldGainSpeedStart = Double(0.15)
        static let goldGainSpeedEnd = Double(0.65)
        static let runeGainSpeed = Double(1.0)
        static let goldWaitTime = Double(0.025)
        static let offerCollectDuration = Double(0.75)
        static let workingTowardsGoal = Double(0.66)
    }
    
    struct HUD {
        static let goldGainedTime = Double(2.0)
        static let gemCountFadeTime = Double(1.5)
    }
    
    struct Renderer {
        static let glowSpinSpeed = Double(2)
    }
    
    struct Gem {
        static let randomXOffsetRange: Range<CGFloat> = -100.0..<100.0
        static let randomYOffsetRange: Range<CGFloat> = -100.0..<100.0
    }
}
