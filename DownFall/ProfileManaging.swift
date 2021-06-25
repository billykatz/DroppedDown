//
//  ProfileSaving.swift
//  DownFall
//
//  Created by Katz, Billy on 6/14/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import GameKit
import Foundation
import Combine
import CombineSchedulers

protocol ProfileManaging {
    /// Call this when the app is loaded into memory
    func start(_ presenter: UIViewController, showGCSignIn: Bool)
    
    /// Resets user defaults. Only do this when resetting the player's data
    func resetUserDefaults()
    
    /// Deletes the local profile file. Only do this when resetting the player's data. This only works if we have the UUID from User Defaults
    func deleteLocalProfile()
    
    /// Deletes all the remote files in Game Center.  I
    func deleteAllRemoteProfile()
    
    /// Emits the profile that should be loaded and use to player the game
    var loadedProfile: AnyPublisher<Profile?, Error> { get }
    
    /// Saves a profile
    func saveProfile(_ profile: Profile)
}

/// Errors emitted during Profile loading and saving
enum ProfileError: Error {
    case failedToLoadProfile
    case noUserDefaultsValue
    case profileLoadCancelled
    case failedToResolveProfiles
    case failedToLoadLocalProfile
    case failedToDeleteLocalProfile
    case localProfileHasNotProgressedFurtherThanRemoteProfile
    case failedToCreateLocalProfile
    case failedToAccessLocalDirectory
    case failedToSaveLocalProfile(Error?)
    case failureToSaveRemoteProfile(Error)
    case failedToLoadRemoteProfile(Error?)
}

class ProfileViewModel: ProfileManaging {
    
    struct Constants {
        static let playerUUIDKey = "playerUUID"
        static let saveFilePath = NSHomeDirectory()
        static let tempFilePath = NSTemporaryDirectory()
        static let tag = String(describing: ProfileViewModel.self)
    }
    
    /// Public interface with the loaded profile
    public lazy var loadedProfile = loadedProfileSubject.eraseToAnyPublisher()
    private lazy var loadedProfileSubject = PassthroughSubject<Profile?, Error>()
    
    /// Gets sent the authenication status of the GKLocalPlayer
    private lazy var authenicatedSubject = PassthroughSubject<Bool, Error>()
    private lazy var authenicated = authenicatedSubject.eraseToAnyPublisher()
    
    private let userDefaultClient: UserDefaultClient
    private var localPlayer: PlayerClient
    private let fileManagerClient: FileManagerClient
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    
    private var disposables = Set<AnyCancellable>()
    
