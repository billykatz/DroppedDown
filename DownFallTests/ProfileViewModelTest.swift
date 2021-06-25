//
//  ProfileViewModelTest.swift
//  DownFallTests
//
//  Created by Billy on 6/24/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import XCTest
import CombineSchedulers
import Combine
import GameKit
@testable import Shift_Shaft

extension PlayerClient {
    static let noSavedGames = Self(
        fetchGCSavedGames: {
            return Future { promise in
                promise(.success([]))
            }
        },
        saveGameData: { _, _, _ in },
        deleteGame: { _ in
            return Future { promise in
                promise(.success(true))
            }
        },
        authenticationHandler: { _ in
            return { }()
        },
        isAuthenticated: { return true }
    )
}

class ProfileViewModelTest: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    
    var testScheduler: TestSchedulerOf<DispatchQueue>!
    var mainScheduler: TestSchedulerOf<DispatchQueue>!
    
    override func setUp() {
        self.testScheduler = DispatchQueue.test
        self.mainScheduler = TestSchedulerOf<DispatchQueue>(now: .init(.init(uptimeNanoseconds: 1)))
    }
    
    func testInitialProfile() {
        let profileViewModel = ProfileViewModel(localPlayer: .success,
                                                userDefaultClient: .noUserDefaults,
                                                fileManagerClient: .test,
                                                scheduler: testScheduler.eraseToAnyScheduler(),
                                                mainQueue: mainScheduler.eraseToAnyScheduler())
        
        var expectedProfiles: [Profile?] = []
        profileViewModel
            .loadedProfile
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { profile in
                    expectedProfiles.append(profile)
                }
            )
            .store(in: &cancellables)
        
        XCTAssertEqual(expectedProfiles, [])

    }
    
    func testProfileSaveLocally() {
        
        let profileViewModel = ProfileViewModel(localPlayer: .success,
                                                userDefaultClient: .testUserDefaults,
                                                fileManagerClient: .test,
                                                scheduler: testScheduler.eraseToAnyScheduler(),
                                                mainQueue: mainScheduler.eraseToAnyScheduler())
    }

}
