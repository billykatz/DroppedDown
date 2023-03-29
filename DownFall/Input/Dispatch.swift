//
//  Dispatch.swift
//  DownFall
//
//  Created by William Katz on 3/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

protocol Dispatching {
    func send(_ input: Input)
    func register(_ callback: @escaping (Input) -> ())
    func reset()
}

class Dispatch: Dispatching {
    // Dispatch.shared
    static let shared = Dispatch()
    
    var receivers: [(Input) -> ()] = []
    
    func register(_ callback: @escaping (Input) -> ()) {
        receivers.append(callback)
    }
    
    func send(_ input: Input) {
        receivers.forEach {
            $0(input)
        }
    }
    
    func reset() {
        receivers = []
    }
}
