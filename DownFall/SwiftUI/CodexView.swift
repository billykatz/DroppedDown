//
//  CodexView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexView: View {
    @ObservedObject var viewModel: CodexViewModel
    
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    @State var showModal: Bool = false
    @State var selectedIndex: Int
    @State var hiddenTrigger: Bool = false
    
    @State var modalOpacity = 0.0
    @State var lastUpdated: Int = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                Spacer().frame(height: 10.0)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.unlockables) { unlockable in
                        let index = viewModel.unlockables.firstIndex(of: unlockable)!
                        CodexItemView(viewModel: viewModel, index: index).onTapGesture {
                            selectedIndex = index
                            showModal.toggle()
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
                    CodexItemModalView(viewModel: viewModel, index: selectedIndex)
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
        
        let data = CodexViewModel(unlockables: Unlockable.debugData, playerData: .zero, statData: [])
        
        CodexView(viewModel: data, selectedIndex: 0)
    }
}
