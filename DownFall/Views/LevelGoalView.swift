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
        static let heightConstant = CGFloat(0.15)
        static let widthConstant = CGFloat(0.85)
    }
    
    let contentView: SKSpriteNode
    var viewModel: LevelGoalTracker?
    
    init(viewModel: LevelGoalTracker, playableRect: CGRect) {
        self.viewModel = viewModel
        self.contentView = SKSpriteNode(color: .clear, size: CGSize(width: playableRect.width*Constants.widthConstant, height: playableRect.height*Constants.heightConstant))
        
        super.init(texture: nil, color: .clear, size: .zero)
        
        addChild(contentView)
        
        createGoalView()
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createGoalView() {
        let view = SKSpriteNode(color: .clayRed, size: contentView.size)
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
    
    func updateGoal(type: TileType, goalTrack: GoalTracking) {
        contentView.removeAllChildren()
        createGoalView()
    }
}
