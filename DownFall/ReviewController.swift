//
//  ReviewController.swift
//  DownFall
//
//  Created by Billy on 3/13/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import StoreKit

extension UserDefaults {
    static let lastReviewRequestAppVersion = "lastReviewRequestAppVersion"
}

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
        
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: UserDefaults.lastReviewRequestAppVersion)
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        defaults.set(currentVersion, forKey: UserDefaults.lastReviewRequestAppVersion)
        
        SKStoreReviewController.requestReviewInCurrentScene()
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}
