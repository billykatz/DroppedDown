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

struct CodexItemModalTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.titleCodexFont)
            .foregroundColor(.white)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(15.0)

    }
}

struct CodexItemModalDescriptionView: View {
    let unlockable: Unlockable
    
    var body: some View {
        if (unlockable.isUnlocked) {
            Text(unlockable.item.body)
                .font(.codexFont)
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        } else {
            Text("Mine [x] more rocks to unlock")
                .font(.codexFont)
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }

    }
}

struct CodexItemModalUnlockView: View {
    let unlockable: Unlockable
    
    var body: some View {
        if unlockable.isUnlocked {
            Text("Unlocked at 200 rocks")
                .font(.codexFont)
                .foregroundColor(.white)
                .padding()
        } else {
            Text("Unlock at 200 rocks")
                .font(.codexFont)
                .foregroundColor(.white)
                .padding()
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
    var viewModel: ProgressableModel
    @State var index: Int
    var unlockable: Unlockable {
        return viewModel.unlockables[index]
    }
    
    var body: some View {
        CodexBackgroundView(width: Constants.backgroundWidth, height: Constants.backgroundHeight, backgroundColor: .codexItemBackgroundBlue).overlay(
            VStack(alignment: .center) {
                CodexItemModalTitleView(title: offer.title)
                Spacer().frame(height: 50.0)
                CodexItemAnimatingView(unlockable: unlockable).scaleEffect(4.0)
                Spacer().frame(height: 65.0)
                CodexItemModalDescriptionView(unlockable: unlockable)
                Spacer()
                CodexItemModalUnlockView(unlockable: unlockable)
                Spacer()
                if (hiddenTrigger || !hiddenTrigger) {
                    if (!unlockable.isPurchased && unlockable.isUnlocked) {
                        BuyButtonView(action: purchase, price: unlockable.purchaseAmount)
                    }
                }
            }
            .padding(.bottom, 15.0)
        )
    }
    
    func purchase() {
        hiddenTrigger.toggle()
        viewModel.purchaseUnlockable(unlockable: unlockable)
    }
}

#if DEBUG

struct CodexItemModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        let unlockable = Unlockable(stat: .damageTaken(100), item: StoreOffer.offer(type: .killMonsterPotion, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true)
        
        CodexItemModalView(viewModel: ProgressableModel(), index: 0)
    }
}
#endif
