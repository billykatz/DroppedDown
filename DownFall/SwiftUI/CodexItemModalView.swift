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

struct BuyButtonView: View {
    let action: () -> ()
    let price: Int
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(UIColor.eggshellWhite))
                    .frame(width: 200, height: 75)
                HStack(alignment: .center, spacing: 0) {
                    Text("Buy - ")
                        .font(.buttonFont)
                        .foregroundColor(.black)
                    PriceView(price: price)
                }
            }
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
    
    @State var hiddenTrigger: Bool = false
    @Binding var unlockable: Unlockable
    
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
                if (hiddenTrigger || !hiddenTrigger) {
                    if (!unlockable.isUnlocked) {
                        
                    }
                    else if (!unlockable.isPurchased) {
                        BuyButtonView(action: purchase, price: unlockable.purchaseAmount)
                        Spacer()
                    }
                    
                }
                
            }
        )
    }
    
    func purchase() {
       hiddenTrigger.toggle()
       unlockable.isPurchased = true
    }
}

#if DEBUG

struct CodexItemModalView_Previews: PreviewProvider {
    @State static var unlockable = Unlockable(stat: .damageTaken(100), item: StoreOffer.offer(type: .killMonsterPotion, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false)
    
    static var previews: some View {

        CodexItemModalView(unlockable: $unlockable)
    }
}
#endif
