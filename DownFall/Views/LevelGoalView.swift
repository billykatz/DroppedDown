//
//  LevelGoalView.swift
//  DownFall
//
//  Created by Katz, Billy on 4/6/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit
import Combine

class LevelGoalView: SKSpriteNode {
    
    struct Constants {
        static let keyView = "keyView"
        static let radius = CGFloat(50)
        static let barPadding: CGFloat = 25.0
        static let barSize: CGSize = CGSize(width: 225, height: 75)
    }
    
    private let fillableCircleCenter: CGPoint
    private let viewModel: LevelGoalTracker
    private let infoSprite: SKSpriteNode
    private var disposables = Set<AnyCancellable>()
    
    lazy var contentView: SKSpriteNode = {
        return SKSpriteNode(color: .clear, size: adjustedFrame.size)
    }()
    
    lazy var adjustedFrame: CGRect = {
        var frame = self.frame
        let frameOffset = self.frame.width*0.1
        frame = CGRect(origin: frame.origin.translate(xOffset: frameOffset, yOffset: 0.0), size: frame.size.scaleWidth(by: 0.9))
        return frame
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: LevelGoalTracker, size: CGSize) {
        self.viewModel = viewModel
        fillableCircleCenter = .zero
                
        let infoSprite = SKSpriteNode(texture: SKTexture(imageNamed: "info"), size: .fifty)
        self.infoSprite = infoSprite
        
        super.init(texture: nil, color: .clear, size: size)
        
        // position the info button sprite inside of here
        infoSprite.position = CGPoint.position(infoSprite.frame, inside: self.contentView.frame, verticalAlign: .top, horizontalAnchor: .left, xOffset: 25.0, yOffset: 25.0)
        
        addChild(contentView)
        addChild(infoSprite)
        // removing for test background purposes
//        addBorder()
        
        isUserInteractionEnabled = true
        
        bindToViewModel()
        
    }
    
    private func bindToViewModel() {
        
        viewModel
            .goalIsUpdated
            .sink { (completion) in
            } receiveValue: { [weak self] (goalTracking) in
                self?.updateGoal(goalTracking)
            }.store(in: &disposables)

        
        viewModel
            .goalCompleted
            .sink { (completion) in
                
            } receiveValue: { [weak self] (event) in
                let (goals) = event
                self?.completedGoal(goals)
            }
            .store(in: &disposables)

    }
    
    private func addBorder() {
        
        let border = SKShapeNode(rect: self.contentView.frame, cornerRadius: 15.0)
        border.fillColor = .clear
        border.strokeColor = .goldOutlineDull
        border.lineWidth = 5.0
        
        self.addChildSafely(border)
        
    }
        
    private func completedGoal(_ updatedGoals: [GoalTracking]) {
        for goal in updatedGoals {
            createFillableBar(for: goal, at: goal.index, orderCompleted: goal.orderCompleted)
        }

    }
    
    private func updateGoal(_ updatedGoals: [GoalTracking]) {
        contentView.removeAllChildren()
        createFillableBar(updatedGoals)
    }
    
    
    private func createFillableBar(_ updatedGoals: [GoalTracking]) {
        for (index, goalTrack) in updatedGoals.enumerated() {
            createFillableBar(for: goalTrack, at: index)
        }
    }
    
    private func createFillableBar(for updatedGoal: GoalTracking, at index: Int, orderCompleted: Int = 0) {
        let (lightFill, darkFill) = updatedGoal.fillBarColor
        let bar = FillableBar(size: Constants.barSize, viewModel: FillableBarViewModel(total: updatedGoal.target, progress: updatedGoal.current, fillColor: lightFill, backgroundColor: darkFill, text: "", direction: .leftToRight))
       
        // Position the bar relative to the content view and other bars
        bar.position = CGPoint.alignHorizontally(bar.frame, relativeTo: infoSprite.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding:  (CGFloat(index) * bar.size.height) + (Constants.barPadding) + (CGFloat(index) * Constants.barPadding), translatedToBounds: true)
        
        
        contentView.addChild(bar)
        if updatedGoal.isCompleted && updatedGoal.hasBeenRewarded {
            let mockCircle = SKSpriteNode(color: .clear, size: .fifty)
            bar.addCheckmark(radius: bar.frame.height/2.0*0.8, position: CGPoint.position(mockCircle.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .right))
            
            let sprite = SKSpriteNode(imageNamed: "Reward\(updatedGoal.orderCompleted)Border")
            sprite.size = bar.size
            sprite.position = CGPoint.position(sprite.frame, inside: bar.frame, verticalAlign: .center, horizontalAnchor: .center)
            
            bar.addChild(sprite)

        }
        
    }



}


extension LevelGoalView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        if self.contentView.contains(position) {
            viewModel.viewWasTapped()
        }
        
    }
}
