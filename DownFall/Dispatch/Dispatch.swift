//
//  Dispatch.swift
//  DownFall
//
//  Created by William Katz on 3/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

protocol DispatchReceiver {
    func receive(_ e: Event)
    func isEqual(to other: AnyObject) -> Bool
}

enum Event: Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        switch (lhs, rhs) {
        case (.render, .render), (.rotate, .rotate), (.transformation(_), .transformation(_)):
            return true
        default:
            return false
        }
    }
    
    public var hashValue: Int {
        switch self {
        case .render:
            return 1
        case .rotate:
            return 2
        case .transformation:
            return 3
        case .animationsFinished:
            return 4
        case .refereeStart:
            return 5
        }
    }
    
    case render
    case rotate
    case transformation(Transformation?)
    case animationsFinished(Transformation?)
    case refereeStart(Board?)
}

class Dispatch {
    
    
    static let sharedInstance = Dispatch()
    
    init() {}
    
    var receivers: [Event: [DispatchReceiver]] = [:]
    var queue: [Event] = []
    
    func register(_ receiver: DispatchReceiver, for e: Event) {
        var receivers = self.receivers[e] ?? []
        receivers.append(receiver)
        self.receivers[e] = receivers
    }
    
    func unregister(_ receiver: DispatchReceiver, for e: Event) {
        var receivers: [DispatchReceiver] = self.receivers[e] ?? []
        receivers.removeAll {
            return receiver.isEqual(to: $0 as AnyObject)
        }
        self.receivers[e] = receivers
    }
    
    func post(_ event: Event) {
        queue.append(event)
    }
    
    func send() {
        guard !queue.isEmpty else { return }
        let event = queue.removeFirst()
        receivers[event]?.forEach {
            $0.receive(event)
        }
    }
    
    func reset() {
        receivers = [:]
        queue = []
    }
}
