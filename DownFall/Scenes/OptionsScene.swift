//
//  OptionsScene.swift
//  DownFall
//
//  Created by Katz, Billy on 7/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

protocol OptionsSceneDelegate: class {
    func backSelected()
}

class OptionsScene: SKScene, ButtonDelegate {
    
    private var foreground: SKSpriteNode!
    weak var myDelegate: OptionsSceneDelegate?
    
    let originalSprite = SKSpriteNode(texture: SKTexture(imageNamed: "test-image-shader"), color: .clear, size: .init(width: 800.0, height: 800.0))

    var sprite = SKSpriteNode(texture: SKTexture(imageNamed: "test-image-shader"), color: .clear, size: .init(width: 800.0, height: 800.0))
    
    private lazy var resetDataButton: Button = {
        
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .resetData)
        return button
        
        
    }()
    
    private lazy var backButton: Button = {
        
        let button = Button(size: .buttonExtralarge,
                            delegate: self,
                            identifier: .back)
        return button
        
        
    }()
    
    override func didMove(to view: SKView) {
    
        let foreground = SKSpriteNode(color: .backgroundGray, size: self.size.playableRect.size)
        self.foreground = foreground
        addChildSafely(foreground)
        
        resetDataButton.position = .position(resetDataButton.frame, inside: foreground.frame, verticalAlign: .bottom, horizontalAnchor: .center)
        
        foreground.addChildSafely(resetDataButton)
        
        backButton.position = .position(backButton.frame, inside: foreground.frame, verticalAlign: .top, horizontalAnchor: .left, yOffset: .safeAreaHeight)
        
        
        foreground.addChildSafely(backButton)
        
        
        let redButton = Button(size: .buttonExtralarge, delegate: self, identifier: .increaseRed)
        let blueButton = Button(size: .buttonExtralarge, delegate: self, identifier: .increaseBlue)
        let greenButton = Button(size: .buttonExtralarge, delegate: self, identifier: .increaseGreen)
        let alphaButton = Button(size: .buttonExtralarge, delegate: self, identifier: .increaseAlpha)
        
        redButton.position = .position(redButton.frame, inside: foreground.frame, verticalAlign: .center, horizontalAnchor: .right)
        
        blueButton.position = .alignHorizontally(blueButton.frame, relativeTo: redButton.frame, horizontalAnchor: .right, verticalAlign: .bottom, translatedToBounds: true)
        
        greenButton.position = .alignHorizontally(greenButton.frame, relativeTo: blueButton.frame, horizontalAnchor: .right, verticalAlign: .bottom, translatedToBounds: true)
        
        alphaButton.position = .alignHorizontally(alphaButton.frame, relativeTo: greenButton.frame, horizontalAnchor: .right, verticalAlign: .bottom, translatedToBounds: true)
        
        foreground.addChildSafely(redButton)
        foreground.addChildSafely(blueButton)
        foreground.addChildSafely(greenButton)
        foreground.addChildSafely(alphaButton)
    }
    
    var currentRed: Float = 0.0
    var currentBlue: Float = 0.0
    var currentGreen: Float = 0.0
    var currentAlpha: Float = 0.0
    
    func increase(r: Float? = nil, g: Float? = nil, b: Float? = nil, a: Float? = nil) {
        let shader = SKShader(fileNamed: "TestShader.fsh")
        shader.uniforms = [
            SKUniform(name: "u_inputRed", float: r ?? currentRed),
            SKUniform(name: "u_inputBlue", float: b ?? currentBlue),
            SKUniform(name: "u_inputGreen", float: g ?? currentGreen),
            SKUniform(name: "u_inputAlpha", float: a ?? currentAlpha),
        ]
        currentRed = r ?? currentRed.truncatingRemainder(dividingBy: 256)
        currentBlue = b ?? currentBlue.truncatingRemainder(dividingBy: 256)
        currentGreen = g ?? currentGreen.truncatingRemainder(dividingBy: 256)
        currentAlpha = a ?? currentAlpha.truncatingRemainder(dividingBy: 256)
        
        sprite = originalSprite.copy() as! SKSpriteNode
        sprite.shader = shader
        
        sprite.removeFromParent()
        foreground.addChildSafely(sprite)
    }
    
    
    func buttonTapped(_ button: Button) {
        switch button.identifier {
        case .resetData:
            /// Order matters here
            GameScope.shared.profileManager.deleteLocalProfile()
            GameScope.shared.profileManager.deleteAllRemoteProfile()
            GameScope.shared.profileManager.resetUserDefaults()
        case .back:
            myDelegate?.backSelected()
        case .increaseRed:
            increase(r: 50.0)
        case .increaseAlpha:
            increase(a: 50.0)
        case .increaseGreen:
            increase(g: 50.0)
        case .increaseBlue:
            increase(b: 50.0)
        default:
            break
        }
    }
}
