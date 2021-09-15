//
//  SettingsView.swift
//  DownFall
//
//  Created by Billy on 9/13/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct SettingsDebugButtonView: View {
    let price: Int
    let textColor: UIColor
    let scale: CGFloat
    let font: Font
    let textureName: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(textureName)
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

struct SettingsDebugButton: View {
    let action: (Int) -> ()
    let price: Int
    let add: Bool
    let textureName: String
    
    var body: some View {
        Button(action: {
            action(price)
        }) {
            HStack {
                Text(add ? "+" : "-")
                    .font(.codexFont)
                    .foregroundColor(Color(UIColor.darkBarBlue))
                    .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                        dimension[VerticalAlignment.center] + 2
                    })
                SettingsDebugButtonView(price: price, textColor: .blue, scale: 0.5, font: .codexFont, textureName: textureName)
            }
                .frame(width: 105, height: 40)
                .background(Color(UIColor.eggshellWhite))
                .cornerRadius(10.0)
        }
    }
}



struct SettingsView: View {
    let crystalsTextureName = "crystals"
    
    var debugGemMenu: some View {
        VStack {
            Text("Gems").font(.titleCodexFont)
            HStack {
                VStack {
                    SettingsDebugButton(action: minusGems(amount:), price: 100, add: false, textureName: crystalsTextureName)
                }
                VStack {
                    SettingsDebugButton(action: plusGems(amount:), price: 100, add: true, textureName: crystalsTextureName)
                }

            }
        }

    }
    
    var debugRocksMenu: some View {
        VStack {
            Text("Rocks").font(.titleCodexFont)
            HStack {
                VStack {
                    SettingsDebugButton(action: minusBlueRocks(amount:), price: 100, add: false, textureName: "blueRock")
                    SettingsDebugButton(action: minusRedRocks(amount:), price: 100, add: false, textureName: "redRock")
                    SettingsDebugButton(action: minusPurpleRocks(amount:), price: 100, add: false, textureName: "purpleRock")
                }
                VStack {
                    SettingsDebugButton(action: plusBlueRocks(amount:), price: 100, add: true, textureName: "blueRock")
                    SettingsDebugButton(action: plusRedRocks(amount:), price: 100, add: true, textureName: "redRock")
                    SettingsDebugButton(action: plusPurpleRocks(amount:), price: 100, add: true, textureName: "purpleRock")
                }
                

            }
        }

    }

    
    
    var body: some View {
        ScrollView{
            VStack(spacing: 40) {
                debugGemMenu
                debugRocksMenu
            }
        }
    }
    
    func plusGems(amount: Int) {
        
    }
    
    func minusGems(amount: Int) {
        
    }
    
    func plusBlueRocks(amount: Int) {
        
    }
    
    func minusBlueRocks(amount: Int) {
        
    }
    
    func plusRedRocks(amount: Int) {
        
    }
    
    func minusRedRocks(amount: Int) {
        
    }
    
    func plusPurpleRocks(amount: Int) {
        
    }
    
    func minusPurpleRocks(amount: Int) {
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
