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
    func saveGameCenterProfile(name: String, overwriteFile: Bool, completion: @escaping ProfileResult)
    func loadGameCenterProfile(name: String, completion: @escaping ProfileResult)
    func createOrloadLocalProfile(name: String, completion: @escaping ProfileResult)
    func authenticate(_ presenter: UIViewController, _ handler: @escaping ProfileResult)
    func resetUserDefaults()
    
    func deleteLocalProfile()
    func deleteRemoteProfile()
    
    /// Call this method after attempting to authenticate with GameCenter
    func createOrLoadPlayerId(_ handler: @escaping ProfileResult)
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
                        throw ProfileError.failedToLoadProfile
                    }
                })
                .eraseToAnyPublisher()
        
        
        /// Zip together the local and remote data. Erase errors to .success(nil) so the main body still executes
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
        
        
        /// Creates a new player profile locally and then saves it remotely
        createNewPlayerProfile
            .eraseToAnyPublisher()
            .print("Create new player profile")
            .tryFlatMap( { [weak self] shouldSave -> Future<(String, Data), Error> in
                guard let self = self else {
                    throw ProfileError.failedToCreateLocalProfile
                }
                return self.createLocalProfile()
            })
            .tryFlatMap( { [weak self] nameData -> Future<Void, Error> in
                guard let self = self else {
                    throw ProfileError.failedToCreateRemoteProfile
                }
                return self.saveProfileRemotely(nameData)
            })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    print("Error saving local or remote \(err)")
                case .finished:
                    print("Successfully create new player profile")
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
    func loadLocalProfile(name: String) -> Future<Profile?, Error> {
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
                promise(.success(profile))
            }
            catch let err {
                print("Failed to load local profile \(err)")
                promise(.failure(ProfileError.failedToLoadProfile))
            }
        }
    }
    
    
    
    /// Returns the UUID saved in UserDefaults or an error if no UserDefaults exists
    func fetchPlayerUUID() -> Future<String, Error> {
//        return Future { promise in promise(.success("C53421AE-4C82-489E-AA79-3A32C21D798E"))}
        return Future { promise in
            if let playerUUID = UserDefaults.standard.string(forKey: Constants.playerUUIDKey) { promise(.success(playerUUID))
            } else {
                promise(.failure(ProfileError.noUserDefaultsValue))
            }
        }
    }
    
    
    /// Returns the data associated in a GKSaveGame file
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
    
    /// Saves a data file locally
    func createLocalProfile() -> Future<(String, Data), Error> {
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
                let jsonData = try JSONEncoder().encode(profile)
                try jsonData.write(to: pathURL)
                print("Successfully saved file at path \(pathURL.path)")
                
                /// make sure we set this to the user defaults
                UserDefaults.standard.set(uuid, forKey: Constants.playerUUIDKey)
                
                promise(.success((uuid, newPlayerProfile)))
            } catch let err {
                print("Failed to save file at path \(pathURL)")
                promise(.failure(ProfileError.failedToSaveLocalProfile(err)))
            }
        }
    }
    
    func saveProfileRemotely(_ nameData: (String, Data)) -> Future<Void, Error> {
        return Future { promise in
            print("Saving profile to GameCenter")
            
            let localPlayer = GKLocalPlayer()
            let (name, data) = nameData
                localPlayer.saveGameData(data, withName: name) { (savedGame, error) in
                    if let error = error {
                        print("Error saving game file in Game Center with name \(name)")
                    promise(.failure(ProfileError.saveError(error)))
                } else {
                    print("Successfully save game file with name \(name)")
                    promise(.success(()))
                }
            }
        }
    }
    
    
    func authenticate(_ presenter: UIViewController, _ handler: @escaping ProfileResult) {
        print("Starting to authenticate with game center")
        GKLocalPlayer().authenticateHandler = { [weak self] viewController, error in
            if let vc = viewController {
                presenter.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("we are authenticated")
                self?.createOrLoadPlayerId(handler)
            } else {
                /// We may want to do different things
                self?.createOrLoadPlayerId(handler)
                print("disable GameCenter")
            }
        }
    }
    
    /// Loads a player's save file if they have one
    /// If this is a brand new player or one who has reset their data, we create one
    func createOrLoadPlayerId(_ handler: @escaping ProfileResult) {
        resetUserDefaults()
        if let playerUUID = UserDefaults.standard.string(forKey: Constants.playerUUIDKey) {
            print("Player UUID in UserDefaults \(playerUUID)")
            //            deleteGameCenterFiles(name: playerUUID)
            loadGameCenterProfile(name: playerUUID, completion: handler)
        } else {
            print("No player uuid in user defaults")
            /// First we want to check if a game exists for this player
            /// It is possible they have played before ona diferent device and we just need to load their profile from GameCenter.
            loadGameCenterProfile(name: "", completion: handler)
        }
    }
    
    /// Save the profile to the GameCenter and Locally
    func saveGameCenterProfile(name: String, overwriteFile: Bool = false, completion: @escaping ProfileResult) {
        
        print("Saving profile to GameCenter")
        
        let localPlayer = GKLocalPlayer()
        let fauxData = name.data(using: .utf8)!
        
        /// Fetch the save games to see if there are any other games with the same name
        localPlayer.fetchSavedGames { (savedGames, error) in
            guard error == nil else {
                // TODO: save the game locally
                print("Error fetching games prior to saving \(String(describing: error))")
                completion(.failure(.saveError(error!)))
                return
            }
            
            /// Check if a profile already exists with the name
            savedGames?
                .filter({ (game) -> Bool in
                    return game.name == name
                })
                .forEach { game in
                    if !overwriteFile {
                        print("Save game files already exists \(String(describing: error))")
                        completion(.failure(.fileWithNameAlreadyExists))
                        return
                    }
            }
            
            // TODO make sure we dont overwrite save files
            
            print("Saving game file with name \(name)")
            /// If we have reach this point, we should save the data
            localPlayer.saveGameData(fauxData, withName: name) { [weak self] (savedGame, error) in
                if let error = error {
                    print("Error saving game file in Game Center with name \(name)")
                    completion(.failure(.saveError(error)))
                } else {
                    print("Successfully save game file with name \(name)")
                    //                    let profile = Profile(name: name)
                    //                    completion(.success(profile))
                }
            }
        }
    }
    
    func loadGameCenterProfile(name: String, completion: @escaping ProfileResult) {
        //        print("Fetching saved games from GameCenter")
        //        let localPlayer = GKLocalPlayer()
        //        localPlayer.fetchSavedGames { [weak self] (savedGames, error) in
        //            if error == nil {
        //                if let gameName = savedGames?.first?.name {
        //                    print("Found game withe name \(gameName)")
        //                    completion(.success(Profile(name: gameName)))
        //
        //                    // we want to save the file locally as well so that data is sync between local and remote
        //                    self?.saveLocalProfile(name: name, completion: completion)
        //
        //                    /// make sure we set this to the user defaults
        //                    UserDefaults.standard.set(gameName, forKey: Constants.playerUUIDKey)
        //
        //                } else {
        //                    print("No game found")
        //                    self?.createOrloadLocalProfile(name: name, completion: completion)
        //                }
        //            } else {
        //                /// Attempt to reconcile by loading the local profile
        //                self?.createOrloadLocalProfile(name: name, completion: completion)
        //            }
        //        }
    }
    
    /// Creates or loads a local profile from the App's Directory
    /// Side effects: saves the profile in GameCenter as well
    func createOrloadLocalProfile(name: String, completion: @escaping ProfileResult) {
        //        let path = "\(Constants.saveFilePath)\(name)"
        //        print("Attempt to load file at \(path)")
        //        if let localProfile = FileManager.default.contents(atPath: "\(Constants.saveFilePath)\(name)") {
        //            let string = String(data: localProfile, encoding: .utf8)!
        //            print("Loaded local profile with name \(string)")
        //            completion(.success(.init(name: string)))
        //        } else {
        //            print("Creating save file at path \(path)")
        //            let fauxData = name.data(using: .utf8)!
        //            FileManager.default.createFile(atPath: path, contents: fauxData)
        //            completion(.success(Profile(name: name)))
        //
        //
        //        }
        //
        //        print("attempt to save this remotely to keep everything in sync")
        //        // Either way we want to try to save this profile to keep GameCenter and Local files in sync
        //        saveGameCenterProfile(name: name, completion: completion)
    }
    
    /// Attemps to save a local profile.
    /// If no local profile exists at the path, then this creates a new file at path
    /// If a file does exist, this overwrites the file
    func saveLocalProfile(name: String, completion: @escaping ProfileResult) {
        //
        
    }
    
    func deleteGameCenterFiles(name: String) {
        GKLocalPlayer.local.deleteSavedGames(withName: name, completionHandler: nil)
    }
    
    func deleteLocalFile(name: String) throws {
        let path = "\(Constants.saveFilePath)\(name)"
        return try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        
    }
    
    func resetUserDefaults() {
        UserDefaults.standard.set(nil, forKey: Constants.playerUUIDKey)
    }
    
    func deleteLocalProfile() {
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
    
    func deleteRemoteProfile() {
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