    init(localPlayer: PlayerClient = .live,
         userDefaultClient: UserDefaultClient = .live,
         fileManagerClient: FileManagerClient = .live,
         scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "profile-saving-thread", qos: .userInitiated).eraseToAnyScheduler(),
         mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        self.localPlayer = localPlayer
        self.userDefaultClient = userDefaultClient
        self.fileManagerClient = fileManagerClient
        self.scheduler = scheduler
        self.mainQueue = mainQueue
    }
    
    /// Defines all business logic and kickoffs the pipeline by attempting to authenicate with GameCenter
    func start(_ presenter: UIViewController, showGCSignIn: Bool = false) {
        
        /// Load the remote save file into data
        let loadRemoteData =
            authenicated
                .map { _ in }
                .print("\(Constants.tag): Load remote data publisher", to: GameLogger.shared)
                .flatMap { [localPlayer] in localPlayer.fetchGCSavedGames() }
                .compactMap { savedGames in return savedGames.first }
                .flatMap(loadSavedGame)
                .eraseToAnyPublisher()
        
        /// Store the pipeline to fetch the UUID from user defaults and attempt to load the local profile
        let loadLocalProfilePublisher =
            userDefaultClient
                .fetchPlayerUUID(Constants.playerUUIDKey)
                .print("\(Constants.tag): fetch local game files", to: GameLogger.shared)
                .flatMap { [fileManagerClient] (uuid) -> Future<Profile?, Error> in
                    return loadLocalProfile(pathPrefix: Constants.saveFilePath, name: uuid, fileManagerClient: fileManagerClient)
                }
                .eraseToAnyPublisher()
        
        /// Zip the files together. No matter what we expect each inner pipeline to spit out at least one value
        let loadedProfilesZip = Publishers.Zip(
            loadRemoteData
                .eraseToAnyPublisher()
                .replaceError(with: nil),
            loadLocalProfilePublisher
                .eraseToAnyPublisher()
                .replaceError(with: nil)
        )
        
        /// Creates a new player profile locally and then saves it remotely
        let createAndSavePlayerProfile =
            createLocalProfile(playerUUIDKey: Constants.playerUUIDKey, userDefaultClient: userDefaultClient, fileManagerClient: fileManagerClient)
            .eraseToAnyPublisher()
        
        let resolveProfileConflict: AnyPublisher<Profile, Error> =
            loadedProfilesZip
                .print("\(Constants.tag): Resolve profile conflict", to: GameLogger.shared)
                .eraseToAnyPublisher()
                .tryMap ({ (saveFiles)  in
                    let (remote, local) = saveFiles
                    if remote == nil , let local = local {
                        /// load the local profile
                        GameLogger.shared.log(prefix: Constants.tag, message: "Only local file found")
                        return local
                    } else if local == nil, let remote = remote {
                        /// load the remote file
                        GameLogger.shared.log(prefix: Constants.tag, message: "Only remote file found")
                        return remote
                    } else if let remote = remote, let local = local  {
                        /// load the file which has more progress
                        /// if there is a tie, then load the remote one
                        let remoteProgressedFuther = remote.progress >= local.progress
                        GameLogger.shared.log(prefix: Constants.tag, message: "Both local and remote file found. Loading \(remoteProgressedFuther ? remote: local)")
                        return remoteProgressedFuther ? remote: local
                    } else {
                        /// this is likely a new player and needs to save a new profile
                        GameLogger.shared.log(prefix: Constants.tag, message: "Neither local or remote file found.")
                        throw ProfileError.failedToResolveProfiles
                    }
                })
                .catch { _ in
                    return createAndSavePlayerProfile
                }
                .eraseToAnyPublisher()
        
        /// Resolves the profile conflict
        /// re-saves the profiles locally and remotely
        /// Writes to loadedProfileSubject on success
        Publishers.CombineLatest(
            resolveProfileConflict.flatMap { [userDefaultClient, fileManagerClient] profile -> AnyPublisher<Profile, Error> in
                return saveProfileLocally(profile, uuidKey: Constants.playerUUIDKey, userDefaultsClient: userDefaultClient, fileManagerClient: fileManagerClient).eraseToAnyPublisher()
            },
            authenicated.map { _ in })
            .subscribe(on: scheduler)
            .receive(on: mainQueue)
            .sink(receiveCompletion: { _ in },
                  receiveValue:
                    {  [loadedProfileSubject] value  in
                        let (localProfile, _) = value
                        if localProfile == Profile.zero {
                            GameLogger.shared.fatalLog(prefix: Constants.tag, message: "Local profile failed to load")
                        }
                        GameLogger.shared.log(prefix: Constants.tag, message: "Loaded local profile with name: \(localProfile.name)")
                        loadedProfileSubject.send(localProfile)
                    })
            .store(in: &self.disposables)
        
        /// Start the authenicated process
        GameLogger.shared.log(prefix: Constants.tag, message: "Starting to authenticate with game center")
        localPlayer.authenticationHandler(
            { [authenicatedSubject, localPlayer] viewController, error in
                if let vc = viewController, showGCSignIn {
                    GameLogger.shared.log(prefix: Constants.tag, message: "Showing GameCenter Log in view controller.")
                    presenter.present(vc, animated: true)
                } else {
                    GameLogger.shared.log(prefix: Constants.tag, message: "Player is authenticated with GameCenter \(localPlayer.isAuthenticated())")
                    authenicatedSubject.send(localPlayer.isAuthenticated())
                    
                }
            }
        )
    }
    
    /// Saves a profile locally and remotely if the file has progressed further than current loaded profile
    /// Sends the updated profile after saving completes
    public func saveProfile(_ profile: Profile) {
        Publishers.CombineLatest3(
            loadedProfile.last(),
            Just(profile).setFailureType(to: Error.self),
            authenicated
        )
        .print("\(Constants.tag) Save Profile", to: GameLogger.shared)
        .tryFlatMap { [localPlayer, userDefaultClient, fileManagerClient] (loadedProfile, newProfile, isAuthenticated) -> AnyPublisher<Profile, Error> in
            if loadedProfile?.progress ?? 0 <= newProfile.progress {
                GameLogger.shared.log(prefix: Constants.tag, message: "saving new profile")
                return saveProfileLocallyAndRemotely(newProfile, localPlayer: localPlayer, uuidKey: Constants.playerUUIDKey, userDefaultsClient: userDefaultClient, isAuthenticated: isAuthenticated, fileManagerClient: fileManagerClient)
            } else {
                GameLogger.shared.log(prefix: Constants.tag, message: "not saving profile because remote is further")
                throw ProfileError.localProfileHasNotProgressedFurtherThanRemoteProfile
            }
        }
        .subscribe(on: scheduler)
        .receive(on: mainQueue)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let err):
                GameLogger.shared.log(prefix: Constants.tag, message: "Error saving local or remote \(err)")
            case .finished:
                GameLogger.shared.log(prefix: Constants.tag, message: "Successfully created and sync local and remote profiles")
            }
        }, receiveValue: { [loadedProfileSubject] profile in
            loadedProfileSubject.send(profile)
        }).store(in: &disposables)
    }
    
    /// Reset user defaults
    public func resetUserDefaults() {
        userDefaultClient.set(nil, Constants.playerUUIDKey)
    }
    
    /// Delete the local profile
    public func deleteLocalProfile() {
        userDefaultClient
            .fetchPlayerUUID(Constants.playerUUIDKey)
            .eraseToAnyPublisher()
            .print("\(Constants.tag): Delete Local Profile", to: GameLogger.shared)
            .flatMap( { [fileManagerClient] uuid -> Future<Void, Error> in
                return Future { promise in
                    guard let domain =  fileManagerClient.urls(.documentDirectory, .userDomainMask).first else {
                        promise(.failure(ProfileError.failedToDeleteLocalProfile))
                        return
                    }
                    let pathURL = domain.appendingPathComponent(uuid)
                    do {
                        try fileManagerClient.removeItem(pathURL)
                        promise(.success(()))
                    }
                    catch {
                        promise(.failure(ProfileError.failedToDeleteLocalProfile))
                    }
                }
            }).eraseToAnyPublisher()
            .subscribe(on: scheduler)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &disposables)
        
    }
    
    /// Delete all profiles saved in GameKit
    public func deleteAllRemoteProfile() {
        localPlayer
            .fetchGCSavedGames()
            .print("\(Constants.tag) Deleting Saved Games", to: GameLogger.shared)
            .flatMap({ games in
                return games
                    .publisher /// Turns array of objects into publisher.
                    .setFailureType(to: Error.self) // Sets the failure type for type consistentency, otherwise this would have error type Never
            })
            .tryFlatMap( { [localPlayer] game -> Future<Bool, Error>  in
                return localPlayer.deleteGame(game.name ?? "")
            })
            .eraseToAnyPublisher()
            .subscribe(on: scheduler)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &disposables)
    }
    
    
    
}

