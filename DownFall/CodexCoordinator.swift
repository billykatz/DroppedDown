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

extension UIViewController
{
    func bottomBlack()
    {
        let colorBottomBlack = UIView()
        view.addSubview(colorBottomBlack)
        colorBottomBlack.translatesAutoresizingMaskIntoConstraints = false
        colorBottomBlack.backgroundColor = .backgroundGray
        
        let colorTopBlack = UIView()
        view.addSubview(colorTopBlack)
        colorTopBlack.translatesAutoresizingMaskIntoConstraints = false
        colorTopBlack.backgroundColor = .backgroundGray
        
        NSLayoutConstraint.activate([
            colorBottomBlack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            colorBottomBlack.widthAnchor.constraint(equalTo: view.widthAnchor),
            colorBottomBlack.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            colorTopBlack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            colorTopBlack.widthAnchor.constraint(equalTo: view.widthAnchor),
            colorTopBlack.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
    }
}


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
        
        viewController.pushViewController(hostingViewController, animated: true)
    }
    
    func updateUnlockable(_ unlockables: [Unlockable]) {
        profileViewModel?.updateUnlockables(unlockables)
    }
}
