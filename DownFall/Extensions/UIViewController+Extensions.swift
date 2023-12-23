//
//  UIViewController+Extensions.swift
//  DownFall
//
//  Created by Billy on 9/13/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import UIKit

extension UIViewController
{
    func bottomBlack()
    {
        let colorBottomBlack = UIView()
        view.addSubview(colorBottomBlack)
        colorBottomBlack.translatesAutoresizingMaskIntoConstraints = false
        colorBottomBlack.backgroundColor = .black
        
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

