//
//  CodexView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexView: View {
    let storeOffers: [StoreOffer]
    
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    @State var showModal: Bool = false
    @State var selectedOffer: StoreOffer?
    
    @State var modalOpacity = 0.0
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(storeOffers) { storeOffer in CodexItemView(offer: storeOffer).onTapGesture {
                            showModal.toggle()
                            selectedOffer = storeOffer
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if (showModal) {
                ZStack {
                    GeometryReader { geo in
                        Rectangle()
                            .frame(width:  geo.size.width, height: geo.size.height*2, alignment: .center)
                            .foregroundColor(.gray)
                            .opacity(modalOpacity/2)
                            .offset(x: 0.0, y: -100.0)
                    }
                    CodexItemModalView(offer: selectedOffer!)
                        .opacity(modalOpacity)
                        
                }
                .onAppear {
                    // needs to be a withAnimation block or else it animates our sprite sheet
                    withAnimation { modalOpacity = 1.0 }
                }
                .onDisappear { showModal.toggle() }
                .onTapGesture(perform: {
                    withAnimation { modalOpacity = 0 }
                })
                
            }
        }
    }
}

struct CodexView_Previews: PreviewProvider {
    static var previews: some View {
        let data: [StoreOffer] = StoreOfferType.allCases.map {
            StoreOffer.offer(type: $0, tier: 1)
        }
        
        CodexView(storeOffers: data)
    }
}
