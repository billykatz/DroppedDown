//
//  LevelGoalView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/6/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

class LevelGoalView: SKSpriteNode {
    
    struct Constants {
        static let goalViewName = "goalView"
        static let radius = CGFloat(50)
    }
    
    let contentView: SKSpriteNode
    let fillableCircleCenter: CGPoint
    let viewModel: LevelGoalTracker
    
    init(viewModel: LevelGoalTracker, size: CGSize) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(color: .clear, size: size)
        fillableCircleCenter = CGPoint(x: contentView.frame.minX + (CGFloat(self.viewModel.numberOfExitGoals+2) * Constants.radius), y: 0.0)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(contentView)
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func goalView() -> SKSpriteNode{
        let exit = TileType.exit(blocked: viewModel.exitLocked)
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: exit.textureString()), color: .clear, size: CGSize(width: 100.0, height: 100.0))
        sprite.zPosition = 150
        sprite.position = fillableCircleCenter
        return sprite
    }
    
    func createFillableCircle(_ updatedGoals: [TileType: GoalTracking]) {
        for (type, goalTrack) in updatedGoals {
            let radius = Constants.radius + (CGFloat(goalTrack.index+1) * Constants.radius)
            let (lightFill, darkFill) = type.fillBarColor
            let viewModel = FillableCircleViewModel(radius: CGFloat(radius),
                                                    total: goalTrack.target,
                                                    progress: goalTrack.initial,
                                                    fillColor: lightFill,
                                                    darkFillColor: darkFill,
                                                    text: "",
                                                    backgroundColor: .backgroundGray)
            let fillableCircle = FillableCircleBar(size: size,
                                                   viewModel: viewModel)
            if goalTrack.index == 0 {
                fillableCircle.zPosition = 100
            } else if goalTrack.index == 1 {
                fillableCircle.zPosition = 0
            } else if goalTrack.index == 2 {
                fillableCircle.zPosition = -100
            }
            fillableCircle.position = fillableCircleCenter
            
            contentView.addChild(fillableCircle)
        }
    }
    
    func bindToViewModel() {
        viewModel.goalUpdated = updateGoal
    }
    
    func updateGoal(_ updatedGoals: [TileType: GoalTracking]) {
        contentView.removeAllChildren()
        contentView.addChildSafely(goalView())
        createFillableCircle(updatedGoals)
    }
}
