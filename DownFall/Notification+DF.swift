//
//  Notification+DF.swift
//  DownFall
//
//  Created by William Katz on 9/17/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let rotated = Notification.Name("rotated")
    static let computeNewBoard = Notification.Name("computeNewBoard")
    static let lessThanThreeNeighborsFound = Notification.Name("lessThanThreeNeighborsFound")
    static let gameWin = Notification.Name("gameWin")
    static let noMovesLeft = Notification.Name("noMovesLeft")
}
