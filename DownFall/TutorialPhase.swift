//
//  TutorialPhase.swift
//  DownFall
//
//  Created by Billy on 10/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation



struct TutorialPhase: Hashable, Codable {
    let shouldShowHud: Bool
    let shouldShowLevelGoals: Bool
    let shouldShowLevelGoalDetailView: Bool
    let shouldShowTileDetailView: Bool
    let shouldInputLevelGoalView: Bool
    let shouldSpawnMonsters: Bool
    let shouldSpawnTileWithGem: Bool
    
    let dialogue: Dialogue
    
    let highlightTileType: [TileType]?
    
    let waitDuration: Double
    let fadeInDuration: Double
    
    let shouldDimScreen: Bool
    let shouldHighlightLevelGoalsInHUD: Bool
    let shouldShowRotateFinger: Bool
}

extension TutorialPhase {
    
    static let thisIsYou: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: false, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .thisIsYou, highlightTileType: [.player(.zero)], waitDuration: 1.0, fadeInDuration: 0.5, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let thisIsTheExit: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: false, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .thisIsTheExit, highlightTileType: [.exit(blocked: true)], waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    
    static let theseAreLevelGoals: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: false, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .theseAreLevelGoals, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let theseAreLevelGoalsInTheHud: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .theseAreLevelGoalsInHUD, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: true, shouldShowRotateFinger: false)
    
    static let okayReadyToMineSomeRocks: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .okayReadyToMineSomeRocks, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let youCanRotate: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: true, shouldSpawnTileWithGem: false, dialogue: .youCanRotate, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: true)
    
    static let yikesAMonster: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yikesAMonster, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let killAMonster: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .killAMonster, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let yayMonsterDead1GoalCompleted: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yayMonsterDead1GoalCompleted, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let yayMonsterDead2GoalCompleted: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yayMonsterDead2GoalCompleted, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)

    
    static let levelGoalRewards: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .levelGoalRewards, highlightTileType: [.exit(blocked: false), .offer(StoreOffer.offer(type: .dodge(amount: 5), tier: 1)), .offer(StoreOffer.offer(type: .luck(amount: 5), tier: 1))], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)
    
    static let youCanLeaveNow: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .youCanLeaveNow, highlightTileType: [.exit(blocked: false)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false, shouldShowRotateFinger: false)


    
}
