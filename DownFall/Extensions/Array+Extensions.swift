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
    
}