func saveProfileLocallyAndRemotely(_ profile: Profile, localPlayer: PlayerClient, uuidKey: String, userDefaultsClient: UserDefaultClient, isAuthenticated: Bool, fileManagerClient: FileManagerClient) -> AnyPublisher<Profile, Error> {
        
    let ignoreUnauthenicatedGameCenter = saveProfileRemotely(profile, localPlayer: localPlayer).catch {
        error in
        return Future<Profile, Error> { promise in
            if (!isAuthenticated) { promise(.success(profile)) }
            else { promise(.failure(error)) }
        }
    }

    return
        Publishers.Merge(
            saveProfileLocally(profile, uuidKey: uuidKey, userDefaultsClient: userDefaultsClient, fileManagerClient: fileManagerClient),
            ignoreUnauthenicatedGameCenter
        )
        .eraseToAnyPublisher()
}

/// Saves the profile remotely
/// Uses a JSON encoder to save the data
func saveProfileRemotely(_ profile: Profile, localPlayer: PlayerClient) -> Future<Profile, Error> {
    return Future { promise in
        GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Saving profile to GameCenter")
        
        let name = profile.name
        do {
            let data = try JSONEncoder().encode(profile)
            localPlayer.saveGameData(data, name) { (savedGame, error) in
                if let error = error {
                    GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Error saving game file in Game Center with name \(name) due to error \(error)")
                    promise(.failure(ProfileError.failureToSaveRemoteProfile(error)))
                } else {
                    GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Successfully save game file with name \(name)")
                    promise(.success(profile))
                }
            }
        } catch {
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Failed to encode profile with error: \(error)")
            promise(.failure(ProfileError.failureToSaveRemoteProfile(error)))
        }
    }
}

