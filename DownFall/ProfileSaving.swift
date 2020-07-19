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

struct Profile: Codable {
    let name: String
    let progress: Int
    let player: EntityModel
}

protocol ProfileSaving {
    /// Call this when the app is loaded into memory
    func start(_ presenter: UIViewController)
    
    /// Resets user defaults. Only do this when resetting the player's data
    func resetUserDefaults()
    
    /// Deletes the local profile file. Only do this when resetting the player's data. This only works if we have the UUID from User Defaults
    func deleteLocalProfile()
    
    /// Deletes all the remote files in Game Center.  I
    func deleteAllRemoteProfile()
    
    /// Emits the profile that should be loaded and use to player the game
    var loadedProfile: AnyPublisher<Profile, Error> { get }
    
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
    case failedToSaveLocalProfile(Error?)
    case failureToSaveRemoteProfile(Error)
    case failedToLoadRemoteProfile(Error?)
}

class ProfileViewModel: ProfileSaving {
    
    struct Constants {
        static let playerUUIDKey = "playerUUID"
        static let saveFilePath = NSHomeDirectory()
        static let tempFilePath = NSTemporaryDirectory()
    }
    
    /// Gets sent the loaded profile
    private lazy var loadedProfileSubject = PassthroughSubject<Profile, Error>()
    /// Public interface with the loaded profile
    lazy var loadedProfile = loadedProfileSubject.eraseToAnyPublisher()
    
    /// Gets sent the authenication status of the GKLocalPlayer
    private lazy var authenicatedSubject = PassthroughSubject<Bool, Error>()
    private lazy var authenicated = authenicatedSubject.eraseToAnyPublisher()
    
    /// The dispose bag
    private var disposables = Set<AnyCancellable>()
    
    /// Background Queue
    private var backgroundQueue = DispatchQueue.init(label: "profile-saving-thread", qos: .userInitiated, attributes: .concurrent)
    
