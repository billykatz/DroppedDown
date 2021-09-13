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
        
        XCTAssertEqual(expectedProfiles, [nil])

    }
    
    func testProfileStart() {
        
        let profileViewModel = ProfileViewModel(localPlayer: .noSavedGames,
                                                userDefaultClient: .testUserDefaults,
                                                fileManagerClient: .live,
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

        
        profileViewModel.start(UIViewController())
        
        XCTAssertEqual(expectedProfiles, [nil])
        
        // profile work is done on the background thread
        testScheduler.advance()
        
        profileViewModel.authenicatedSubject.send(true)
        
        // profiles are received on the main thread
        mainScheduler.advance()
        
        /// save the profile with the uuid as the name
        /// copy all other defaults
        let newProfile = Profile(name: "", progress: 3, player: .zero, deepestDepth: 0, progressModel: CodexViewModel())
        
        XCTAssertEqual(expectedProfiles.last!?.currentRun, newProfile.currentRun)
        XCTAssertEqual(expectedProfiles.last!?.progress, newProfile.progress)
        XCTAssertEqual(expectedProfiles.last!?.deepestDepth, newProfile.deepestDepth)
            
    }
    
    func testProfileSaveLocalProfileProgressedFurther() {
        
        let profileViewModel = ProfileViewModel(localPlayer: .noSavedGames,
                                                userDefaultClient: .testUserDefaults,
                                                fileManagerClient: .live,
                                                profileCodingClient: .test,
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

        
        profileViewModel.start(UIViewController())
        
        XCTAssertEqual(expectedProfiles, [nil])
        
        // profile work is done on the background thread
        testScheduler.advance()
        
        profileViewModel.authenicatedSubject.send(true)
        
        // profiles are received on the main thread
        mainScheduler.advance()
        
        let saveProfile = Profile(name: "test-uuid-1", progress: 1, player: .playerZero, currentRun: nil, randomRune: nil, deepestDepth: 3, progressModel: CodexViewModel())
        profileViewModel.authenicatedSubject.send(true)
        profileViewModel.saveProfile(saveProfile)
        
        XCTAssertNotEqual(saveProfile.name, expectedProfiles.last!!.name)
        
        testScheduler.advance(by: 100)
        mainScheduler.advance(by: 100)
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertEqual(saveProfile.name, lastProfileSaved.name)
            
    }

    func testProfileSaveLocalProfileProgressedTheSame() {
        
        let profileViewModel = ProfileViewModel(localPlayer: .noSavedGames,
                                                userDefaultClient: .testUserDefaults,
                                                fileManagerClient: .live,
                                                profileCodingClient: .test,
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

        
        profileViewModel.start(UIViewController())
        
        XCTAssertEqual(expectedProfiles, [nil])
        
        // profile work is done on the background thread
        testScheduler.advance()
        
        profileViewModel.authenicatedSubject.send(true)
        
        // profiles are received on the main thread
        mainScheduler.advance()
        
        let saveProfile = Profile(name: "test-uuid-1", progress: 0, player: .playerZero, currentRun: nil, randomRune: nil, deepestDepth: 3, progressModel: CodexViewModel())
        profileViewModel.authenicatedSubject.send(true)
        profileViewModel.saveProfile(saveProfile)
        
        XCTAssertNotEqual(saveProfile.name, expectedProfiles.last!!.name)
        
        testScheduler.advance()
        mainScheduler.advance()
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertEqual(saveProfile.name, lastProfileSaved.name)
            
    }

    
    func testProfileDoNotSaveBecauseExistingProfileProgressedFurther() {
        
        let profileViewModel = ProfileViewModel(localPlayer: .noSavedGames,
                                                userDefaultClient: .testUserDefaults,
                                                fileManagerClient: .live,
                                                profileCodingClient: ProfileCodingClient(decoder: .progress10, encoder: .test),
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

        
        profileViewModel.start(UIViewController())
        
        XCTAssertEqual(expectedProfiles, [nil])
        
        // profile work is done on the background thread
        testScheduler.advance()
        
        profileViewModel.authenicatedSubject.send(true)
        
        // profiles are received on the main thread
        mainScheduler.advance()
        
        let saveProfile = Profile(name: "test-uuid-1", progress: 1, player: .playerZero, currentRun: nil, randomRune: nil, deepestDepth: 3, progressModel: CodexViewModel())
        profileViewModel.authenicatedSubject.send(true)
        profileViewModel.saveProfile(saveProfile)
        
        
        testScheduler.advance()
        mainScheduler.advance()
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertNotEqual(saveProfile.name, lastProfileSaved.name)
            
    }



}
