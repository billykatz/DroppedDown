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
        static let circleNamePrefix = "Circle-"
        static let keyView = "keyView"
        static let radius = CGFloat(50)
        static let barPadding: CGFloat = 25.0
        static let barSize: CGSize = CGSize(width: 225, height: 75)
        static let circleSize: CGSize = CGSize(width: 200, height: 200)
        static let goalImageSize: CGSize = CGSize(width: 50, height: 50)
        static let goalImageCompletedSize: CGSize = CGSize(width: 75, height: 75)
    }
    
    private let viewModel: LevelGoalTracker
    private var levelGoalViewModels: [FillableCircleViewModel] = []
    private var numberOfGoals: Int = 0
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
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(contentView)
        addBorder()
        
        isUserInteractionEnabled = true
        
        bindToViewModel()
        
    }
    
    private func bindToViewModel() {
        
        viewModel
            .goalIsUpdated
            .sink { (completion) in
            } receiveValue: { [weak self] (goalTracking) in
                self?.numberOfGoals = goalTracking.count
                
                for (index, updatedGoal) in goalTracking.enumerated() {
                    let (lightFill, darkFill) = updatedGoal.fillBarColor
                    if self?.levelGoalViewModels.optionalElement(at: index) != nil {
                        
                        let newVm = FillableCircleViewModel(radius: Constants.circleSize.width/2, total: updatedGoal.target, progress: updatedGoal.current, fillColor: lightFill, darkFillColor: darkFill, backgroundColor: .backgroundGray, direction: .downToUp)
                        
                        self?.levelGoalViewModels[index] = newVm
                        
                    } else {
                        // first time through
                        let vm = FillableCircleViewModel(radius: Constants.circleSize.width/2, total: updatedGoal.target, progress: updatedGoal.current, fillColor: lightFill, darkFillColor: darkFill, backgroundColor: .backgroundGray, direction: .downToUp)

                        self?.levelGoalViewModels.append(vm)
                    }
                    
                    self?.updateGoal(updatedGoal)
                }
                
            }.store(in: &disposables)

        
        viewModel
            .goalCompleted
            .sink { (completion) in
                
            } receiveValue: { [weak self] (event) in
                let (goals) = event
                for goal in goals {
                    self?.updateGoal(goal)
                }
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
    
    private func updateGoal(_ updatedGoal: GoalTracking) {
        /// remove the current bar
        contentView.removeChild(with: "\(Constants.circleNamePrefix)\(updatedGoal.index)")
        
        //prime the loop
        let circle = createFillableBar(for: updatedGoal, at: updatedGoal.index)
        contentView.addChildSafely(circle)
    }
    
    func xOffsetForGoal(widthOfItem: CGFloat, indexOfGoal: Int) -> CGFloat {
        let totalWidthMinusItemWidth = contentView.frame.width - (CGFloat(numberOfGoals) * widthOfItem)
        let offset = (CGFloat(indexOfGoal+1) * totalWidthMinusItemWidth / CGFloat(numberOfGoals + 1)) + (CGFloat(indexOfGoal) * widthOfItem)
        return offset
    }
    
    private func createFillableBar(for updatedGoal: GoalTracking, at index: Int) -> SKSpriteNode {
        guard let vm = levelGoalViewModels.optionalElement(at: index) else { return SKSpriteNode() }
        
        let circle = FillableCircleBar(size: Constants.circleSize, viewModel: vm)
       
        // Position the bar relative to the content view and other bars
        circle.position = CGPoint.position(circle.frame, inside: contentView.frame, verticalAlign: .center, horizontalAnchor: .left, xOffset: xOffsetForGoal(widthOfItem: Constants.circleSize.width, indexOfGoal: index), translatedToBounds: true)
        
        
        // Add the goal background, image, and current total needed views
        let goalBackgroundView = SKShapeNode(circleOfRadius: Constants.circleSize.width/2 - 20.0)
        goalBackgroundView.color = .black
        
        let goalImageView = SKSpriteNode(texture: SKTexture(imageNamed: updatedGoal.textureName()), size: (updatedGoal.isCompleted ? Constants.goalImageCompletedSize : Constants.goalImageSize))
        
        // dont add the current amount needed anymore
        // and dont adjust the goal image position
        if (!updatedGoal.isCompleted) {
            goalImageView.position = goalImageView.position.translateVertically(25)
            let currentTargetView = ParagraphNode(text: "\(updatedGoal.target - updatedGoal.current)", paragraphWidth: 200, fontSize: .fontLargeSize)
            currentTargetView.position = currentTargetView.position.translateVertically(-20)
            goalBackgroundView.addChild(currentTargetView)
        }
        
        goalBackgroundView.zPosition = 50000
        goalBackgroundView.addChild(goalImageView)
        
        circle.addChild(goalBackgroundView)
        circle.name = "\(Constants.circleNamePrefix)\(updatedGoal.index)"
        
        return circle
        
    }
    
    public func originForGoalView(index: Int) -> CGPoint {
        let x: CGFloat = -contentView.frame.width/2 + xOffsetForGoal(widthOfItem: Constants.circleSize.width, indexOfGoal: index) + Constants.circleSize.width/2
        let y: CGFloat = 0
        return CGPoint(x: x, y: y)
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
