//
//  PlayerStatView.swift
//  DownFall
//
//  Created by Billy on 9/14/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct StatButton: View {
    let textColor: UIColor = .white
    let font: Font = .titleCodexFont
    let add: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0)
                .frame(width: 50, height: 50, alignment: .center)
            Text(add ? " +" : " -")
                .font(font)
                .foregroundColor(Color(textColor))
                .padding(.trailing, 8)
        }
    }
}


struct StatView: View {
    let viewModel: ProfileViewModel
    let stat: Statistics
    
    
    var statExtra: String {
        let value: Any? = stat.gemColor ?? stat.rockColor ?? stat.monsterType ?? stat.runeType
        if value == nil { return "" }
        return " - \(String(describing: value!))"
    }
    
    var body: some View {
        HStack {
            #if DEBUG
            StatButton(add: false).onTapGesture(perform: {
                viewModel.updateStat(amount: -50, stat: stat)
            })
            StatButton(add: true).onTapGesture(perform: {
                viewModel.updateStat(amount: 50, stat: stat)
            })
            #endif
            Text("\(stat.statType.rawValue)\(statExtra)")
            Spacer()
            Text(verbatim: "\(stat.amount)")
        }
//        .onReceive(viewModel.profilePublisher, perform: { profile in
//            if let stat = profile.stats.first(where: { $0 == stat }) {
//                self.stat = stat
//            }
//        })
    }
}



struct PlayerStatsView: View {
    let viewModel: ProfileViewModel
    @State var playerStatistics: [Statistics] = []
    @State var gemAmount: Int = 0
    
    let columns: [GridItem] = [.init(.flexible(minimum: 250), alignment: .leading)]
    
    
    var body: some View {
        ScrollView{
            Button(action: {
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasStartedTutorialKey)
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasCompletedTutorialKey)
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasDiedDuringTutorialKey)
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasLaunchedBeforeKey)
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSkippedTutorialKey)
                
                
                
                UserDefaults.standard.setValue(false, forKey: UserDefaults.shouldShowCompletedTutorialKey)
                
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSeenCompletedTutorialKey)


                
            }) {
                Text("Reset tutorial flags")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 75)
                    .background(Color(.backgroundGray))
                    .cornerRadius(5.0)
            }
            Button(action: {
                UserDefaults.standard.setValue(false, forKey: UserDefaults.shouldSeeDiedForTheFirstTimeKey)
                
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSeenDiedForTheFirstTimeKey)
                
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSeenFirstRuneFTUEKey)
                
                UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSeenMinedFirstGemFTUEKey)
            }){
                Text("Reset FTUE flags")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 75)
                    .background(Color(.backgroundGray))
                    .cornerRadius(5.0)
            }
            HStack {
                CodexWalletView(gemAmount: gemAmount)
                #if DEBUG
                
                Button(action: {
                    viewModel.updateGems(amount: -50)
                }) {
                    StatButton(add: false)
                }
                Button(action: {
                    viewModel.updateGems(amount: 50)
                }) {
                    StatButton(add: true)
                }
                
                #endif
            }.background(Color(UIColor.backgroundGray))
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(playerStatistics) {  stat in
                    StatView(viewModel: viewModel, stat: stat)
                }.onReceive(viewModel.profilePublisher, perform: { profile in
                    playerStatistics = profile.stats
                    gemAmount = viewModel.gemAmount
                })
            }.padding()
            Button(action: viewModel.deletePlayerData) {
                Text("Delete All Data")
            }
        }
    }
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileViewModel(profile: .debugProfile)
        PlayerStatsView(viewModel: profileVM)
    }
}
