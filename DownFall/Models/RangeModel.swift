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
}

extension RangeModel {
    static var one: RangeModel {
        return RangeModel(lower: 1, upper: 1)
    }
    
    static var zero: RangeModel {
        return RangeModel(lower: 0, upper: 0)
    }
}