func loadSavedGame(_ savedGame: GKSavedGame) -> Future<Profile?, Error> {
    return Future { promise in
        savedGame.loadData { (data, error) in
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(Profile.self, from: data)
                    promise(.success(profile))
                } catch {
                    promise(.failure(ProfileError.failedToLoadRemoteProfile(error)))
                }
            } else {
                promise(.failure(ProfileError.failedToLoadRemoteProfile(error)))
            }
        }
    }
}

func loadLocalProfile(pathPrefix: String, name: String, fileManagerClient: FileManagerClient) -> Future<Profile?, Error> {
    return Future { promise in
        guard let domain =  fileManagerClient.urls(.documentDirectory, .userDomainMask).first else {
            promise(.failure(ProfileError.failedToAccessLocalDirectory))
            return
        }
        let pathURL = domain.appendingPathComponent(name)
        GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Attempt to load file at \(pathURL)")
        
        do {
            let data = try Data(contentsOf: pathURL)
            let profile = try JSONDecoder().decode(Profile.self, from: data)
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Successfully loaded local file \(profile)")
            promise(.success(profile))
        }
        catch let err {
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Failed to load local profile \(err)")
            promise(.failure(ProfileError.failedToLoadProfile))
        }
    }
}



/// Create a data file from the local tempate file called "newProfile"
/// Also is responsible for saving the UUID in User Defaults
func createLocalProfile(playerUUIDKey: String, userDefaultClient: UserDefaultClient, fileManagerClient: FileManagerClient) -> Future<Profile, Error> {
    return Future { promise in
        let uuid = UUID().uuidString
        guard let domain =  fileManagerClient.urls(.documentDirectory, .userDomainMask).first else {
            promise(.failure(ProfileError.failedToAccessLocalDirectory))
            return
        }
        let pathURL = domain.appendingPathComponent(uuid)
        
        GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Attempt to save file path string at \(pathURL.path)")
        
        /// The file doesnt exist, so let's create one
        do {
            guard let newPlayerProfile = try Data.data(from: "newProfile") else {
                promise(.failure(ProfileError.failedToCreateLocalProfile))
                return
            }
            let profile = try JSONDecoder().decode(Profile.self, from: newPlayerProfile)
            /// save the profile with the uuid as the name
            /// copy all other defaults
            let newProfile = Profile(name: uuid, progress: profile.progress, player: profile.player, deepestDepth: profile.deepestDepth)
            
            /// encode the new profile into data
            let jsonData = try JSONEncoder().encode(newProfile)
            
            /// write that data to file
            try jsonData.write(to: pathURL)
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Successfully saved file at path \(pathURL.path)")
            
            /// make sure we set this to the user defaults
            userDefaultClient.set(uuid, playerUUIDKey)
            
            promise(.success(newProfile))
        } catch let err {
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Failed to save file at path \(pathURL)")
            promise(.failure(ProfileError.failedToSaveLocalProfile(err)))
        }
    }
}

/// Takes a Profile and saves it locally.
/// Also overwrites the UserDefaults key
func saveProfileLocally(_ profile: Profile, uuidKey: String, userDefaultsClient: UserDefaultClient, fileManagerClient: FileManagerClient) -> Future<Profile, Error> {
    return Future { promise in
        let uuid = profile.name
        guard let domain = fileManagerClient.urls(.documentDirectory, .userDomainMask).first else {
            promise(.failure(ProfileError.failedToAccessLocalDirectory))
            return
        }
        let pathURL = domain.appendingPathComponent(uuid)
        GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Attempt to save file locally at path \(pathURL.path)")
        
        do {
            let data = try JSONEncoder().encode(profile)
            try data.write(to: pathURL)
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Successfully saved file locally at path \(pathURL.path)")
            
            /// make sure we set this to the user defaults
            userDefaultsClient.set(uuid, uuidKey)
            
            promise(.success(profile))
        } catch let err {
            GameLogger.shared.log(prefix: ProfileViewModel.Constants.tag, message: "Failed to save file locally at path \(pathURL)")
            promise(.failure(ProfileError.failedToSaveLocalProfile(err)))
        }
    }
}
