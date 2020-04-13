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
    }
    
    let contentView: SKSpriteNode
    var viewModel: LevelGoalTracker?
    
    init(viewModel: LevelGoalTracker, size: CGSize) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(color: .clear, size: size)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(contentView)
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func goalView() -> SKSpriteNode{
        let exit = TileType.exit(blocked: viewModel?.exitLocked ?? true)
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: exit.textureString()), color: .clear, size: CGSize(width: 100.0, height: 100.0))
        sprite.zPosition = 150
        return sprite
    }
    
    func createFillableCircle(_ updatedGoals: [TileType: GoalTracking]) {
        for (type, goalTrack) in updatedGoals {
            let radius = 50 + ((goalTrack.index+1) * 50)
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
            contentView.addChild(fillableCircle)
        }
    }
    
    func createGoalView() {
        let view = SKSpriteNode(color: .foregroundBlue, size: contentView.size)
        view.name = Constants.goalViewName
        
        guard let goalTracker = viewModel?.goalProgress[.rock(.purple)] else { return }
        let text = "\(goalTracker.levelGoalType.rawValue)"
        let goalLabel = ParagraphNode(text: text, paragraphWidth: contentView.size.width)
        
        let goalProgressText = "\(goalTracker.initial) / \(goalTracker.target)"
        let goalProgressLabel = ParagraphNode(text: goalProgressText, paragraphWidth: contentView.size.width)
        
        goalProgressLabel.position = CGPoint.alignHorizontally(goalProgressLabel.frame, relativeTo: goalLabel.frame, horizontalAnchor: .center, verticalAlign: .bottom)
        
        view.addChild(goalLabel)
        view.addChild(goalProgressLabel)
        
        contentView.addChild(view)
    }
    
    func bindToViewModel() {
        viewModel?.goalUpdated = updateGoal
    }
    
    func updateGoal(_ updatedGoals: [TileType: GoalTracking]) {
        contentView.removeAllChildren()
        contentView.addChildSafely(goalView())
        createFillableCircle(updatedGoals)
    }
}
