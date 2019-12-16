//
//  IndexPath+Extensions.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

extension IndexPath {
    mutating func incrStepIndex() {
        self = IndexPath(item: item+1, section: section)
    }
}
