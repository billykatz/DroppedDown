//
//  GameMusicManager.swift
//  DownFall
//
//  Created by Billy on 3/17/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import AVKit


class GameMusicManager {
    
    let gameMusicThread = DispatchQueue(label: "GameMusicManager.gameMusicThread", qos: .userInitiated)
    
    let menuMusicManager: MenuMusicManager
    let levelMusicManager: LevelAudioManager
    
    var isBossLevel: Bool = false
    var isInMainMenu: Bool = true {
        didSet {
            decideToPlay(isMuted: isMuted, fromTappingUnmute: false, fromStartingLevel: false)
        }
    }
    
    
    private var isMuted: Bool = UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey)
    private var observer: NSKeyValueObservation?
    
    init() {
        
        self.menuMusicManager = MenuMusicManager()
        self.levelMusicManager = LevelAudioManager()
        
        
        gameMusicThread.async { [weak self] in
            self?.observer = UserDefaults.standard.observe(\.muteMusic, options: [.new], changeHandler: { [weak self] (defaults, change) in
                let isMuted = change.newValue ?? true
                self?.decideToPlay(isMuted: isMuted, fromTappingUnmute: true, fromStartingLevel: false)
            })
        }
        
        UserDefaults.standard.set(AVAudioSession.sharedInstance().isOtherAudioPlaying, forKey: UserDefaults.muteMusicKey)
        
    }
    
    deinit {
        self.observer?.invalidate()
        
    }
    
    private func decideToPlay(isMuted: Bool, fromTappingUnmute: Bool, fromStartingLevel: Bool) {
        self.isMuted = isMuted
        
        gameMusicThread.async { [isInMainMenu, menuMusicManager, levelMusicManager] in
            if isMuted {
                // is something else playing?
                if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                    if isInMainMenu {
                        menuMusicManager.stopBackgroundMusic()
                    } else {
                        levelMusicManager.stopBackgroundMusic()
                    }
                }
            } else {
                if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                    if isInMainMenu {
                        menuMusicManager.playBackgroundMusic()
                    } else {
                        menuMusicManager.stopBackgroundMusic()
                    }
                    
                    if fromStartingLevel {
                        levelMusicManager.playBackgroundMusic()
                    }
                } else {
                    if fromTappingUnmute {
                        if isInMainMenu {
                            menuMusicManager.playBackgroundMusic()
                        } else {
                            levelMusicManager.playBackgroundMusic()
                        }
                    }
                }
            }
        }
    }

    
    func register() {
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input.type)
            
        }
    }
    
    func handleInput(_ inputType: InputType) {
        
        switch inputType {
        case .boardBuilt, .boardLoaded:
            levelMusicManager.isBossLevel = self.isBossLevel
            decideToPlay(isMuted: isMuted, fromTappingUnmute: false, fromStartingLevel: true)
            
        case .gameLose, .gameWin, .playAgain:
            if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                levelMusicManager.stopBackgroundMusic()
            }
            
        default:
            ()
            
        }
    }
    
    
}
