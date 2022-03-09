//
//  MenuMusicManager.swift
//  DownFall
//
//  Created by Billy on 2/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class MenuMusicManager {
    
    static let shared = MenuMusicManager()
    static let tag = String(describing: MenuMusicManager.shared)
    
    let menuMusicThread = DispatchQueue(label: "MenuMusicManager.menuMusicThread", qos: .userInitiated)
    let musicVolume: Float = 0.5
    
    var menuMusicPlayer: AVAudioPlayer?
    var observer: NSKeyValueObservation?
    var muted: Bool = false {
        didSet {
            decideToPlayOrStopMusic()
        }
    }
    
    var gameIsPlaying: Bool = false {
        didSet {
            decideToPlayOrStopMusic()
        }
    }
    
    init() {
        menuMusicThread.sync { [weak self] in
            do {
                let resourceName = "shift-shaft-menu-music-gold"
                if let backgroundMusicPath = Bundle.main.path(forResource: resourceName, ofType: "m4a") {
                    let url = URL(fileURLWithPath: backgroundMusicPath)
                    self?.menuMusicPlayer = try AVAudioPlayer(contentsOf: url)
                    self?.menuMusicPlayer?.prepareToPlay()
                } else {
                    print("no music")
                }

            }
            catch(let err) {
                GameLogger.shared.log(prefix: MenuMusicManager.tag, message: "Failed to load menu music \(err)")
            }
        }
        
        menuMusicThread.async { [weak self] in
            self?.observer = UserDefaults.standard.observe(\.muteMusic, options: [.new], changeHandler: { [weak self] (defaults, change) in
                let isMuted = change.newValue ?? true
                self?.muted = isMuted
            })
        }

    }
    
    var shouldPlay: Bool {
        return !muted && !(menuMusicPlayer?.isPlaying ?? true) && !UserDefaults.standard.bool(forKey: UserDefaults.muteMusicKey) && !gameIsPlaying
    }
    
    deinit {
        observer?.invalidate()
    }
    
    func decideToPlayOrStopMusic() {
        if shouldPlay {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
    
    func playBackgroundMusic() {
        menuMusicThread.async { [menuMusicPlayer, shouldPlay, musicVolume] in
            if shouldPlay {
                menuMusicPlayer?.setVolume(0, fadeDuration: 0)
                menuMusicPlayer?.play()
                menuMusicPlayer?.setVolume(musicVolume, fadeDuration: 1.25)
                menuMusicPlayer?.numberOfLoops = -1
            }
        }
    }
    
    func stopBackgroundMusic() {
        menuMusicThread.async { [menuMusicPlayer, musicVolume] in
            if menuMusicPlayer?.isPlaying ?? false {
                menuMusicPlayer?.setVolume(musicVolume, fadeDuration: 0)
                menuMusicPlayer?.setVolume(0.0, fadeDuration: 0.4)
            }
        }

        menuMusicThread.asyncAfter(deadline: .now() + 0.4, execute: { [menuMusicPlayer] in
            menuMusicPlayer?.pause()
        })
    }
    
}
