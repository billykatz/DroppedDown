//
//  CodexPriceView.swift
//  DownFall
//
//  Created by Billy on 9/13/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct PriceView: View {
    let price: Int
    let textColor: UIColor
    let scale: CGFloat
    let font: Font
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("crystals")
                .resizable()
                .frame(width: 50*scale, height: 50*scale)
                .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                    dimension[VerticalAlignment.center] - (4 * scale)
                    
                })
            Text(verbatim: "\(price)")
                .font(font)
                .foregroundColor(Color(textColor))
                .padding(.trailing, 8)
        }

    }
}


struct CodexPriceView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            PriceView(price: 300, textColor: .white, scale: 0.5, font: .codexFont)
            
            PriceView(price: 1234, textColor: .white, scale: 0.5, font: .codexFont)
            
            PriceView(price: 500, textColor: .white, scale: 0.75, font: .buttonFont)
            
            PriceView(price: 9999, textColor: .white, scale: 0.75, font: .buttonFont)
        }
        .frame(width: 400, height: 400).background(Color.black)
    }
}
