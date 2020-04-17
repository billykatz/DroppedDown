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
        static let keyView = "keyView"
        static let radius = CGFloat(50)
    }
    
    let contentView: SKSpriteNode
    let fillableCircleCenter: CGPoint
    let keyView: SKSpriteNode
    let viewModel: LevelGoalTracker
    var updatedGoals: [GoalTracking]?
    
    init(viewModel: LevelGoalTracker, size: CGSize) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(color: .clear, size: size)
        fillableCircleCenter = .zero//CGPoint(x: contentView.frame.minX + (CGFloat(self.viewModel.numberOfExitGoals+2) * Constants.radius), y: 0.0)
        
        keyView = SKSpriteNode(color: .clear, size: CGSize(width: 3*size.width/4, height: size.height))
        keyView.name = Constants.keyView
                
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(keyView)
        addChild(contentView)
        
        isUserInteractionEnabled = true
        
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
    
    func createFillableCircle(_ updatedGoals: [GoalTracking]) {
        for goalTrack in updatedGoals {
            let type = goalTrack.tileType
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
    
    func updateGoal(_ updatedGoals: [GoalTracking]) {
        contentView.removeAllChildren(exclude: [Constants.keyView])
        contentView.addChildSafely(goalView())
        createFillableCircle(updatedGoals)
        self.updatedGoals = updatedGoals
    }
}


extension LevelGoalView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let updatedGoals = updatedGoals else { return }
        let position = touch.location(in: self)
        if self.contentView.contains(position) {
            InputQueue.append(Input(.levelGoalDetail(updatedGoals)))
        }
        
    }
}
