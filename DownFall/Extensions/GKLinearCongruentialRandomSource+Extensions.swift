//
//  GKLinearCongruentialRandomSource+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 11/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import GameplayKit

extension GKLinearCongruentialRandomSource {
    var positiveNextInt: Int {
        return abs(self.nextInt())
    }
}

extension GKLinearCongruentialRandomSource {
    func procsGivenChance(_ chance: Float) -> Bool {
        let nextFloat = nextUniform()
        if chance >= nextFloat * 100 {
            return true
        } else {
            return false
        }
    }
    
    func chooseElement<Element>(_ array: [Element]) -> Element? {
        guard !array.isEmpty else { return nil }
        let nextFloat = nextUniform()
        let totalChances = Float(array.count) * nextFloat
        let chosenIndex =  Int(totalChances.rounded(.towardZero))
        return array[chosenIndex]
    }
    
    func chooseElement<Element>(_ array: [Element], avoidBlock: (Element) -> Bool) -> Element? {
        guard !array.isEmpty else { return nil }
        let nextFloat = nextUniform()
        let totalChances = Float(array.count) * nextFloat
        let chosenIndex =  Int(totalChances.rounded(.towardZero))
        var chosen = array[chosenIndex]
        while avoidBlock(chosen) {
            let nextFloat = nextUniform()
            let totalChances = Float(array.count) * nextFloat
            let chosenIndex =  Int(totalChances.rounded(.towardZero))
            chosen = array[chosenIndex]
        }
        return array[chosenIndex]
    }

    
    func chooseElements<Element>(choose: Int, fromArray array: [Element]) -> [Element] where Element: Equatable {
        guard !array.isEmpty else { return [] }
        guard choose < array.count else { return array }
        var chosenElements: [Element] = []
        var chooseFromArray = array
        var maxTries = 30
        while !chooseFromArray.isEmpty && maxTries > 0 && chosenElements.count < choose {
            if let nextElement = chooseElement(chooseFromArray) {
                chosenElements.append(nextElement)
                if let idx = chosenElements.firstIndex(where: { element in
                    return element == nextElement
                }) {
                    chooseFromArray.remove(at: idx)
                }
            } else {
                maxTries -= 1
            }
        }
        return chosenElements
    }
    
    func chooseElementWithChance<Element>(_ array: [Element]) -> Element? where Element: ChanceModel {
        guard !array.isEmpty else { return nil }
        let nextFloat = nextUniform()
        
        let totalChances = array.reduce(0, { prev, current in return prev + current.chance }) * nextFloat
        var chosenNumber = totalChances.rounded(.towardZero)
        
        // we want teh current chance number to encompassment the valid remainging
        for chanceModel in array {
            if chanceModel.chance >= chosenNumber {
                return chanceModel
            } else {
                chosenNumber -= chanceModel.chance
            }
        }
        
        return array.last!
    }
    
    func chooseElementWithChance<Element, T>(_ array: [Element]) -> Element? where Element: AnyChanceModel<T> {
        guard !array.isEmpty else { return nil }
        let nextFloat = nextUniform()
        
        let totalChances = array.reduce(0, { prev, current in return prev + current.chance }) * nextFloat
        var chosenNumber = totalChances.rounded(.towardZero)
        
        // we want the current chance number to encompass the valid remaining
        for chanceModel in array {
            if chanceModel.chance >= chosenNumber {
                return chanceModel
            } else {
                chosenNumber -= chanceModel.chance
            }
        }
        
        return array.last!
    }

    
    func chooseElementsWithChance<Element, T>(_ array: [Element], choices: Int) -> [Element] where Element: AnyChanceModel<T> {
        guard !array.isEmpty else { return [] }
        var chosenElements: [Element] = []
        
        var maxTries = 30
        while chosenElements.count < choices && maxTries > 0 {
            if let chosen = chooseElementWithChance(array) {
                if !chosenElements.contains(chosen) {
                    chosenElements.append(chosen)
                }
            }
            maxTries -= 1
        }
        
        return chosenElements
    }

}

