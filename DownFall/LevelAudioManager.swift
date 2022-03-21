//
//  AudioManager.swift
//  DownFall
//
//  Created by Katz, Billy on 1/10/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

extension UserDefaults {
    @objc dynamic var muteMusic: Bool {
        return bool(forKey: UserDefaults.muteMusicKey)
    }
}

enum Sound: CaseIterable {
    case pickaxe
    case mineRocks
    case collectGem
    case gemAppears
    case goalCompleted
    case playerHitsEnemy
    case enemyHitsPlayer
    case exitUnblocked
    case levelComplete
    case gameLose
    
    var filename: String {
        switch self {
        case .pickaxe:
            return "pickaxe.mp3"
        case .mineRocks:
            return "mineRocks.wav"
        case .collectGem:
            return "collectGem.mp3"
        case .gemAppears:
            return "gemAppears.mp3"
        case .goalCompleted:
            return "goalCompleted.mp3"
        case .playerHitsEnemy:
            return "playerHitsEnemy.mp3"
        case .enemyHitsPlayer:
            return "enemyHitsPlayer.mp3"
        case .exitUnblocked:
            return "exitUnblocked.mp3"
        case .levelComplete:
            return "levelComplete.mp3"
        case .gameLose:
            return "gameLose.mp3"
        }
    }
}


class LevelAudioManager {
    
    let audioThread = DispatchQueue(label: "audioThread", qos: .userInitiated)
    let backgroundMusicThread = DispatchQueue(label: "musicThread", qos: .userInitiated)
    
    let musicVolume: Float = 0.5
    var fadeInDuration: Float = 2.5
    
    var isBossLevel: Bool = false
    var _backgroundMusicPlayer: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer? {
        if let musicPlayer = _backgroundMusicPlayer {
            return musicPlayer
        } else {
            do {
                if isBossLevel {
                    if let backgroundMusicPath = Bundle.main.path(forResource: "shift-shaft-boss-loop", ofType: "m4a") {
                        let url = URL(fileURLWithPath: backgroundMusicPath)
                        self._backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                        self._backgroundMusicPlayer?.prepareToPlay()
                        return self._backgroundMusicPlayer
                    } else {
                        GameLogger.shared.log(prefix: "[LevelAudioManager]", message: "Failed to load boss music file")
                        return nil
                    }
                    
                } else {
                    if let backgroundMusicPath = Bundle.main.path(forResource: "shift-shaft-nonBoss-level-music-gold", ofType: "wav") {
                        let url = URL(fileURLWithPath: backgroundMusicPath)
                        self._backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                        self._backgroundMusicPlayer?.prepareToPlay()
                        return self._backgroundMusicPlayer
                    } else {
                        GameLogger.shared.log(prefix: "[LevelAudioManager]", message: "Failed to load non-boss music file")
                        return nil
                    }
                }
            }
            catch(let err) {
                GameLogger.shared.log(prefix: "[LevelAudioManager]", message: "Failed to load \(err)")
                return nil
            }
            
        }
    }
    
    func playBackgroundMusicBoardBuild() {
        if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
            playBackgroundMusic()
        }
    }

    
    func playBackgroundMusic() {
        backgroundMusicThread.sync(execute: { [backgroundMusicPlayer, musicVolume, fadeInDuration] in
            backgroundMusicPlayer?.setVolume(0, fadeDuration: 0)
            backgroundMusicPlayer?.play()
            backgroundMusicPlayer?.setVolume(musicVolume, fadeDuration: TimeInterval(fadeInDuration))
            
            // negative value means that it will loop
            backgroundMusicPlayer?.numberOfLoops = -1
        })
    }
    
    func stopBackgroundMusic() {
        backgroundMusicThread.sync(execute: { [backgroundMusicPlayer] in
            backgroundMusicPlayer?.setVolume(0, fadeDuration: 0.5)
        })
        
        backgroundMusicThread.asyncAfter(deadline: .now() + 0.5, execute: { [backgroundMusicPlayer] in
            backgroundMusicPlayer?.pause()
        })

    }
    
    func loadAllSounds() {
        // purposefully left blank.
    }
    
    func playSound(_ sound: Sound, waitForCompletion: Bool = false, silent: Bool = false) {
        // purposefully left blank.
    }
    
    func sequenceSounds(_ sounds: [Sound]) {
        // purposefully left blank.
    }

}


class AudioEventListener {
    
    init(audioManager: LevelAudioManager) {
//        Dispatch.shared.register { (input) in
//            switch input.type {
//            case .transformation(let transformations):
//                if let trans = transformations.first, let inputType = trans.inputType {
//                    switch inputType {
//                    case .touch:
//                        if trans.newTiles != nil {
//                            audioManager.playSound(.mineRocks)
//
//                            if trans.removedTilesContainGem ?? false {
//                                audioManager.playSound(.gemAppears)
//                            }
//                        } else {
//                            audioManager.playSound(.pickaxe)
//                        }
//                    default:
//                        break
//                    }
//                }
//            case .collectItem:
//                audioManager.playSound(.collectGem)
//            case .goalCompleted(_, allGoalsCompleted: let allCompleted):
//                if allCompleted {
//                    audioManager.sequenceSounds([.goalCompleted, .exitUnblocked])
//                } else {
//                    audioManager.playSound(.goalCompleted)
//                }
//
//            case .attack(attackType: _, attacker: _, defender: _, affectedTiles: _, dodged: _, attackerIsPlayer: let attackerIsPlayer):
//                if attackerIsPlayer {
//                    audioManager.playSound(.playerHitsEnemy)
//                } else {
//                    audioManager.playSound(.enemyHitsPlayer)
//                }
//
//            case .gameWin:
//                audioManager.playSound(.levelComplete)
//                audioManager.stopBackgroundMusic()
//
//            case .gameLose:
//                audioManager.playSound(.gameLose)
//                audioManager.stopBackgroundMusic()
//
//            case .playAgain, .loseAndGoToStore:
//                audioManager.stopBackgroundMusic()
//
//            default:
//                break
//            }
//        }
    }
}
