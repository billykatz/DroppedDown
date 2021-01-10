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
    }
    
    let fillableCircleCenter: CGPoint
    let viewModel: LevelGoalTracker
    var updatedGoals: [GoalTracking]?
    let infoSprite: SKSpriteNode
    
    lazy var contentView: SKSpriteNode = {
        return SKSpriteNode(color: .clear, size: adjustedFrame.size)
    }()
    
    lazy var adjustedFrame: CGRect = {
        var frame = self.frame
        let frameOffset = self.frame.width*0.1
        frame = CGRect(origin: frame.origin.translate(xOffset: frameOffset, yOffset: 0.0), size: frame.size.scaleWidth(by: 0.9))
        return frame
    }()
    
    /// The dispose bag
    private var disposables = Set<AnyCancellable>()
    
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
        addBorder()
        
        isUserInteractionEnabled = true
        
        bindToViewModel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let barPadding: CGFloat = 25.0
    private lazy var barSize: CGSize = CGSize(width: 225, height: 75)
    
    private func addBorder() {
        
        let border = SKShapeNode(rect: self.contentView.frame, cornerRadius: 15.0)
        border.fillColor = .clear
        border.strokeColor = .goldOutlineDull
        border.lineWidth = 5.0
        
        self.addChildSafely(border)
        
    }
    
    private func createFillableBar(_ updatedGoals: [GoalTracking]) {
        for (index, goalTrack) in updatedGoals.enumerated() {
            createFillableCircle(for: goalTrack, at: index)
        }
    }
    
    private func createFillableCircle(for updatedGoal: GoalTracking, at index: Int, flash: Bool = false) {
        let (lightFill, darkFill) = updatedGoal.fillBarColor
        let bar = FillableBar(size: barSize, viewModel: FillableBarViewModel(total: updatedGoal.target, progress: updatedGoal.current, fillColor: lightFill, backgroundColor: darkFill, text: "", direction: .leftToRight))
       
        // Position the bar relative to the content view and other bars
        bar.position = CGPoint.alignHorizontally(bar.frame, relativeTo: infoSprite.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding:  (CGFloat(index) * bar.size.height) + (barPadding) + (CGFloat(index) * barPadding), translatedToBounds: true)
        
        
        contentView.addChild(bar)
        if flash || updatedGoal.isCompleted {
            let mockCircle = SKSpriteNode(color: .clear, size: .fifty)
            bar.addCheckmark(radius: bar.frame.height/2.0*0.8, position: CGPoint.position(mockCircle.frame, inside: self.frame, verticalAlign: .center, horizontalAnchor: .right))
        }
        
    }


    private func bindToViewModel() {
        viewModel.goalUpdated = { [weak self] updatedGoals in self?.updateGoal(updatedGoals) }
        
        viewModel
            .goalCompleted
            .sink { (completion) in
                
            } receiveValue: { [weak self] (goals) in
                self?.completedGoal(goals)
            }
            .store(in: &disposables)

    }
    
    private func completedGoal(_ updatedGoals: [GoalTracking]) {
        for (index, goal) in updatedGoals.enumerated() {
            let computedIndex = self.updatedGoals?.firstIndex(of: goal) ?? index
            createFillableCircle(for: goal, at: computedIndex, flash: true)
        }

    }
    
    private func updateGoal(_ updatedGoals: [GoalTracking]) {
        contentView.removeAllChildren()
        createFillableBar(updatedGoals)
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
