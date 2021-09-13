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
    var profile: Profile?
    
    init(viewController: UINavigationController) {
        self.viewController = viewController
    }
    
    func presentCodexView(with profile: Profile?) {
        guard let profile = profile else { fatalError("Cannot present CodexView without a profile") }
        
        self.profile = profile
        let viewModel = CodexViewModel(unlockables: Unlockable.debugData, playerData: profile.player, statData: profile.stats)
        let codexView = CodexView(viewModel: viewModel, selectedIndex: 0)
        
        let hostingViewController = UIHostingController(rootView: codexView)
        
        viewController.pushViewController(hostingViewController, animated: true)
    }
}
