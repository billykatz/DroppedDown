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
    
    func toggleModal() {
        modalOpacity = 0.0
        showModal.toggle()
        selectedOffer = nil
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(storeOffers) { storeOffer in CodexItemView(offer: storeOffer).onTapGesture {
                            showModal.toggle()
                            selectedOffer = storeOffer
                        }
                    }
//                    ForEach(storeOffers) { storeOffer in CodexItemView(offer: storeOffer).onTapGesture {
//                            showModal.toggle()
//                            selectedOffer = storeOffer
//                        }
//                    }

                }
            }
            .padding(.horizontal)
            
            if (selectedOffer != nil) {
                ZStack {
                    GeometryReader { geo in
                        Rectangle()
                            .size(geo.size.scale(by: 2.0))
                            .foregroundColor(.gray)
                            .opacity(modalOpacity/2)
                            .offset(x: 0.0, y: -100)
                            .onTapGesture(perform: toggleModal)
                    }
                    CodexItemModalView(offer: selectedOffer!)
                        .opacity(modalOpacity)
                        .onAppear {
                            withAnimation {
                                modalOpacity = 1.0
                            }
                        }
                        .onTapGesture(perform: toggleModal)
                }
                
            }
        }
        //        .sheet(isPresented: $showModal) {
        //            if selectedOffer != nil {
        //                CodexItemModalView(offer: selectedOffer!)
        //                Text("Show modal")
        //            }
        //        }
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
