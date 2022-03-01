//
//  CodexView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

extension Shape {
    public func fill<Shape: ShapeStyle>(
        _ fillContent: Shape,
        strokeColor  : Color,
        lineWidth    : CGFloat

    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(strokeColor, lineWidth: lineWidth)

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
    
    func sectionView(section: CodexSections) -> some View {
        ForEach(viewModel.unlockables(in: section)) {
            unlockable in
            let index = viewModel.unlockables.firstIndex(of: unlockable)!
            CodexItemView(viewModel: viewModel, index: index)
                .onTapGesture {
                    viewModel.didTapOnCodexItem(at: index)
                    selectedIndex = index
                    showModal.toggle()
                }
                .contentShape(Rectangle())
        }
    }
    
    var startRunButton: some View {
        return Button(action: {
            viewModel.startRunPressed()
        }, label: {
            RoundedRectangle(cornerRadius: 50.0)
                .fill(Color(UIColor.foregroundBlue), strokeColor: Color(UIColor.codexButtonLightGray), lineWidth: 3)
                .frame(width: 250, height: 75)
                .shadow(color: .black, radius: 15, x: 0, y: 0)
                .overlay(
                    HStack(alignment: .center, spacing: 0) {
                        Text("Start Run")
                            .font(.bigSubTitleCodexFont)
                            .foregroundColor(Color(UIColor.white))
                            .padding()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .foregroundColor(.black)
                            .alignmentGuide(VerticalAlignment.center, computeValue: { dimension in
                                dimension[VerticalAlignment.center] + 4
                            })
                    }

                
                )
        })
    }
    
    var permanentUpgradesSection: some View {
        return VStack {
        
            Text("Permanent Upgrades ").font(.bigSubTitleCodexFont).foregroundColor(.white).multilineTextAlignment(.center)
            Text("Upgrades applied immediately to your base character ").font(.codexFont).foregroundColor(.white).multilineTextAlignment(.center)
            Spacer().frame(height: 25.0)
            LazyVGrid(columns: columns,
                      spacing: 20) {
                ForEach(viewModel.permanentUpgrades) { section in
                    sectionView(section: section)
                }

            }.frame(alignment: .top)
        }

    }
    
    var itemPoolSection: some View {
        return VStack {
            Text("Item Pool ").font(.bigSubTitleCodexFont).foregroundColor(.white).multilineTextAlignment(.center)
            Text("These items have a chance to show up in runs. ").font(.codexFont).foregroundColor(.white).multilineTextAlignment(.center)
            
            Spacer().frame(height: 25.0)
            
            LazyVGrid(columns: columns,
                      spacing: 20) {
                ForEach(viewModel.availableInRun) { section in
                    sectionView(section: section)
                }
            }.frame(alignment: .top)
        }

    }

    
    var body: some View {
        VStack(spacing: 4.0) {
            CodexWalletView(gemAmount: viewModel.gemAmount).frame(alignment: .center)
            ZStack {
                ScrollView {
                    Spacer().frame(height: 10.0)
                    permanentUpgradesSection
                    Spacer().frame(height: 85.0)
                    itemPoolSection
                    Spacer().frame(height: 120)
                                        
                }
                .overlay(
                    VStack {
//                        GeometryReader { reader in
                            Spacer()
                            Text("")
                            .frame(width: UIScreen.main.bounds.size.width, height: 200, alignment: .bottom)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                                    )
//
                    }
                )
                .padding(.horizontal)
                
                if (showModal) { modalView }
                
                if (modalOpacity == 0.0) {
                    VStack {
                        Spacer()
                        startRunButton
                        Spacer().frame(height: 20.0)
                    }
                }
            }
        }.background(Color(UIColor.backgroundGray))
    }
}

struct CodexView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileViewModel(profile: .debugProfile)
        let codexCoord = CodexCoordinator(viewController: UINavigationController(), delegate: nil)
        
        let data = CodexViewModel(profileViewModel: profileVM, codexCoordinator: codexCoord)
        
        CodexView(viewModel: data, selectedIndex: 0)
    }
}
