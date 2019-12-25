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
    
    func divivdedIntoSubRanges(_ subRanges: Int) -> [RangeModel] {
        /// 0...90 -> 0...29, , 30...59, 60...89
        ///
        var subRangeModels: [RangeModel] = []
        var lower = self.lower
        let rangeValue = (upper - lower) / subRanges
        var upper = rangeValue - 1
        for _ in 0..<subRanges {
            subRangeModels.append(RangeModel(lower: lower, upper: upper))
            lower = upper + 1
            upper = lower + rangeValue - 1
        }
        
        return subRangeModels
    }
    
    func next(_ extraRange: Int) -> RangeModel {
        /// given a range of 60-70 the next range of 10 would be 71-81
        return RangeModel(lower: upper + 1, upper: upper + extraRange)
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
