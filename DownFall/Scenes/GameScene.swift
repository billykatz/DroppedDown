//
//  GameScene.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import UIKit
import GameplayKit
import Foundation

protocol GameSceneCoordinatingDelegate: AnyObject {
    func navigateToMainMenu(_ scene: SKScene, playerData: EntityModel)
    func finishRunAfterGameLost(playerData: EntityModel)
    func goToNextArea(updatedPlayerData: EntityModel)
    func saveState()
}


class GameScene: SKScene {
    
    struct Constants {
        static let swipeDistanceThreshold = CGFloat(25.0)
        static let quickSwipeDistanceThreshold = CGFloat(75.0)
        
        static let tag = String(describing: GameScene.self)
    }
    // only strong reference to the Board
    private var board: Board?
    
    // the board size
    private var boardSize: Int!
    
    //foreground
    private(set) var foreground: SKNode!
    
    // delegate
    weak var gameSceneDelegate: GameSceneCoordinatingDelegate?
    
    //renderer
    private var renderer: Renderer?
    
    //Generator
    private var generator: HapticGenerator = HapticGenerator.shared
    
    //swipe recognizer view
    private var swipeRecognizerView: SwipeRecognizerView?
    
    //level
    private var level: Level?
    private var levelGoalTracker: LevelGoalTracker?
    
    // stat tracker
    private var runStatTracker: RunStatTracker?
    
    // audio listener
    private var audioListener: AudioEventListener?
    
    // tutorial
    private var tutorialConductor: TutorialConductor?
    
    // boss controller
    private var bossController: BossController?
    
    //touch state
    private var touchWasSwipe = false
    private var touchWasCanceled = false
    private var lastPosition: CGPoint?
    private var swipeDirection: SwipeDirection?
    
    // rotate preview
    private var rotatePreview: RotatePreviewView?
    
    // referee
    private var referee: Referee?
    
    // profile view model
    private var profileViewModel: ProfileViewModel?
    
    private var numberOfPreviousBossWins: Int = 0
    
    #if DEBUG
    // screenshot helper
    private var screenshotHelper: ScreenshotHelper?
    #endif
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Creates an instance of board and does preparation neccessary for didMove(to:) to be called
    public func commonInit(boardSize: Int,
                           entities: EntitiesModel,
                           difficulty: Difficulty = .normal,
                           updatedEntity: EntityModel,
                           level: Level,
                           randomSource: GKLinearCongruentialRandomSource?,
                           stats: [Statistics],
                           loadedTiles: [[Tile]]? = [],
                           tutorialConductor: TutorialConductor,
                           profileViewModel: ProfileViewModel?,
                           numberOfPreviousBossWins: Int
    ) {
        self.profileViewModel = profileViewModel
        
        // create the tutorial conductor
        self.tutorialConductor = tutorialConductor
        
        // init our level
        self.level = level
        level.startLevel(playerData: updatedEntity, isTutorial: tutorialConductor.isTutorial)
        
        
        //create the foreground node
        foreground = SKNode()
        foreground.position = .zero
        addChild(foreground)
        
        
        self.levelGoalTracker = LevelGoalTracker(level: level, tutorialConductor: tutorialConductor)
        self.runStatTracker = RunStatTracker(runStats: stats, level: level)
        self.numberOfPreviousBossWins = numberOfPreviousBossWins
        
        
        //init our tile creator
        let tileCreator = TileCreator(entities,
                                      difficulty: difficulty,
                                      updatedEntity: updatedEntity,
                                      level: level,
                                      randomSource: randomSource ?? GKLinearCongruentialRandomSource(),
                                      loadedTiles: loadedTiles,
                                      tutorialConductor: tutorialConductor)
        
        //board
        board = Board.build(tileCreator: tileCreator, difficulty: difficulty, level: level, tutorialConductor: tutorialConductor)
        self.boardSize = boardSize
        
        // create the audio listener
        let audioManager = AudioManager(sceneNode: foreground, isBossLevel: level.isBossLevel)
        audioListener = AudioEventListener(audioManager: audioManager)
        
        // start the tutorial conductor
        tutorialConductor.startHandlingInput()
        
        // create the bossController
        bossController = BossController(level: level)
        
        // referee
        referee = Referee.shared
        
        if bossController?.isBossLevel ?? false {
            referee?.setWinRule(BossWin())
        } else {
            referee?.setWinRule(NonBossWin())
        }
        
        
    }
    
