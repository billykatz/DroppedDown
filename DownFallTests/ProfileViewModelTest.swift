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
        let profileViewModel = ProfileLoadingManager(localPlayer: .success,
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
        
        let profileViewModel = ProfileLoadingManager(localPlayer: .noSavedGames,
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
        let newProfile = Profile(name: "", player: .zero, currentRun: nil, stats: [], unlockables: [], startingUnlockbles: [], pastRunSeeds: [])
        
        XCTAssertEqual(expectedProfiles.last!?.currentRun, newProfile.currentRun)
            
    }
    
    func testProfileSaveLocalProfileProgressedFurther() {
        
        let profileViewModel = ProfileLoadingManager(localPlayer: .noSavedGames,
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
        
        
        
        let saveProfile = Profile(name: "test-uuid-1", player: .playerZero, currentRun: nil, stats: [], unlockables: Unlockable.testUnlockablesOnePurchased, startingUnlockbles: [], pastRunSeeds: [])
        
        profileViewModel.authenicatedSubject.send(true)
        profileViewModel.saveProfile(saveProfile)
        
        XCTAssertNotEqual(expectedProfiles.last!!.progress, saveProfile.progress)
        XCTAssertNotEqual(saveProfile.name, expectedProfiles.last!!.name)
        
        testScheduler.advance(by: 100)
        mainScheduler.advance(by: 100)
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertEqual(saveProfile.name, lastProfileSaved.name)
        XCTAssertEqual(saveProfile.progress, lastProfileSaved.progress)
            
    }

    func testProfileSaveLocalProfileProgressedTheSame() {
        
        let profileViewModel = ProfileLoadingManager(localPlayer: .noSavedGames,
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
        
        let saveProfile = Profile(name: "test-uuid-1", player: .playerZero, currentRun: nil, stats: [], unlockables: [], startingUnlockbles: [], pastRunSeeds: [])
        
        profileViewModel.authenicatedSubject.send(true)
        profileViewModel.saveProfile(saveProfile)
        
        XCTAssertNotEqual(saveProfile.name, expectedProfiles.last!!.name)
        
        testScheduler.advance()
        mainScheduler.advance()
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertEqual(saveProfile.name, lastProfileSaved.name)
            
    }

    
    func testProfileDoNotSaveBecauseExistingProfileProgressedFurther() {
        
        let profileViewModel = ProfileLoadingManager(localPlayer: .noSavedGames,
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
        
        let saveName = "SaveThisOne\(UUID())"
        let saveProfile = Profile(name: saveName, player: .playerZero, currentRun: nil, stats: [], unlockables: Unlockable.testUnlockablesOnePurchased, startingUnlockbles: [], pastRunSeeds: [])
        
        
        profileViewModel.saveProfile(saveProfile)
        profileViewModel.authenicatedSubject.send(false)
        
        testScheduler.advance()
        mainScheduler.advance()
        
        
        let nextProfie = Profile(name: "this-one-is-not", player: .playerZero, currentRun: nil, stats: [], unlockables: Unlockable.testUnlockablesNonePurchased, startingUnlockbles: [], pastRunSeeds: [])

        
        profileViewModel.saveProfile(nextProfie)
        
        testScheduler.advance()
        mainScheduler.advance()
        
        /// there was an issue with calling this in the same exact moment when calling saveProfile which caused a stale value to be spit through the pipeline
        /// Leave this in here to keep this test useful
        profileViewModel.authenicatedSubject.send(false)
        
        let lastProfileSaved = expectedProfiles.last!!
        
        XCTAssertEqual(saveName, lastProfileSaved.name)
            
    }



}
