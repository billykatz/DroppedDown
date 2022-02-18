//
//  CodexWalletView.swift
//  DownFall
//
//  Created by Billy on 2/18/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexWalletView: View {
    let gemAmount: Int
    
    var body: some View {
        HStack {
            HStack {
                Image("crystals").alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                    dimension[VerticalAlignment.center] - 3
                })
                Text(verbatim: "\(gemAmount)").font(.titleCodexFont).foregroundColor(.white)
            }.padding(.trailing, 10)
        }

    }
}

struct CodexWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CodexWalletView(gemAmount: 555)
    }
}
