//
//  CodexView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexView: View {
    let progress: ProgressableModel
    
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    @State var showModal: Bool = false
    @State var selectedUnlockable: Unlockable
    
    @State var modalOpacity = 0.0
    
    var body: some View {
        ZStack {
            ScrollView {
                Spacer().frame(height: 10.0)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(progress.unlockables) { unlockable in
                        CodexItemView(unlockable: unlockable).onTapGesture {
                            selectedUnlockable = unlockable
                            showModal.toggle()
                            print("\(String(describing: selectedUnlockable.id))")
                        }
                        .contentShape(Rectangle())
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
                    CodexItemModalView(unlockable: $selectedUnlockable)
                    .opacity(modalOpacity)
                        
                }
                .onAppear {
                    // needs to be a withAnimation block or else it animates our sprite sheet
                    withAnimation { modalOpacity = 1.0 }
                }
                .onDisappear {
                    showModal.toggle()
                }
                .onTapGesture(perform: {
                    withAnimation { modalOpacity = 0 }
                })
                
            }
        }
    }
}

struct CodexView_Previews: PreviewProvider {
    static var previews: some View {
        
        let data = ProgressableModel()
        
        CodexView(progress: data, selectedUnlockable: data.unlockables.first!)
    }
}