    /// Defines all business logic and kickoffs the pipeline by attempting to authenicate with GameCenter
    func start(_ presenter: UIViewController) {
        
        /// Load the remote save file into data
        let loadRemoteData =
            GKLocalPlayer.local.fetchGCSavedGames()
                .print("load remote data")
                .combineLatest(authenicated.map { _ in })
                .eraseToAnyPublisher()
                .tryFlatMap { [weak self] (savedGames, _) -> Future<Profile?, Error> in
                    guard let self = self, let game = savedGames.first else {
                        throw ProfileError.failedToLoadRemoteProfile(nil)
                    }
                    
                    return self.loadSavedGame(game)
            }
            .eraseToAnyPublisher()
        
        /// Store the pipeline to fetch the UUID from user defaults and attempt to load the local profile
        let loadLocalProfile =
            fetchPlayerUUID()
                .print("fetch local game files")
                .tryFlatMap { [weak self] (uuid) -> Future<Profile?, Error> in
                    guard let self = self else {
                        throw ProfileError.failedToLoadLocalProfile
                    }
                    return self.loadLocalProfile(name: uuid)
            }
            .eraseToAnyPublisher()
        
        /// load remote and local publisher
        let loadedProfilesZip = Publishers.Zip(
            loadRemoteData
                .eraseToAnyPublisher()
                .replaceError(with: nil),
            loadLocalProfile
                .eraseToAnyPublisher()
                .replaceError(with: nil)
        )
        
        /// Creates a new player profile locally and then saves it remotely
        let createAndSavePlayerProfile =
            self.createLocalProfile()
                .eraseToAnyPublisher()
                .print("Create new and save player profile")
                .tryFlatMap( { [weak self] nameData -> Future<Profile, Error> in
                    guard let self = self else {
                        throw ProfileError.profileLoadCancelled
                    }
                    return self.saveProfileRemotely(nameData)
                })
                .eraseToAnyPublisher()
        
        let resolveProfileConflict: AnyPublisher<Profile, Error> =
            loadedProfilesZip
                .eraseToAnyPublisher()
                .tryMap ({ (saveFiles)  in
                    let (remote, local) = saveFiles
                    if remote == nil , let local = local {
                        /// load the local profile
                        return local
                    } else if local == nil, let remote = remote {
                        /// load the remote file
                        return remote
                    } else if let remote = remote, let local = local  {
                        /// load the file which has more progress
                        /// if there is a tie, then load the remote one
                        return remote.progress >= local.progress ? remote: local
                    } else {
                        /// this is likely a new player and needs to save a new profile
                        throw ProfileError.failedToResolveProfiles
                    }
                })
                .catch( { error in
                    return createAndSavePlayerProfile
                })
                .eraseToAnyPublisher()
        
        /// Resolves the profile conflict
        /// re-saves the profiles locally and remotely
        /// Writes to loadedProfileSubject on success
        resolveProfileConflict
            .print("Resolving profile conflicts")
            .tryFlatMap { [weak self] (profile) -> Future<Profile, Error> in
                guard let self = self else { throw ProfileError.profileLoadCancelled }
                return self.saveProfileLocally(profile)
            }
            .tryFlatMap { [weak self] (profile) -> Future<Profile, Error> in
                guard let self = self else { throw ProfileError.profileLoadCancelled }
                return self.saveProfileRemotely(profile)
            }
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    print("Error saving local or remote \(err)")
                case .finished:
                    print("Successfully created and sync local and remote profiles")
                }
            }, receiveValue: { [weak self] profile in
                self?.loadedProfileSubject.send(profile)
            })
            .store(in: &disposables)
        
        /// Start the authenicated process
        print("Starting to authenticate with game center")
        GKLocalPlayer().authenticateHandler = { [weak self] viewController, error in
            print("Authenitcation handler. Authenticated: \(GKLocalPlayer.local.isAuthenticated)")
            if let vc = viewController {
                presenter.present(vc, animated: true)
            } else {
                self?.authenicatedSubject.send(GKLocalPlayer.local.isAuthenticated)
            }
        }
    }
    
    /// Saves a profile locally and remotely if the file has progressed further than current loaded profile
    /// Sends the updated profile after saving completes
    public func saveProfile(_ profile: Profile) {
        Publishers.CombineLatest(loadedProfile, Just(profile).setFailureType(to: Error.self))
            .tryFlatMap { [weak self](loadedProfile, newProfile) -> Future<Profile, Error> in
                guard let self = self else { throw ProfileError.profileLoadCancelled }
                if loadedProfile.progress < newProfile.progress {
                    return self.saveProfileLocally(newProfile)
                } else {
                    throw ProfileError.failedToDeleteLocalProfile
                }
        }
        .tryFlatMap { [weak self] (profile) -> Future<Profile, Error> in
            guard let self = self else { throw ProfileError.profileLoadCancelled }
            return self.saveProfileRemotely(profile)
        }
        .subscribe(on: backgroundQueue)
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let err):
                print("Error saving local or remote \(err)")
            case .finished:
                print("Successfully created and sync local and remote profiles")
            }
        }, receiveValue: { [weak self] profile in
            self?.loadedProfileSubject.send(profile)
        }).store(in: &disposables)
    }
    
    /// Reset user defaults
    public func resetUserDefaults() {
        UserDefaults.standard.set(nil, forKey: Constants.playerUUIDKey)
    }
    
    /// Delete the local profile
    public func deleteLocalProfile() {
        fetchPlayerUUID()
            .eraseToAnyPublisher()
            .print("Delete Local Profile")
            .flatMap( { uuid -> Future<Void, Error> in
                return Future { promise in
                    guard let domain =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        promise(.failure(ProfileError.failedToDeleteLocalProfile))
                        return
                    }
                    let pathURL = domain.appendingPathComponent(uuid)
                    do {
                        try FileManager.default.removeItem(at: pathURL)
                        promise(.success(()))
                    }
                    catch {
                        promise(.failure(ProfileError.failedToDeleteLocalProfile))
                    }
                }
            }).eraseToAnyPublisher()
            .subscribe(on: backgroundQueue)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &disposables)
        
    }
    
    /// Delete all profiles saved in GameKit
    public func deleteAllRemoteProfile() {
        GKLocalPlayer
            .local
            .fetchGCSavedGames()
            .print("Deleting Saved Games")
            .flatMap({ games in
                return games.publisher.setFailureType(to: Error.self)
            })
            .flatMap( { game in
                return GKLocalPlayer.local.deleteGame(game)
            })
            .eraseToAnyPublisher()
            .subscribe(on: backgroundQueue)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &disposables)
    }
    
    /// Loads a local profile from the App's Directory
    private func loadLocalProfile(name: String) -> Future<Profile?, Error> {
        let path = "\(Constants.saveFilePath)\(name)"
        print("Creation of Future to load file at \(path)")
        return Future { promise in
            guard let domain =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                promise(.failure(ProfileError.failedToSaveLocalProfile(nil)))
                return
            }
            let pathURL = domain.appendingPathComponent(name)
            print("Attempt to load file at \(pathURL)")
            
            do {
                let data = try Data(contentsOf: pathURL)
                let profile = try JSONDecoder().decode(Profile.self, from: data)
                print("Successfully loaded local file \(profile)")
                promise(.success(profile))
            }
            catch let err {
                print("Failed to load local profile \(err)")
                promise(.failure(ProfileError.failedToLoadProfile))
            }
        }
    }
    
    
    
    /// Returns the UUID saved in UserDefaults or an error if no UserDefaults exists
    private func fetchPlayerUUID() -> Future<String, Error> {
        return Future { promise in
            if let playerUUID = UserDefaults.standard.string(forKey: Constants.playerUUIDKey) { promise(.success(playerUUID))
            } else {
                promise(.failure(ProfileError.noUserDefaultsValue))
            }
        }
    }
    
    
    /// Returns the data associated in a GKSaveGame file
    private func loadSavedGame(_ savedGame: GKSavedGame) -> Future<Profile?, Error> {
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
    
    /// Takes a Profile and saves it locally.
    /// Also overwrites the UserDefaults key
    private func saveProfileLocally(_ profile: Profile) -> Future<Profile, Error> {
        return Future { promise in
            let uuid = profile.name
            guard let domain = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                promise(.failure(ProfileError.failedToSaveLocalProfile(nil)))
                return
            }
            let pathURL = domain.appendingPathComponent(uuid)
            print("Attempt to save file path string at \(pathURL.path)")
            
            do {
                let data = try JSONEncoder().encode(profile)
                try data.write(to: pathURL)
                print("Successfully saved file at path \(pathURL.path)")
                
                /// make sure we set this to the user defaults
                UserDefaults.standard.set(uuid, forKey: Constants.playerUUIDKey)
                
                promise(.success(profile))
            } catch let err {
                print("Failed to save file at path \(pathURL)")
                promise(.failure(ProfileError.failedToSaveLocalProfile(err)))
            }
        }
    }
    
    /// Create a data file from the local tempate file called "newProfile"
    /// Also is responsible for saving the UUID in User Defaults
    private func createLocalProfile() -> Future<Profile, Error> {
        return Future { promise in
            let uuid = UUID().uuidString
            guard let domain =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                promise(.failure(ProfileError.failedToSaveLocalProfile(nil)))
                return
            }
            let pathURL = domain.appendingPathComponent(uuid)
            print("Attempt to save file path string at \(pathURL.path)")
            
            /// The file doesnt exist, so let's create one
            do {
                guard let newPlayerProfile = try Data.data(from: "newProfile") else {
                    promise(.failure(ProfileError.failedToSaveLocalProfile(nil)))
                    return
                }
                let profile = try JSONDecoder().decode(Profile.self, from: newPlayerProfile)
                /// save the profile with the uuid as the name
                /// copy all other defaults
                let newProfile = Profile(name: uuid, progress: profile.progress, player: profile.player)
                
                /// encode the new profile into data
                let jsonData = try JSONEncoder().encode(newProfile)
                
                /// write that data to file
                try jsonData.write(to: pathURL)
                print("Successfully saved file at path \(pathURL.path)")
                
                /// make sure we set this to the user defaults
                UserDefaults.standard.set(uuid, forKey: Constants.playerUUIDKey)
                
                promise(.success(newProfile))
            } catch let err {
                print("Failed to save file at path \(pathURL)")
                promise(.failure(ProfileError.failedToSaveLocalProfile(err)))
            }
        }
    }
    
    
    /// Saves the profile remotely
    /// Uses a JSON encoder to save the data
    private func saveProfileRemotely(_ profile: Profile) -> Future<Profile, Error> {
        return Future { promise in
            print("Saving profile to GameCenter")
            
            let localPlayer = GKLocalPlayer()
            let name = profile.name
            do {
                let data = try JSONEncoder().encode(profile)
                localPlayer.saveGameData(data, withName: name) { (savedGame, error) in
                    if let error = error {
                        print("Error saving game file in Game Center with name \(name)")
                        promise(.failure(ProfileError.failureToSaveRemoteProfile(error)))
                    } else {
                        print("Successfully save game file with name \(name)")
                        promise(.success(profile))
                    }
                }
            } catch {
                print("Failed to encode profile")
                promise(.failure(ProfileError.failureToSaveRemoteProfile(error)))
            }
        }
    }
    
}
