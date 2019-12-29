//
//  RangeModel.swift
//  DownFall
//
//  Created by William Katz on 6/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct RangeModel: Decodable, Equatable, Hashable {
    let lower: Int
    let upper: Int
    
    /// This is not guaranteed to create even distribution
    /// For ranges where the total is not divisible by the number of subranges, then rounding occurs
    /// E.g. 10 into 4 ranges = 2 2 3 3
    /// 10 into 5 = 2 2 2 2 2
    /// 10 into 6 = 2 2 2 2 1 1
    
    func divivdedIntoSubRanges(_ subRanges: Int) -> [RangeModel] {
        /// 0...90 -> 0...29, , 30...59, 60...89
        ///
        var subRangeModels: [RangeModel] = []
        var lower = self.lower
        let rangeValue = (upper - lower) / subRanges
        var upper = rangeValue - 1
        var lastUpper = 0
        for _ in 0..<subRanges {
            subRangeModels.append(RangeModel(lower: lower, upper: upper))
            lastUpper = upper
            lower = upper + 1
            upper = lower + rangeValue - 1
        }
        
        /// This logic deals with rounding issues where the range is not evenly divided by the number of subranges
        let difference =  self.upper - lastUpper
        var count = 0
        for _ in 0..<difference {
            subRangeModels[count] = RangeModel(lower: subRangeModels[count].lower,
                                               upper: min(self.upper-1,subRangeModels[count].upper+1) )
                
            for nextIndex in count+1..<subRangeModels.count {
                subRangeModels[nextIndex] = RangeModel(lower: subRangeModels[nextIndex].lower+1,
                                                       upper: min(self.upper-1,subRangeModels[nextIndex].upper+1))
            }
            count += 1
        }
        
        return subRangeModels
    }
    
    func next(_ extraRange: Int) -> RangeModel {
        /// given a range of 60-70 the next range of 10 would be 70-79
        return RangeModel(lower: upper, upper: upper + extraRange - 1)
    }
    
    func contains(_ number: Int) -> Bool {
        return lower <= number && number <= upper
    }
}

extension RangeModel {
    static var one: RangeModel {
        return RangeModel(lower: 1, upper: 1)
    }
    
    static var zero: RangeModel {
        return RangeModel(lower: 0, upper: 0)
    }
}
