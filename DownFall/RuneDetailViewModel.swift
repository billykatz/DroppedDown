//
//  RuneDetailViewModel.swift
//  DownFall
//
//  Created by Billy on 12/8/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Combine
import CoreGraphics

protocol RuneDetailViewModelable {
    var rune: Rune? { get }
    var progress: CGFloat { get }
    var confirmed: ((Rune) -> ())? { get set }
    var canceled: (() -> ())? { get set }
    var isCharged: Bool { get }
    var chargeDescription: String? { get }
}

class RuneDetailViewModel: RuneDetailViewModelable {
    var rune: Rune?
    var progress: CGFloat
    var confirmed: ((Rune) -> ())?
    var canceled: (() -> ())?
    
    init(rune: Rune?, progress: CGFloat, confirmed: ((Rune) -> ())?, canceled: (() -> ())?) {
        self.rune = rune
        self.progress = progress
        self.confirmed = confirmed
        self.canceled = canceled
    }
    
    /// returns true is we have completed the charging of a rune
    var isCharged: Bool {
        guard let rune = rune else { return false }
        return progress >= CGFloat(rune.cooldown)
    }
    
    /// returns a string to display to players that describes how to recahrge the rune
    var chargeDescription: String? {
        guard let rune = rune else { return nil }
        if rune.isCharged { return "Ready to use" }
        var strings: [String] = []
        for type in rune.rechargeType {
            switch type {
            case .rock(let color, _ , _):
                let moreToMine = rune.cooldown - rune.rechargeCurrent
                let grouped = rune.rechargeMinimum > 1
                if grouped {
                    strings.append("Mine \(rune.cooldown) groups of \(rune.rechargeMinimum)+")
                } else {
                    let charge = "Mine \(moreToMine) more \(color.humanReadable.lowercased()) rock\(moreToMine > 1 ? "s" : "") to charge"
                    strings.append(charge)
                }
            case .monster:
                let moreToKill = rune.cooldown - rune.rechargeCurrent
                let charge = "Kill \(moreToKill) more monster\(moreToKill > 1 ? "s" : "") with your pickaxe"
                strings.append(charge)
            default:
                break
            }
        }
        strings.removeDuplicates()
        
        return strings.joined(separator: ". ")
    }
}
