//
//  RuneReplacementView.swift
//  DownFall
//
//  Created by Katz, Billy on 11/14/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Combine

protocol RuneReplacementViewModelInputs {
    
}

protocol RuneReplacementViewModelOutputs {
    
}

struct RuneReplacementViewModel {
    let newRune: Rune
    let runeSlots: Int
    let currentRunes: [Rune]
}
