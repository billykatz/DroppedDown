//
//  TurnWatcher.swift
//  DownFall
//
//  Created by William Katz on 9/26/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

class TurnWatcher {
    static let shared = TurnWatcher()
    
    private var newTurn = false
    
    init() {
        register()
    }
    
    func register() {
        Dispatch.shared.register { [weak self] (input) in
            switch input.type {
            case .transformation(let transformation):
                switch transformation.inputType {
                case .reffingFinished?:
                    ()
                case .touchBegan:
                    ()
                case .itemUsed:
                    self?.newTurn = false
                case .touch(_, let type):
                    if case TileType.monster = type {
                        self?.newTurn = false
                    }
                    if transformation.tileTransformation != nil {
                        self?.newTurn = true
                    }
                default:
                    if transformation.tileTransformation != nil {
                        self?.newTurn = true
                    }
                }
            default:
                ()
            }
        }

    }
    
    func getNewTurnAndReset() -> Bool {
        let newTurnValue = newTurn
        newTurn = false
        return newTurnValue
    }
    
    func checkNewTurn() -> Bool {
        return newTurn
    }
}
