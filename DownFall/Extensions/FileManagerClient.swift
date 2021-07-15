//
//  FileManagerClient.swift
//  DownFall
//
//  Created by Billy on 6/25/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct FileManagerClient {
    var urls: (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask) -> [URL]
    var removeItem: (URL) throws -> ()
}

extension FileManagerClient {
    static let live = Self { directory, options in
        return FileManager.default.urls(for: directory, in: options)
    } removeItem: { url in
        return try FileManager.default.removeItem(at: url)
    }
    
    static let test = Self { directory, options in
        return [URL(fileURLWithPath: "test/path/for/tests")]
    } removeItem: { url in
        return
    }

}
