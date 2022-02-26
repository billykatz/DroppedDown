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


class AudioManager {
    
    let audioThread = DispatchQueue(label: "audioThread", qos: .userInitiated)
    let backgroundMusicThread = DispatchQueue(label: "musicThread", qos: .userInitiated)
    
    let audioNode: SKAudioNode
    var backgroundMusicPlayer: AVAudioPlayer?
    let musicVolume: Float = 0.5
    
    var observer: NSKeyValueObservation?
    
    init(sceneNode: SKNode, isBossLevel: Bool) {
        self.audioNode = SKAudioNode()
        
        backgroundMusicThread.sync { [weak self] in
            do {
                let resourceName = isBossLevel ? "shift-shaft-boss-loop" : "background-music"
                if let backgroundMusicPath = Bundle.main.path(forResource: resourceName, ofType: "wav") {
                    let url = URL(fileURLWithPath: backgroundMusicPath)
                    self?.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                    self?.backgroundMusicPlayer?.prepareToPlay()
                } else {
                    print("no music")
                }
            }
            catch(let err) {
                print(err)
            }
        }
        
        backgroundMusicThread.async { [weak self] in
            self?.observer = UserDefaults.standard.observe(\.muteMusic, options: [.new], changeHandler: { [weak self] (defaults, change) in
                let isMuted = change.newValue ?? true
                if (isMuted) {
                    self?.stopBackgroundMusic()
                } else {
                    self?.playBackgroundMusic()
                }
            })
        }

        
        sceneNode.addChild(self.audioNode)
            
//        loadAllSounds()
    }
    
    deinit {
        observer?.invalidate()
    }

    func playBackgroundMusic() {
        if !UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey) {
            backgroundMusicThread.sync(execute: { [backgroundMusicPlayer, musicVolume] in
                backgroundMusicPlayer?.setVolume(0, fadeDuration: 0)
                backgroundMusicPlayer?.play()
                backgroundMusicPlayer?.setVolume(musicVolume, fadeDuration: 2.5)
                
                // negative value means that it will loop
                backgroundMusicPlayer?.numberOfLoops = -1
            })
        }
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
        for sound in Sound.allCases {
            playSound(sound, silent: true)
        }
    }
    
    func playSound(_ sound: Sound, waitForCompletion: Bool = false, silent: Bool = false) {
//        audioThread.async { [weak self] in
//            let rockSound = SKAction.playSoundFileNamed(sound.filename, waitForCompletion: waitForCompletion)
//
//            if !silent && !UserDefaults.standard.bool(forKey: UserDefaults.muteSoundKey) {
//                self?.audioNode.run(rockSound)
//            }
//
//        }
    }
    
    func sequenceSounds(_ sounds: [Sound]) {
//        var soundActions = [SKAction]()
//        for sound in sounds {
//            soundActions.append(SKAction.playSoundFileNamed(sound.filename, waitForCompletion: true))
//        }
//        
//        audioThread.async { [weak self] in
//            if !UserDefaults.standard.bool(forKey: UserDefaults.muteSoundKey) {
//                self?.audioNode.run(SKAction.sequence(soundActions))
//            }
//
//        }
    }

}


class AudioEventListener {
    
    init(audioManager: AudioManager) {
        Dispatch.shared.register { (input) in
            switch input.type {
            case .transformation(let transformations):
                if let trans = transformations.first, let inputType = trans.inputType {
                    switch inputType {
                    case .touch:
                        if trans.newTiles != nil {
                            audioManager.playSound(.mineRocks)
                            
                            if trans.removedTilesContainGem ?? false {
                                audioManager.playSound(.gemAppears)
                            }
                        } else {
                            audioManager.playSound(.pickaxe)
                        }
                    default:
                        break
                    }
                }
            case .collectItem:
                audioManager.playSound(.collectGem)
            case .goalCompleted(_, allGoalsCompleted: let allCompleted):
                if allCompleted {
                    audioManager.sequenceSounds([.goalCompleted, .exitUnblocked])
                } else {
                    audioManager.playSound(.goalCompleted)
                }
                
            case .attack(attackType: _, attacker: _, defender: _, affectedTiles: _, dodged: _, attackerIsPlayer: let attackerIsPlayer):
                if attackerIsPlayer {
                    audioManager.playSound(.playerHitsEnemy)
                } else {
                    audioManager.playSound(.enemyHitsPlayer)
                }
                
            case .gameWin:
                audioManager.playSound(.levelComplete)
                audioManager.stopBackgroundMusic()
            
            case .gameLose:
                audioManager.playSound(.gameLose)
                audioManager.stopBackgroundMusic()
                
            case .playAgain, .loseAndGoToStore:
                audioManager.stopBackgroundMusic()
            case .boardBuilt, .boardLoaded:
                audioManager.playBackgroundMusic()
                
            default:
                break
            }
        }
    }
}
