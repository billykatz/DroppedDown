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
    
    init(viewController: UINavigationController) {
        self.viewController = viewController
    }
    
    func presentCodexView() {
//        let allOffers = StoreOfferType.allCases.map { StoreOffer.offer(type: $0, tier: 1) }
        let codexView = CodexView(progress: ProgressableModel())
        
        let hostingViewController = UIHostingController(rootView: codexView)
        
//        viewController.modalTransitionStyle = .flipHorizontal
        
        viewController.pushViewController(hostingViewController, animated: true)
    }
}
