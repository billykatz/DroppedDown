//
//  Dispatch.swift
//  DownFallTests
//
//  Created by William Katz on 3/3/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

class MockRenderer : DispatchReceiver {
    
    var receivedWasCalled = false
    var eventReceived : [Event: Bool] = [:]
    
    func receive(_ e: Event) {
        //purposefully left empty for protocol conformance
        eventReceived[e] = true
    }
    func isEqual(to other: AnyObject) -> Bool {
        guard let other = other as? MockRenderer else { return false }
        return self === other
        
    }
    
}

class MockBoard : DispatchReceiver {
    var eventReceived : [Event: Bool] = [:]
    
    func receive(_ e: Event) {
        //purposefully left empty for protocol conformance
        eventReceived[e] = true
    }
    func isEqual(to other: AnyObject) -> Bool {
        guard let other = other as? MockBoard else { return false }
        return self === other
        
    }
    
}

class DispatchTests: XCTestCase {
    
    var dispatch: Dispatch = Dispatch.sharedInstance
    var mockRenderer: MockRenderer!
    var mockBoard: MockBoard!
    
    override func setUp() {
        mockRenderer = MockRenderer()
        mockBoard = MockBoard()
    }
    
    override func tearDown() {
        mockRenderer = nil
        mockBoard = nil
        dispatch.reset()
    }
    
    func testDispatchInit() {
        let dispatch = Dispatch()
        XCTAssertNotNil(dispatch)
    }
    
    func testDispatchProvidesSingleton() {
        XCTAssertNotNil(dispatch)
    }
    
    func testDispatchRegistration() {
        
        //registration
        XCTAssertEqual(dispatch.receivers[.render]?.count, nil)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, nil)
        
        //register for render
        dispatch.register(mockRenderer, for: .render)
        XCTAssertEqual(dispatch.receivers[.render]?.count, 1)
        dispatch.register(mockBoard, for: .render)
        XCTAssertEqual(dispatch.receivers[.render]?.count, 2)
        
        //register for rotate
        dispatch.register(mockBoard, for: .rotate)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 1)
        dispatch.register(mockRenderer, for: .rotate)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 2)
        
        
        //Unregister
        
        //unregister for rotate
        dispatch.unregister(mockRenderer, for: .rotate)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 1)
        dispatch.unregister(mockBoard, for: .rotate)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 0)
        
        //unregister for render
        dispatch.unregister(mockRenderer, for: .render)
        XCTAssertEqual(dispatch.receivers[.render]?.count, 1)
        dispatch.unregister(mockBoard, for: .render)
        XCTAssertEqual(dispatch.receivers[.render]?.count, 0)
        
        
        //registration
        dispatch.register(mockRenderer, for: .render)
        dispatch.register(mockBoard, for: .rotate)
        
        XCTAssertEqual(dispatch.receivers[.render]?.count, 1)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 1)
        
        //unregistrations
        //ensure we dont unregister receivers from stuff they arent listening too
        dispatch.unregister(mockBoard, for: .render)
        XCTAssertEqual(dispatch.receivers[.render]?.count, 1)
        
        dispatch.unregister(mockRenderer, for: .rotate)
        XCTAssertEqual(dispatch.receivers[.rotate]?.count, 1)
    }
    
    func testDispatchSendsEvent() {
        dispatch.register(mockRenderer, for: .render)
        dispatch.register(mockBoard, for: .rotate)
        
        XCTAssertFalse(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.render] ?? false)
        
        dispatch.send()
        
        XCTAssertFalse(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.render] ?? false)
        
        
        dispatch.post(.rotate)
        dispatch.post(.render)
        
        dispatch.send()
        XCTAssertTrue(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.render] ?? false)
        XCTAssertFalse(mockBoard.eventReceived[.render] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.rotate] ?? false)
        
        dispatch.send()
        XCTAssertTrue(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertTrue(mockRenderer.eventReceived[.render] ?? false)
        XCTAssertFalse(mockBoard.eventReceived[.render] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.rotate] ?? false)
        
        
        dispatch.register(mockBoard, for: .render)
        XCTAssertFalse(mockBoard.eventReceived[.render] ?? false)
        dispatch.post(.render)
        dispatch.send()
        XCTAssertTrue(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertTrue(mockRenderer.eventReceived[.render] ?? false)
        XCTAssertTrue(mockBoard.eventReceived[.render] ?? false)
        XCTAssertFalse(mockRenderer.eventReceived[.rotate] ?? false)
        
        
        dispatch.register(mockRenderer, for: .rotate)
        XCTAssertFalse(mockRenderer.eventReceived[.rotate] ?? false)
        dispatch.post(.rotate)
        dispatch.send()
        XCTAssertTrue(mockBoard.eventReceived[.rotate] ?? false)
        XCTAssertTrue(mockRenderer.eventReceived[.render] ?? false)
        XCTAssertTrue(mockBoard.eventReceived[.render] ?? false)
        XCTAssertTrue(mockRenderer.eventReceived[.rotate] ?? false)
        
    }
}
