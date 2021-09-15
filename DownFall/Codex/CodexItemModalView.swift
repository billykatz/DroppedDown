//
//  CodexItemModalView.swift
//  DownFall
//
//  Created by Billy on 7/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct BuyButtonView: View {
    let action: () -> ()
    let price: Int
    let canAfford: Bool
    
    var buttonColor: Color {
        return Color(canAfford ? .codexButtonLightGray : .codexDarkGray)
    }
    
    var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(buttonColor)
            .frame(width: 200, height: 75)
    }
    
    var body: some View {
        if canAfford {
            Button(action: action) {
                buttonBackground
                    .overlay(HStack(alignment: .center, spacing: 0) {
                            Text("Buy - ")
                                .font(.buttonFont)
                                .foregroundColor(.black)
                                .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                                    dimension[VerticalAlignment.center] + 2
                                })
                            PriceView(price: price, textColor: .black, scale: 0.75, font: Font.buttonFont)
                    })
            }

        } else {
            buttonBackground
                .overlay(HStack(alignment: .center, spacing: 0) {
                        Text("Mine more gems to buy")
                            .font(.codexFont)
                            .background(Color(UIColor.codexDarkGray))
                            .padding()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .foregroundColor(.black)
                })
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
    let relevantPlayerStat: String

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
            Text(relevantPlayerStat)
                .font(.codexFont)
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }

    }
}

struct CodexItemModalUnlockView: View {
    let unlockable: Unlockable
    
    var statExtra: String {
        let stat = unlockable.stat
        let value: Any? = stat.gemColor ?? stat.rockColor ?? stat.monsterType ?? stat.runeType
        if value == nil { return "" }
        return " - \(String(describing: value!))"
    }
    
    var body: some View {
        Text("Unlocked at \(unlockable.stat.amount) \(unlockable.stat.statType.rawValue) \(statExtra)")
            .font(.codexFont)
            .foregroundColor(.white)
            .padding()
    }
}

struct CodexItemModalView: View {
    
    var viewModel: CodexViewModel
    @State var index: Int
    @State var hiddenTrigger: Bool = false
    
    var unlockable: Unlockable {
        return viewModel.unlockables[index]
    }
    
    struct Constants {
        static let backgroundWidth: CGFloat = 300
        static let backgroundHeight: CGFloat = 500
    }
    
    var backgroundHeight: CGFloat {
        if !unlockable.isUnlocked {
            return 280
        } else {
            return 500
        }
    }
    
    
    var body: some View {
        CodexBackgroundView(width: Constants.backgroundWidth, height: backgroundHeight, backgroundColor: .codexItemBackgroundBlue, borderColor: .codexItemStrokeBlue).overlay(
            VStack(alignment: .center) {
                Spacer().frame(height: 10.0)
                CodexItemModalTitleView(title: unlockable.item.title)
                Spacer().frame(height: 50.0)
                CodexItemAnimatingView(unlockable: unlockable).scaleEffect(4.0)
                Spacer().frame(height: 65.0)
                CodexItemModalDescriptionView(unlockable: unlockable, relevantPlayerStat: viewModel.unlockAt(unlockable))
                Spacer()
                if unlockable.isUnlocked {
                    CodexItemModalUnlockView(unlockable: unlockable)
                    Spacer()
                }
                if (hiddenTrigger || !hiddenTrigger) {
                    if (!unlockable.isPurchased && unlockable.isUnlocked) {
                        BuyButtonView(action: purchase, price: unlockable.purchaseAmount, canAfford: viewModel.playerCanAfford(unlockable: unlockable))
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 15.0)
        )
        .onReceive(viewModel.$unlockables, perform: { unlockables in
            hiddenTrigger.toggle()
        })
    }
    
    func purchase() {
        viewModel.purchaseUnlockable(unlockable: unlockable)

    }
}


struct CodexItemModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        let vm = ProfileViewModel(profile: .debugProfile)
        
        CodexItemModalView(viewModel: CodexViewModel(profileViewModel: vm, codexCoordinator: CodexCoordinator(viewController: UINavigationController())), index: 0)
    }
}
