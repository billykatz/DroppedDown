//
//  ProfileCodingClient+Extensions.swift
//  DownFallTests
//
//  Created by Billy on 7/2/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
@testable import Shift_Shaft

extension ProfileDecodingClient {
    static let test = Self { profileType, data in
        return Profile(name: "test-uuid", progress: 0, player: .zero, currentRun: nil, randomRune: nil, deepestDepth: 0)
    }
    
    static let progress10 = Self { profileType, data in
        return Profile(name: "test-uuid", progress: 10, player: .playerZero, currentRun: nil, randomRune: nil, deepestDepth: 10)
        
    }
}

extension ProfileEncodingClient {
    static let test = Self { profile in
        return Data()
    }
}

extension ProfileCodingClient {
    static let test = Self(
        decoder: .test,
        encoder: .test
    )
}
