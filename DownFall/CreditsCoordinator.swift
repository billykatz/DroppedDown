//
//  CreditsCoordinator.swift
//  DownFall
//
//  Created by Billy on 3/11/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


class CreditsCoordinator {
    
    private let navigationController: UINavigationController
    var profileViewModel: ProfileViewModel?
    
    init(viewController: UINavigationController) {
        self.navigationController = viewController
        
        self.navigationController.navigationBar.barTintColor = .backgroundGray
        self.navigationController.navigationBar.tintColor = .white
        self.navigationController.navigationBar.isTranslucent = false
        
    }
    
    func presentCredits() {
        let creditsView = CreditsView()
        
        let hostingViewController = UIHostingController(rootView: creditsView)
        hostingViewController.bottomBlack()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Credits"
        titleLabel.textAlignment = .center
        titleLabel.font = .bigTitleCodexFont
        
        
        hostingViewController.navigationItem.titleView = titleLabel
        
        navigationController.setNavigationBarHidden(false, animated:true)
        navigationController.pushViewController(hostingViewController, animated: true)
    }
    
    
}
