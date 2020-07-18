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

extension Publisher {
    func tryFlatMap<Pub: Publisher>(
        _ transform: @escaping (Output) throws -> Pub
    ) -> Publishers.FlatMap<AnyPublisher<Pub.Output, Error>, Self> {
        return flatMap({ input -> AnyPublisher<Pub.Output, Error> in
            do {
                return try transform(input)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(outputType: Pub.Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
        })
    }
}

struct Profile: Codable {
    let name: String
    let progress: Int
}

typealias ProfileResult = (Result<Profile, ProfileError>) -> Void

protocol ProfileSaving {
    func start(_ presenter: UIViewController)
    func resetUserDefaults()
    func deleteLocalProfile()
    func deleteRemoteProfile()
}

enum ProfileError: Error {
    case fileWithNameAlreadyExists
    case saveError(Error)
    case failedToLoadProfile
    case failedToLoadLocalProfile
    case failedToSaveLocalProfile(Error?)
    case noUserDefaultsValue
    case loadProfileCancelled
    case failedToLoadRemoteProfile(Error?)
    case failedToCreateLocalProfile
    case failedToCreateRemoteProfile
    case failedToDeleteLocalProfile
    case noNeedToCreateNewProfile
    case failedToResolveProfiles
    case needToCreateNewProfile
}

extension GKLocalPlayer {
    func fetchGCSavedGames() -> Future<[GKSavedGame], Error> {
        return Future { promise in
            GKLocalPlayer.local.fetchSavedGames { (savedGames, error) in
                if let err = error {
                    promise(.failure(err))
                } else {
                    promise(Result.success(savedGames ?? []))
                }
            }
            
        }
    }
}

class ProfileViewModel: ProfileSaving {
    
    struct Constants {
        static let playerUUIDKey = "playerUUID"
        static let saveFilePath = NSHomeDirectory()
        static let tempFilePath = NSTemporaryDirectory()
    }
    
    private lazy var authenicatedSubject = PassthroughSubject<Bool, Error>()
    lazy var authenicated = authenicatedSubject.eraseToAnyPublisher()
    
    private lazy var savedGames = PassthroughSubject<[GKSavedGame], Error>()
    
    private var disposables = Set<AnyCancellable>()
    
    //Saved games
    private var gameCenterSavedGame = PassthroughSubject<GKSavedGame?, Error>()
    private var localSavedGame = PassthroughSubject<Profile?, Error>()
    
    private lazy var loadedGameSubject = PassthroughSubject<GKSavedGame, Error>()
    lazy var savedGame = loadedGameSubject.eraseToAnyPublisher()
    
    func start(_ presenter: UIViewController) {
        
        /// Load the remote save file into data
        let loadRemoteData =
            GKLocalPlayer.local.fetchGCSavedGames()
                .print("load remote data")
                .combineLatest(authenicated.map { _ in })
                .eraseToAnyPublisher()
                .flatMap { [weak self] (savedGames, _) -> Future<Profile?, Error> in
                    guard let self = self, let game = savedGames.first else {
                        //TODO figure out how to do this more succintly
                        return Future { promise in
                            promise(.failure(ProfileError.failedToLoadProfile))
                        }
                    }
                    
                    return self.loadSavedGame(game)
            }
            .eraseToAnyPublisher()
        
        /// Store the pipeline to fetch the UUID from user defaults and attempt to load the local profile
        let loadLocalProfile =
            fetchPlayerUUID()
                .print("fetch local game files")
                .flatMap { [weak self] (uuid) -> Future<Profile?, Error> in
                    guard let self = self else {
                        //TODO figure out how to do this more succintly
                        return Future { promise in promise(.failure(ProfileError.failedToLoadLocalProfile))
                        }
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
        
        /// During this flow, we may need to save to the local directory
        let createNewPlayerProfile: AnyPublisher<Void, Error>  =
            loadedProfilesZip
                .tryMap({ (saveFiles) in
                    let (remote, local) = saveFiles
                    if remote == nil && local == nil {
                        return ()
                    } else {
                        throw ProfileError.noNeedToCreateNewProfile
                    }
                })
                .eraseToAnyPublisher()
        
        /// Creates a new player profile locally and then saves it remotely
        let createAndSavePlayerProfile = createNewPlayerProfile
            .eraseToAnyPublisher()
            .print("Create new player profile")
            .tryFlatMap( { [weak self] shouldSave -> Future<Profile, Error> in
                guard let self = self else {
                    throw ProfileError.failedToCreateLocalProfile
                }
                return self.createLocalProfile()
            })
            .tryFlatMap( { [weak self] nameData -> Future<Profile, Error> in
                guard let self = self else {
                    throw ProfileError.failedToCreateRemoteProfile
                }
                return self.saveProfileRemotely(nameData)
            })
            .catch { [weak self] error -> Future<Profile, Error> in
                print("Error creating  \(error)")
                return self!.saveProfileRemotely(Profile(name:"billy", progress: 2))
            }
            .eraseToAnyPublisher()
        
        let resolveProfileConflict: AnyPublisher<Profile, Error> =
            loadedProfilesZip
                .eraseToAnyPublisher()
                .tryMap ({ (saveFiles) in
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
                        throw ProfileError.needToCreateNewProfile
                    }
                })
                .catch({ error in
                    return createAndSavePlayerProfile
                })
                .eraseToAnyPublisher()
        
        
        /// Zip together the local and remote data. Erase errors to .success(nil) so the main body still executes
        /// Mostly debug right now
        loadedProfilesZip
            .print("loaded data pipeline")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    preconditionFailure("This shouldnt be possible as we erase all errors in the Publishers.Zip. \(error)")
                    ()
                }
            }) { (data) in
                let (savedGame, profile) = data
                switch (savedGame, profile) {
                case (.none, .none):
                    print("branch new player")
                case (.some, .none):
                    print("Have remote.  No local")
                case (.none, .some):
                    print("Have local.  No remote")
                case (.some, .some):
                    print("Have both remote and local")
                }
        }.store(in: &disposables)
        
        

        
        resolveProfileConflict
            .print("Resolving profile conflicts")
            .tryFlatMap { [weak self] (profile) -> Future<Profile, Error> in
                guard let self = self else { throw ProfileError.failedToResolveProfiles }
                return self.saveProfileLocally(profile)
            }
            .tryFlatMap { [weak self] (profile) -> Future<Profile, Error> in
                guard let self = self else { throw ProfileError.failedToResolveProfiles }
                return self.saveProfileRemotely(profile)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    print("Error saving local or remote \(err)")
                case .finished:
                    print("Successfully created and sync local and remote profiles")
                }
            }, receiveValue: { _ in })
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
//        return Future { promise in promise(.success("C53421AE-4C82-489E-AA79-3A32C21D798E"))}
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
    
    /// Saves a data file locally
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
                let newProfile = Profile(name: uuid, progress: profile.progress)
                
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
                        promise(.failure(ProfileError.saveError(error)))
                    } else {
                        print("Successfully save game file with name \(name)")
                        promise(.success(profile))
                    }
                }
            } catch {
                print("Failed to encode profile")
                promise(.failure(ProfileError.saveError(error)))
            }
        }
    }
    
    
    public func resetUserDefaults() {
        UserDefaults.standard.set(nil, forKey: Constants.playerUUIDKey)
    }
    
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
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &disposables)

    }
    
     public func deleteRemoteProfile() {
        fetchPlayerUUID()
        .eraseToAnyPublisher()
        .print("Delete Remote Profile")
        .flatMap( { uuid -> Future<Void, Error> in
            return Future { promise in
                GKLocalPlayer().deleteSavedGames(withName: uuid) { (error) in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        })
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &disposables)
    }
    
}
