//
//  JSONCoding+Extensions.swift
//  DownFall
//
//  Created by Billy on 7/2/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct ProfileDecodingClient {
    var decode: (Profile.Type, Data) throws -> Profile
}

extension ProfileDecodingClient {
    static let live = Self { type, data in
        return try JSONDecoder().decode(type, from: data)
    }
}

struct ProfileEncodingClient {
    var encode: (Profile) throws -> Data
}

extension ProfileEncodingClient {
    static let live = Self { profile in
        return try JSONEncoder().encode(profile)
    }
}

struct ProfileCodingClient {
    var decoder: ProfileDecodingClient
    var encoder: ProfileEncodingClient
}

extension ProfileCodingClient {
    static let live = Self(decoder: .live, encoder: .live)
}
