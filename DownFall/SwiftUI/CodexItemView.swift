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

extension Unlockable {
    var backgroundColor: UIColor {
        if isPurchased && isUnlocked {
            return .codexItemBackgroundBlue
        } else if isUnlocked && !isPurchased {
            return .codexItemBackgroundLightGray
        } else {
            return .codexItemBackgroundBlack
        }
    }

}

struct CodexItemView: View {
    
    var viewModel: ProgressableModel
    @State var index: Int
    @State var hiddenTrigger: Bool = false

    var unlockable: Unlockable {
        return viewModel.unlockables[index]
    }

    var body: some View {
        if (hiddenTrigger || !hiddenTrigger) {
            CodexBackgroundView(width: 100, height: 125, backgroundColor: unlockable.backgroundColor).overlay(
                CodexItemAnimatingView(unlockable: unlockable)
                    .scaleEffect(2.0)
                    .overlay(
                        CodexItemTitleView(title: unlockable.item.title)
                    ).padding(20.0), alignment: .top).onReceive(viewModel.$unlockables, perform: { _ in
                        hiddenTrigger.toggle()
                    })
        }
            
    }
}

struct CodexItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        let data = ProgressableModel()
        
        VStack {
            CodexItemView(viewModel: data, index: 0)
            CodexItemView(viewModel: data, index: 1)
            CodexItemView(viewModel: data, index: 2)
        }
    }
}
