//
//  Bool+Extensions.swift
//  DownFall
//
//  Created by Billy on 2/20/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

extension Bool {
    static var randomSign: Int {
        return self.random() ? -1 : 1
    }
}
