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


protocol CodexCoordinatorDelegate: AnyObject {
    func startRunPressed()
}

class CodexCoordinator {
    
    private let navigationController: UINavigationController
    var profileViewModel: ProfileViewModel?
    private weak var delegate: CodexCoordinatorDelegate?
    
    init(viewController: UINavigationController, delegate: CodexCoordinatorDelegate?) {
        self.navigationController = viewController
        self.delegate = delegate
        
        self.navigationController.navigationBar.barTintColor = .backgroundGray
        self.navigationController.navigationBar.tintColor = .white
        self.navigationController.navigationBar.isTranslucent = false
        
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
        titleLabel.font = .bigTitleCodexFont
        
        
        hostingViewController.navigationItem.titleView = titleLabel
        navigationController.pushViewController(hostingViewController, animated: true)
    }
    
    func updateUnlockable(_ unlockable: Unlockable) {
        profileViewModel?.purchaseUnlockables(unlockable)
    }
    
    func didTapOn(_ unlockable: Unlockable) {
        profileViewModel?.didTapOnUnlockable(unlockable)
    }
    
    func startRunPressed() {
        //        hostingViewController.dismiss(animated: true)
        navigationController.popViewController(animated: true)
        delegate?.startRunPressed()
    }
}
