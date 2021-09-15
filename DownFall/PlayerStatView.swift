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
            StatButton(add: false).onTapGesture(perform: {
                viewModel.updateStat(amount: -50, stat: stat)
            })
            StatButton(add: true).onTapGesture(perform: {
                viewModel.updateStat(amount: 50, stat: stat)
            })
            Text("\(stat.statType.rawValue)\(statExtra)")
            Spacer()
            Text(verbatim: "\(stat.amount)")
        }
    }
}

struct PlayerStatsView: View {
    let viewModel: ProfileViewModel
    @State var playerStatistics: [Statistics] = []
    
    let columns: [GridItem] = [.init(.flexible(minimum: 250), alignment: .leading)
                               ]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(playerStatistics) {  stat in
                    StatView(viewModel: viewModel, stat: stat)
                }.onReceive(viewModel.profilePublisher, perform: { profile in
                    playerStatistics = profile.stats
                })
            }.padding()
        }
    }
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileViewModel(profile: .debug)
        PlayerStatsView(viewModel: profileVM)
    }
}
