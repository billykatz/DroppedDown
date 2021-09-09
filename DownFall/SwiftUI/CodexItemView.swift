//
//  CodexItemView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexItemTitleView: View {
    
    let font = UIFont(name: UIFont.pixelFontName, size: 30.0)!
    
    let title: String
    
    var body: some View {
        Text("\(title)")
            .font(Font(font))
            .foregroundColor(.white)
            .lineLimit(2)
            .minimumScaleFactor(0.01)
            .multilineTextAlignment(.center)
            .frame(width: 90.0)
            .offset(x: 0.0, y: 55.0)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CodexItemView: View {
    
    let unlockable: Unlockable
    
    var itemAndTitle: some View {
        CodexItemAnimatingView(storeOffer: unlockable.item)
            .scaleEffect(2.0)
            .overlay(
                CodexItemTitleView(title: unlockable.item.title)
            ).padding(20.0)

    }
    
    var body: some View {
        CodexBackgroundView(width: 100, height: 125).overlay(itemAndTitle, alignment: .top)
    }
}

struct CodexItemView_Previews: PreviewProvider {
    static var previews: some View {
        let unlockable = Unlockable(stat: .damageTaken(100), item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 50)
        
        CodexItemView(unlockable: unlockable)
    }
}
