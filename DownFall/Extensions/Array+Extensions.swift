//
//  Array+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 3/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    /// Returns the object at th index or nil
    /// Useful for when you are not sure the size of the array
    func optionalElement(at index: Int) -> Element? {
        if index < self.count {
            return self[index]
        }
        return nil
    }
    
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
    
    func dropRandom() -> [Element] {
        guard self.count > 1 else { return [] }
        let randomIndex = Int.random(in: 0..<self.count)
        var newArray: [Element] = []
        for (idx, element) in self.enumerated() {
            if idx != randomIndex {
                newArray.append(element)
            }
        }
        
        return newArray
    }
    
    func dropRandom() -> ([Element], Element?) {
        guard !isEmpty else { return ([], nil) }
        guard count > 1 else { return ([], self.first!) }
        let randomIndex = Int.random(in: 0..<self.count)
        var randomElement: Element?
        var newArray: [Element] = []
        for (idx, element) in self.enumerated() {
            if idx != randomIndex {
                newArray.append(element)
            } else {
                randomElement = element
            }
        }
        
        return (newArray, randomElement)
    }
    
    func choose(random x: Int) -> [Element] {
        guard x < count else { return self }
        let elementsToRemove = count - x
        var arrayToRemoveFrom = self
        (0..<elementsToRemove).forEach { _ in
            arrayToRemoveFrom = arrayToRemoveFrom.dropRandom()
        }
        return arrayToRemoveFrom
    }
}

extension Array {
    mutating func removeFirst(where predicate: (Element) -> Bool) {
        var indexToRemove: Int?
        for (index, el) in self.enumerated() {
            if predicate(el) {
                indexToRemove = index
                break
            }
        }
        if indexToRemove != nil {
            self.remove(at: indexToRemove!)
        }
    }
    
    mutating func removeFirstAndReturn(where predicate: (Element) -> Bool) -> Element? {
        var indexToRemove: Int?
        for (index, el) in self.enumerated() {
            if predicate(el) {
                indexToRemove = index
                break
            }
        }
        if indexToRemove != nil {
            let element = self[indexToRemove!]
            self.remove(at: indexToRemove!)
            return element
        } else {
             return nil
        }
    }
}


extension Array where Element: Collection, Element.Index == Int {
    subscript(tileCoord: TileCoord) -> Element.Iterator.Element {
        return self[tileCoord.x][tileCoord.y]
    }
}


extension Array {
    func randomElement(favorWhere: (Element) -> Bool) -> Element? {
        if let firstIndex = self.firstIndex(where: favorWhere) {
            return self[firstIndex]
        } else {
            return randomElement()
        }
    }
    
//    func randomElement(favorWhere: (Element) -> Bool, avoid: (Element) -> Bool) -> Element? {
//        if let firstIndex = self.firstIndex(where: favorWhere) {
//            if avoid (self[firstIndex])
//            return self[firstIndex]
//        } else {
//            return randomElement()
//        }
//    }
}

extension Array where Element == SpriteAction {
    func maxDuration() -> Double {
        return (self.max(by: { lhsSpriteAction, rhsSpriteActions in
            return lhsSpriteAction.duration > rhsSpriteActions.duration
        }))?.duration ?? 0.0
    }
}
