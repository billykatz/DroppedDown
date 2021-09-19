//
//  CodexView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexWalletView: View {
    let gemAmount: Int
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Image("crystals").alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                    dimension[VerticalAlignment.center] - 3
                })
                Text(verbatim: "\(gemAmount)").font(.titleCodexFont).foregroundColor(.white)
            }.padding(.trailing, 10)
        }

    }
}

struct CodexView: View {
    @ObservedObject var viewModel: CodexViewModel
    
    let columns = [
        GridItem(.flexible(minimum: 100), alignment: .top),
        GridItem(.flexible(minimum: 100), alignment: .top),
        GridItem(.flexible(minimum: 100), alignment: .top)
    ]
    
    @State var showModal: Bool = false
    @State var selectedIndex: Int
    @State var hiddenTrigger: Bool = false
    
    @State var modalOpacity = 0.0
    @State var lastUpdated: Int = 0
    
    
    var modalView: some View {
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
    
    var body: some View {
        VStack(spacing: 4.0) {
            CodexWalletView(gemAmount: viewModel.gemAmount)
            ZStack {
                ScrollView {
                    Spacer().frame(height: 10.0)
                    Text("- Store - ").font(.bigTitleCodexFont).foregroundColor(.white)
                    
                    LazyVGrid(columns: columns,
                              spacing: 20) {
                        ForEach(viewModel.sections) { section in
                            Section(header: Text("\(section.header)").font(.titleCodexFont).foregroundColor(.white)) {
                                ForEach(viewModel.unlockables(in: section)) {
                                    unlockable in
                                    let index = viewModel.unlockables.firstIndex(of: unlockable)!
                                    CodexItemView(viewModel: viewModel, index: index)
                                        .onTapGesture {
                                            selectedIndex = index
                                            showModal.toggle()
                                        }
                                        .contentShape(Rectangle())

                                }
                                Spacer().frame(height: 10.0)
                            }
                        }
                    }.frame(alignment: .top)
                }
                .padding(.horizontal)
                
                if (showModal) { modalView }
            }
        }.background(Color(UIColor.backgroundGray))
    }
}

struct CodexView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileViewModel(profile: .debugProfile)
        let codexCoord = CodexCoordinator(viewController: UINavigationController())
        
        let data = CodexViewModel(profileViewModel: profileVM, codexCoordinator: codexCoord)
        
        CodexView(viewModel: data, selectedIndex: 0)
    }
}