    override func didMove(to view: SKView) {
        
        isAccessibilityElement = false
        
        // preview view
        self.rotatePreview = RotatePreviewView()
        
#if DEBUG
        // screen shot helper
        if UITestRunningChecker.shared.testsAreRunning {
            self.screenshotHelper = ScreenshotHelper(rotatePreview: rotatePreview, foreground: foreground, playableRect: size.playableRect)
        }
#endif
    
        // create the renderer
        self.renderer = Renderer(playableRect: size.playableRect,
                                 foreground: foreground,
                                 boardSize: boardSize,
                                 precedence: Precedence.foreground,
                                 level: level!,
                                 levelGoalTracker: levelGoalTracker!,
                                 tutorialConductor: tutorialConductor,
                                 runStatTracker: runStatTracker!,
                                 numberOfPreviousBossWins:  numberOfPreviousBossWins,
                                 scene: self)
        
        
        // Register for inputs we care about
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input: input)
        }

        //Turn watcher
        TurnWatcher.shared.register()
        // create haptic generator
        generator.register()
        
    }
    
    func handleInput(input: Input) {
        if case InputType.playAgain = input.type {
            guard let board = self.board,
            let playerIndex = tileIndices(of: .player(.zero), in: board.tiles).first
            else { return }
            
            // sets the tutorial flag if the player skips the tutorial from the pause menu
            self.tutorialConductor?.setTutorialSkipped()
            
            self.foreground.removeAllChildren()
            if case let TileType.player(data) = board.tiles[playerIndex].type {
                self.removeFromParent()
                self.swipeRecognizerView?.removeFromSuperview()
                self.gameSceneDelegate?.navigateToMainMenu(self, playerData: data)
            }
        } else if case InputType.visitStore = input.type {
            
            guard let board = self.board,
                  let playerIndex = tileIndices(of: .player(.zero), in: board.tiles).first,
                case let TileType.player(data) = board.tiles[playerIndex].type else { return }
            self.foreground.removeAllChildren()
            self.removeFromParent()
            self.swipeRecognizerView?.removeFromSuperview()
            
            self.gameSceneDelegate?.goToNextArea(updatedPlayerData: data)
        
        } else if case InputType.gameWin(_) = input.type {
            // this is to save the state at the end of the level.
            self.gameSceneDelegate?.saveState()
            
            self.tutorialConductor?.setTutorialCompleted(playerDied: false)
            
            guard let board = self.board,
                  let playerIndex = tileIndices(of: .player(.zero), in: board.tiles).first,
                case let TileType.player(data) = board.tiles[playerIndex].type else { return }

            
            // request the palyer's review if they just finish level 2 or 3 and they have a rune
            if profileViewModel?.canShowReviewRequest() ?? false,
               (level?.depth ?? 0) == 2,
               !(data.pickaxe?.runes.isEmpty ?? true)
            {
                AppStoreReviewManager.requestReviewIfAppropriate()
            }
            // some lower skilled players might take longer to get there, but I still want them to review after 25 games
            else if profileViewModel?.canShowReviewRequestLongTimePlayer() ?? false,
                      (level?.depth ?? 0) > 0 {
                AppStoreReviewManager.requestReviewIfAppropriate()
            }
        } else if case InputType.gameLose = input.type {
            
            self.tutorialConductor?.setTutorialCompleted(playerDied: true)
            
            // set this so the player sees the FTUE for dying
            UserDefaults.standard.setValue(true, forKey: UserDefaults.shouldSeeDiedForTheFirstTimeKey)
            
            // finish up the run
            guard let board = self.board,
                  let playerIndex = tileIndices(of: .player(.zero), in: board.tiles).first,
                case let TileType.player(data) = board.tiles[playerIndex].type else { return }
            gameSceneDelegate?.finishRunAfterGameLost(playerData: data)
            
        } else if case InputType.transformation(let trans) = input.type {
            if let offers = trans.first?.offers {
                profileViewModel?.updateUnlockablesHaveSpawned(offers: offers)
            }
        }
    }
    
    public func prepareForReuse() {
        board = nil
        renderer = nil
        foreground = nil
        gameSceneDelegate = nil
//        generator = nil
        rotatePreview = nil
        audioListener = nil
        runStatTracker = nil
        bossController = nil
        swipeRecognizerView?.removeFromSuperview()
        InputQueue.reset()
        Dispatch.shared.reset()
        print("deiniting")
    }
    
    // public function that exposes all the data necessary to save the exact game state
    public func saveAllState() -> (EntityModel, [GoalTracking], [[Tile]], [Statistics], BossPhase)? {
        guard let board = self.board,
              let playerIndex = tileIndices(of: .player(.zero), in: board.tiles).first,
              case let TileType.player(data) = board.tiles[playerIndex].type,
              let levelGoalTracking = self.levelGoalTracker?.goalProgress,
              let stats = self.runStatTracker?.runStats,
              let bossPhase = bossController?.phase
              else {
            GameLogger.shared.log(prefix: Constants.tag, message: "Failure to gather all information to save the game")
            return nil
        }
        
        return (data, levelGoalTracking, board.tiles, stats, bossPhase)
    }
}

