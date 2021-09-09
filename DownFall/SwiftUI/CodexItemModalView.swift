//
//  CodexItemModalView.swift
//  DownFall
//
//  Created by Billy on 7/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct PriceView: View {
    let price: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("crystals")
                .scaleEffect(CGSize(width: 0.75, height: 0.75))
            Text("\(price)")
                .font(.buttonFont)
                .foregroundColor(.black)
        }

    }
}

struct CodexItemModalView: View {
    
    struct Constants {
        static let backgroundWidth: CGFloat = 300
        static let backgroundHeight: CGFloat = 500
    }
    
    var offer: StoreOffer {
        return unlockable.item
    }
    let unlockable: Unlockable
    @Binding var purchased: Bool
    
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
                Spacer()
                if (!purchased) {
                    Button(action: purchase) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(Color(UIColor.eggshellWhite))
                                .frame(width: 200, height: 75)
                            HStack(alignment: .center, spacing: 0) {
                                Text("Buy - ")
                                    .font(.buttonFont)
                                    .foregroundColor(.black)
                                PriceView(price: unlockable.purchaseAmount)
                            }
                        }
                    }.background(Color.clear)
                    Spacer()
                }
            }
        )
    }
    
    func purchase() {
        purchased = true
    }
}

#if DEBUG

struct CodexItemModalView_Previews: PreviewProvider {
    @State static var purchased = true
    
    static var previews: some View {
        let unlockable = Unlockable(stat: .damageTaken(100), item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 50, isPurchased: false)

        CodexItemModalView(unlockable: unlockable, purchased: $purchased)
    }
}
#endif
