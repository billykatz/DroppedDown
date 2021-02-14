//
//  AudioManager.swift
//  DownFall
//
//  Created by Katz, Billy on 1/10/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

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

    let audioNode: SKNode
    
    init(sceneNode: SKNode) {
        self.audioNode = sceneNode
        
        loadAllSounds()
    }
    
    func loadAllSounds() {
        for sound in Sound.allCases {
            playSound(sound, silent: true)
        }
    }
    
    func playSound(_ sound: Sound, waitForCompletion: Bool = false, silent: Bool = false) {
        audioThread.async { [weak self] in
            let rockSound = SKAction.playSoundFileNamed(sound.filename, waitForCompletion: waitForCompletion)
            
            if !silent && UserDefaults.standard.bool(forKey: "muteSound") {
                self?.audioNode.run(rockSound)
            }

        }
    }
    
    func sequenceSounds(_ sounds: [Sound]) {
        var soundActions = [SKAction]()
        for sound in sounds {
            soundActions.append(SKAction.playSoundFileNamed(sound.filename, waitForCompletion: true))
        }
        
        audioThread.async { [weak self] in
            self?.audioNode.run(SKAction.sequence(soundActions))
        }
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
            case .gameLose:
                audioManager.playSound(.gameLose)
                
            default:
                break
            }
        }
    }
}
