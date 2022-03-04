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
    let foregroundColor: UIColor
    var body: some View {
        Text("\(title)")
            .font(Font(font))
            .foregroundColor(Color(foregroundColor))
            .lineLimit(2)
            .minimumScaleFactor(0.01)
            .multilineTextAlignment(.center)
            .frame(width: 90.0)
            .offset(x: 0.0, y: 55.0)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension Unlockable {
    var backgroundColor: UIColor {
        if isPurchased {
            return .codexItemBackgroundBlue
        } else if isUnlocked && !isPurchased {
            return .codexItemBackgroundLightGray
        } else {
            return .codexItemBackgroundBlack
        }
    }
    
    var borderColor: UIColor {
        if isPurchased || isUnlocked {
            return .white
        } else {
            return .codexItemStrokeGray
        }
    }
    
    var textColor: UIColor {
        if isPurchased || isUnlocked {
            return .white
        } else {
            return .lightGray
        }
    }

}

struct CodexItemView: View {
    
    var viewModel: CodexViewModel
    var index: Int
    @State var hiddenTrigger: Bool = false

    var unlockable: Unlockable {
        return viewModel.unlockables[index]
    }
    
    var priceTextColor: UIColor {
        return viewModel
            .playerCanAfford(unlockable: unlockable) ? .white : .codexRedText
    }
    
    var notificationSignStackSize: CGSize {
        if unlockable.purchaseAmount == 0 {
            return CGSize(width: 145, height: 225)
        } else {
            return .init(width: 125, height: 185)
        }
    }
    
    var notificationSignImageSize: CGSize {
        if unlockable.purchaseAmount == 0 {
            return CGSize(width: 64, height: 32)
        } else {
            return .init(width: 32, height: 32)
        }
    }

    
    var notificationSignImageName: String {
        if unlockable.purchaseAmount == 0 {
            return "free-sign"
        } else {
            return "notificationYellow"
        }
    }
    
    var notificationSign: some View {
        return ZStack {
            HStack {
                Spacer()
                VStack {
                    Image(notificationSignImageName).frame(width: notificationSignImageSize.width, height: notificationSignImageSize.width)
                        .rotationEffect(Angle(degrees: 10))
                    Spacer()
                }
            }
        }.frame(width: notificationSignStackSize.width, height: notificationSignStackSize.height)
    }

    var body: some View {
        if (hiddenTrigger || !hiddenTrigger) {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    CodexBackgroundView(width: 100, height: 125, backgroundColor: unlockable.backgroundColor, borderColor: unlockable.borderColor).overlay(
                        CodexItemAnimatingView(unlockable: unlockable).scaleEffect(2.0)
                            .overlay(
                                CodexItemTitleView(title: unlockable.item.title, foregroundColor: unlockable.textColor)
                            ).padding(20.0), alignment: .top)
                    if (!unlockable.isPurchased && unlockable.isUnlocked) {
                        PriceView(price: unlockable.purchaseAmount, textColor: self.priceTextColor, scale: 0.5, font: Font.codexFont)
                    } else if !unlockable.isPurchased && !unlockable.isUnlocked {
                        Spacer().frame(height: 4)
                        Image("codex-lock").resizable().frame(width: 25, height: 25)
                    }
                }
                if (!unlockable.hasBeenTappedOnByPlayer && unlockable.isUnlocked) {
                    notificationSign
                }
            }
            .onReceive(viewModel.$unlockables) { _ in
                hiddenTrigger.toggle()
            }
            
        }
            
    }
}

struct CodexItemView_Previews: PreviewProvider {
    static var previews: some View {

        
        let data = CodexViewModel(profileViewModel: ProfileViewModel(profile: .debugProfile), codexCoordinator: CodexCoordinator(viewController: UINavigationController(), delegate: nil))
        
        
        VStack {
            CodexItemView(viewModel: data, index: 0)
            CodexItemView(viewModel: data, index: 1)
            CodexItemView(viewModel: data, index: 2)
        }.background(Color(UIColor.backgroundGray))
    }
}
