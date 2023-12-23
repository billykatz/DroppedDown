//
//  CodexBuyButton.swift
//  DownFall
//
//  Created by Billy on 11/9/21.
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
            .frame(width: 225, height: 75)
    }
    
    var body: some View {
        if canAfford {
            Button(action: action) {
                buttonBackground
                    .overlay(HStack(alignment: .center, spacing: 0) {
                            Text("Buy")
                                .font(.buttonFont)
                                .foregroundColor(.black)
                                .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                                    dimension[VerticalAlignment.center] + 2
                                })
                    })
            }
        } else {
            buttonBackground
                .overlay(HStack(alignment: .center, spacing: 0) {
                        Text("Collect more gems to buy")
                            .font(.codexFont)
                            .background(Color(UIColor.codexDarkGray))
                            .padding()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .foregroundColor(.black)
                })
        }
        
        PriceView(price: price, textColor: (canAfford ? .white : .codexRedText), scale: 0.75, font: Font.titleCodexFont)

    }
}
