//
//  Publishers+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 7/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

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

