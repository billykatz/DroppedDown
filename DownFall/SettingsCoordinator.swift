//
//  SettingsCoordinator.swift
//  DownFall
//
//  Created by Billy on 9/13/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import UIKit
import SwiftUI

class SettingsCoordinator {
    
    private let viewController: UINavigationController
    var profileViewModel: ProfileViewModel?
    var profileLoadingViewModel: ProfileLoadingManager?
    
    init(viewController: UINavigationController) {
        self.viewController = viewController
        
        self.viewController.navigationBar.barTintColor = .backgroundGray
        self.viewController.navigationBar.tintColor = .white
        self.viewController.navigationBar.isTranslucent = false
        
    }
    
    func presentSettingsView(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        
        let settingsView = PlayerStatsView(viewModel: self.profileViewModel!)
        let hostingViewController = UIHostingController(rootView: settingsView)
        hostingViewController.bottomBlack()
        
        viewController.pushViewController(hostingViewController, animated: true)
    }
    
    
}