//MARK: Touch and Swiping logic
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchWasSwipe = false
        self.renderer?.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // avoid inputing touchEnded when a touch is cancelled.
        touchWasCanceled = true
        touchWasSwipe = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self.foreground)
        
        // set the lastPosition once until we have detected a touch
        if lastPosition == nil {
            lastPosition = currentPosition
        }
        
        
        guard let lastPosition = lastPosition,
              (
                abs(currentPosition.x - lastPosition.x) > Constants.swipeDistanceThreshold
                ||
                abs(currentPosition.y - lastPosition.y) > Constants.swipeDistanceThreshold
                ||
                touchWasSwipe
              ) else {
            touchWasSwipe = false
            return
        }
        
        touchWasSwipe = true
        
        //determine if the swipe was fast
        let preview = abs(currentPosition.y - lastPosition.y) > Constants.quickSwipeDistanceThreshold ? false : true
        
    
//        print("Preview?: \(preview) - \(abs(currentPosition.y - lastPosition.y))")
        
        // deteremine the vector of the swipe
        let vector = currentPosition - lastPosition
        
        // set the swipe for the duration of this swipe gesture
        let touchIsOnRight = (view?.isOnRight(currentPosition) ?? false)
        let touchIsOnTop = (view?.isOnTop(currentPosition) ?? false)
        
        if self.swipeDirection == nil {
            let swipeDirection = SwipeDirection(from: vector)
            
            /// finally set the swipeDirection
            self.swipeDirection = swipeDirection
            
            /// deteremine which clock rotation to apply
            let rotateDir = RotateDirection(from: swipeDirection, isOnRight: touchIsOnRight, isOnTop: touchIsOnTop)
            
            /// call functions that send rotate input
            switch rotateDir {
            case .clockwise:
                rotateClockwise(preview: preview)
            case .counterClockwise:
                rotateCounterClockwise(preview: preview)
            }
        }
        
        /// update the preview view
        if touchWasSwipe {
            guard let swipeDirection = swipeDirection else { return }
            var distance: CGFloat
            switch swipeDirection {
            case .up:
                let dx = touchIsOnRight ? -vector.dx : vector.dx
                distance = vector.dy + dx
                distance *= (touchIsOnRight ? 1 : -1)
            case .down:
                let dx = touchIsOnRight ? vector.dx : -vector.dx
                distance = vector.dy + dx
                distance *= (touchIsOnRight ? 1 : -1)
            case .left:
                let dy = touchIsOnTop ? vector.dy : -vector.dy
                distance = vector.dx + dy
                distance *= (touchIsOnTop ? -1 : 1)
            case .right:
                let dy = touchIsOnTop ? -vector.dy : vector.dy
                distance = vector.dx + dy
                distance *= (touchIsOnTop ? -1 : 1)
            }
            self.rotatePreview?.touchesMoved(distance: distance)
        }
        
        // set the last position for the next update
        self.lastPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            self.renderer?.touchesEnded(touches, with: event)
            self.lastPosition = nil
            self.swipeDirection = nil
            self.touchWasSwipe = false
        }

        // Note: it is ok to send ever tough end even to the Rotate Preview View.  It only sends input if we are expecting a rotate preview finish.
        self.rotatePreview?.touchesEnded()
        
        if touchWasCanceled && !touchWasSwipe {
            touchWasCanceled = false
        }
    }
}

//MARK: - Rotate
extension GameScene {
    private func rotateClockwise(preview: Bool) {
        InputQueue.append(Input(.rotateClockwise(preview: preview)))
    }
    private func rotateCounterClockwise(preview: Bool) {
        InputQueue.append(Input(.rotateCounterClockwise(preview: preview)))
    }
}

// MARK: - Update

extension GameScene {
    /// We try to digest the top of the queue every frame
    override func update(_ currentTime: TimeInterval) {
        guard let input = InputQueue.pop() else { return }
        print("Sending input \(input.type)")
        Dispatch.shared.send(input)
    }
}
