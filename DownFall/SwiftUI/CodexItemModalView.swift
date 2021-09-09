//
//  CodexItemModalView.swift
//  DownFall
//
//  Created by Billy on 7/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexItemModalView: View {
    
    struct Constants {
        static let backgroundWidth: CGFloat = 300
        static let backgroundHeight: CGFloat = 400
    }
    
    var offer: StoreOffer {
        return unlockable.item
    }
    let unlockable: Unlockable
    
    var body: some View {
        CodexBackgroundView(width: Constants.backgroundWidth, height: Constants.backgroundHeight).overlay(
            VStack(alignment: .center) {
                Text("\(offer.title)")
                    .font(.titleCodexFont)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(15.0)
                Spacer().frame(height: 50.0)
                CodexItemAnimatingView(storeOffer: offer).scaleEffect(4.0)
                Spacer().frame(height: 65.0)
                Text("\(offer.body)")
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                Spacer()
                Text("Unlocked 200/200")
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .padding()
            }
        )
    }
}

struct CodexItemModalView_Previews: PreviewProvider {
    static var previews: some View {
        
        let unlockable = Unlockable(stat: .damageTaken(100), item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 50)

        CodexItemModalView(unlockable: unlockable)
    }
}
