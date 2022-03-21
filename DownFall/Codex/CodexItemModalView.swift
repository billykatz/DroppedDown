//
//  CodexItemModalView.swift
//  DownFall
//
//  Created by Billy on 7/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

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
    let relevantProgress: Int
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
            if (unlockable.isPurchased) {
                CodexUnlockAtView(unlockable: unlockable,
                                  progress: relevantProgress,
                                  progressString: relevantPlayerStat)
            
            }
        } else {
            CodexUnlockAtView(unlockable: unlockable,
                              progress: relevantProgress,
                              progressString: relevantPlayerStat)
        }

    }
}

struct CodexItemModalApplicationView: View {
    let appliesToBaseCharacter: Bool
    
    var body: some View {
//        Text("You own this.")
//            .font(.titleCodexFont)
//            .foregroundColor(.white)
        if (appliesToBaseCharacter) {
            Text("This upgrade has been applied to your character.")
                .font(.codexFont)
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Text("This item has a chance to show up in future runs.")
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

struct CodexItemModalFutureApplicationView: View {
    let appliesToBaseCharacter: Bool
    
    var body: some View {
        if (appliesToBaseCharacter) {
            Text("When purchased, this upgrade will be immediately applied to your character.")
                .font(.codexFont)
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Text("When purchased, this item will show up in future runs.")
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


struct CodexItemModalView: View {
    
    var viewModel: CodexViewModel
    @State var index: Int
    @State var hiddenTrigger: Bool = false
    
    var unlockable: Unlockable {
        return viewModel.unlockables[index]
    }
    
    struct Constants {
        static let backgroundWidth: CGFloat = 300
    }
    
    var backgroundHeight: CGFloat {
        if !unlockable.isUnlocked {
            return 480
        } else {
            return 600
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
                CodexItemModalDescriptionView(unlockable: unlockable, relevantProgress: viewModel.amountNeededToUnlock(unlockable), relevantPlayerStat: viewModel.unlockAt(unlockable))
                Spacer()
                if (hiddenTrigger || !hiddenTrigger) {
                    if (!unlockable.isPurchased && unlockable.isUnlocked) {
                        BuyButtonView(action: purchase, price: unlockable.purchaseAmount, canAfford: viewModel.playerCanAfford(unlockable: unlockable))
                        CodexItemModalFutureApplicationView(appliesToBaseCharacter: unlockable.applysToBasePlayer)
                        Spacer()
                    } else if unlockable.isPurchased {
                        CodexItemModalApplicationView(appliesToBaseCharacter: unlockable.applysToBasePlayer)
//                        Text("Purchased").font(.titleCodexFont).foregroundColor(.white).multilineTextAlignment(.center)
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
        if viewModel.playerCanAfford(unlockable: unlockable) {
            viewModel.purchaseUnlockable(unlockable: unlockable)
            
        } else {
            
        }

    }
}


struct CodexItemModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        let vm = ProfileViewModel(profile: .debugProfile)
        
        CodexItemModalView(viewModel: CodexViewModel(profileViewModel: vm, codexCoordinator: CodexCoordinator(viewController: UINavigationController(), delegate: nil)), index: 0)
    }
}
