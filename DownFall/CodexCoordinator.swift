//
//  CodexCoordinator.swift
//  DownFall
//
//  Created by Billy on 7/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


class CodexCoordinator {
    
    private let viewController: UINavigationController
    var profileViewModel: ProfileViewModel?
    
    init(viewController: UINavigationController) {
        self.viewController = viewController
        
        self.viewController.navigationBar.barTintColor = .backgroundGray
        self.viewController.navigationBar.tintColor = .white
        self.viewController.navigationBar.isTranslucent = false
        
    }
    
    func presentCodexView(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        let viewModel = CodexViewModel(profileViewModel: profileViewModel, codexCoordinator: self)
        let codexView = CodexView(viewModel: viewModel, selectedIndex: 0)
        
        let hostingViewController = UIHostingController(rootView: codexView)
        hostingViewController.bottomBlack()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Basecamp"
        titleLabel.textAlignment = .center
        titleLabel.font = .bigSubtitleCodexFont

        
        hostingViewController.navigationItem.titleView = titleLabel
        
        viewController.pushViewController(hostingViewController, animated: true)
    }
    
    func updateUnlockable(_ unlockable: Unlockable) {
        profileViewModel?.updateUnlockables(unlockable)
    }
}
