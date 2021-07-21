//
//  CodexItemModalView.swift
//  DownFall
//
//  Created by Billy on 7/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexItemModalView: View {
    let offer: StoreOffer
    
    var body: some View {
        CodexBackgroundView(width: 300, height: 350).overlay(
            VStack(alignment: .center) {
                Text("\(offer.title)")
                    .font(.titleCodexFont)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(15.0)
                Spacer().frame(height: 50.0)
                CodexItemAnimatingView(storeOffer: offer).scaleEffect(4.0)
                Spacer().frame(height: 60.0)
                Text("\(offer.body)")
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                Spacer()
                Text("Unlocked 250/200")
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .padding()
            }
        )
    }
}

struct CodexItemModalView_Previews: PreviewProvider {
    static var previews: some View {
        CodexItemModalView(offer: StoreOffer.offer(type: .transmogrifyPotion, tier: 1))
    }
}
