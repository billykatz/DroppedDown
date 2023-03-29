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
    let frame: CGSize
    
    var body: some View {
        ZStack {
            Text(add ? " +" : " -")
                .font(font)
                .foregroundColor(Color(textColor))
                .padding(.trailing, 8)
                .zIndex(10)
            RoundedRectangle(cornerRadius: 15.0)
                .frame(width: frame.width, height: frame.height, alignment: .center)
        }
    }
}

struct DebugButtonLabel: View {
    let labelText: String
    
    var body: some View {
        Text(labelText)
            .padding()
            .background(Color.blue)
            .font(.body)
            .cornerRadius(20)
            .foregroundColor(.white)
            .padding(10)
//            .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                )

    }
}

struct MusicIntroFadeInDurationView:  View {
    @State var fadeInDuration: Float = UserDefaults.standard.float(forKey: UserDefaults.musicFadeInDurationKey) {
        didSet {
            UserDefaults.standard.set(fadeInDuration, forKey: UserDefaults.musicFadeInDurationKey)
        }
    }
    var title: String {
        "Fade in duration: \(fadeInDuration)"
    
    }
    let statButtonSize = CGSize(widthHeight: 50)
    
    var body: some View {
        VStack {
            HStack {
                StatButton(add: false, frame: statButtonSize).onTapGesture(perform: {
                    fadeInDuration -= 0.125
                    fadeInDuration = max(0, fadeInDuration)
                })
                Text(title)
                StatButton(add: true, frame: statButtonSize).onTapGesture(perform: {
                    fadeInDuration += 0.125
                })
            }
        }

    }
    
    
}


struct StartingLevelView:  View {
    @State var startingLevel: Int = UserDefaults.standard.integer(forKey: UserDefaults.startingDepthLevelKey) {
        didSet {
            UserDefaults.standard.set(startingLevel, forKey: UserDefaults.startingDepthLevelKey)
        }
    }
    var startingLevelTitle: String {
        if startingLevel == testLevelDepthNumber {
            return "Test"
        } else if startingLevel == bossLevelDepthNumber {
            return "Boss"
        } else {
            return String(startingLevel+1)
        }
    }
    let statButtonSize = CGSize(widthHeight: 50)
    
    var body: some View {
        VStack {
            
            HStack {
                StatButton(add: false, frame: statButtonSize).onTapGesture(perform: {
                    startingLevel -= 1
                    startingLevel = max(0, startingLevel)
                })
                Text("Start Lvl: \(startingLevelTitle)")
                StatButton(add: true, frame: statButtonSize).onTapGesture(perform: {
                    startingLevel += 1
                })
            }
            HStack {
                Button(action: {
                    startingLevel = testLevelDepthNumber
                }, label: {
                    DebugButtonLabel(labelText: "Test Lvl")
                })
                .frame(width: 150, height: 75)
                
                Button {
                    startingLevel = bossLevelDepthNumber
                } label: {
                    DebugButtonLabel(labelText:"Boss Lvl")
                }
                .frame(width: 150, height: 75)
            }
        }

    }
    
    
}

struct PickaxeView: View {
    @State var numberOfSlots: Int = 1
    let buttonFrame = CGSize(widthHeight: 50.0)
    
    var body: some View {
        VStack {
            HStack {
                StatButton(add: false, frame: buttonFrame).onTapGesture(perform: {
                    numberOfSlots -= 1
                    numberOfSlots = max(numberOfSlots, 1)
                })
                Text("# of Rune Slot: \(numberOfSlots)")
                StatButton(add: true, frame: buttonFrame).onTapGesture(perform: {
                    numberOfSlots += 1
                    numberOfSlots = min(4, numberOfSlots)
                })
            }
            Button {
                ProfileViewModel.updateRuneSlots(numberRuneSlots: numberOfSlots)
            } label: {
                DebugButtonLabel(labelText: "Update Slots")
            }
            Button {
                ProfileViewModel.deleteStartingRunes()
            } label: {
                DebugButtonLabel(labelText: "Delete starting runes")
            }
        }

    }
}

struct RuneView: View {
    let runeType: RuneType
    @State var isCharged = true
    @State var cooldown = 5
    let buttonFrame = CGSize(widthHeight: 25.0)
    
    var rune: Rune {
        Rune.rune(for: runeType)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(rune.textureName, bundle: Bundle.main)
                .resizable()
                .frame(width: 150, height: 150)
            Text(runeType.humanReadable)
            HStack {
                StatButton(add: false, frame: buttonFrame).onTapGesture(perform: {
                    cooldown -= 5
                    cooldown = max(cooldown, 1)
                })
                Text("Charge: \(cooldown)")
                StatButton(add: true, frame: buttonFrame).onTapGesture(perform: {
                    if cooldown == 1 {
                        cooldown += 4
                    } else {
                        cooldown += 5
                    }
                })
            }
            HStack {
                Text("isCharged: \(isCharged.description)")
                StatButton(add: true, frame: buttonFrame).onTapGesture(perform: {
                    isCharged = !isCharged
                })
            }
            Button {
                ProfileViewModel.addRuneToPlayer(runeType: runeType, charged: isCharged, cooldown: cooldown)
            } label: {
                DebugButtonLabel(labelText: "Add")
            }
        }
        .border(.blue, width: 2.0)
        .cornerRadius(15.0)
        .padding(2)
    }
}


struct StatView: View {
    let viewModel: ProfileViewModel
    let stat: Statistics
    
    var body: some View {
        HStack {
            #if DEBUG
            StatButton(add: false, frame: .fifty).onTapGesture(perform: {
                viewModel.updateStat(amount: -50, stat: stat)
            })
            StatButton(add: true, frame: .fifty).onTapGesture(perform: {
                viewModel.updateStat(amount: 50, stat: stat)
            })
            #endif
            Text(stat.humanReadableForStatView())
                .font(.statsStatFont)
            Spacer()
            Text(verbatim: "\(stat.statAmount)")
                .font(.statsStatFont)
        }

    }
}

struct ResetDataView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Delete All Data")
        }
        Button(action: {
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasStartedTutorialKey)
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasCompletedTutorialKey)
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasDiedDuringTutorialKey)
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasLaunchedBeforeKey)
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasSkippedTutorialKey)
            
            
            
            UserDefaults.standard.removeObject(forKey: UserDefaults.shouldShowCompletedTutorialKey)
            
            UserDefaults.standard.removeObject(forKey: UserDefaults.hasSeenCompletedTutorialKey)


            
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
            
            UserDefaults.standard.setValue(false, forKey: UserDefaults.hasSeenRuneChargedForTheFirstTimeFTUEKey)

        }){
            Text("Reset FTUE flags")
                .foregroundColor(.white)
                .frame(width: 200, height: 75)
                .background(Color(.backgroundGray))
                .cornerRadius(5.0)
        }
        Button(action: {
            UserDefaults.standard.clearBossKeys()

        }){
            Text("Reset Boss FTUE flags")
                .foregroundColor(.white)
                .frame(width: 200, height: 75)
                .background(Color(.backgroundGray))
                .cornerRadius(5.0)
        }
        
    }
}



struct PlayerStatsView: View {
    let viewModel: ProfileViewModel
    @State var playerStatistics: [Statistics] = []
    @State var gemAmount: Int = 0
    
    let columns: [GridItem] = [.init(.flexible(minimum: 200), alignment: .leading)]
    
    @State var hiddenTrigger = 0
    
    var body: some View {
        ScrollView{
#if DEBUG
ResetDataView(action: viewModel.deletePlayerData)
#endif
            if (hiddenTrigger >= 0) {
                ForEach(playerStatistics) {  stat in
                    if (StatisticType.statTypeIsInGame(stat.statType) && hiddenTrigger >= 0) {
                        StatView(viewModel: viewModel, stat: stat)
                            .padding(EdgeInsets(top: 10.0, leading: 8.0, bottom: 10.0, trailing: 8.0))
                    }
                }.onReceive(viewModel.profilePublisher, perform: { profile in
                    playerStatistics = profile.stats
                    gemAmount = viewModel.gemAmount
                    hiddenTrigger += 1
                })
            }

#if DEBUG
            MusicIntroFadeInDurationView()
#endif
            #if DEBUG
            StartingLevelView()
            #endif
            #if DEBUG
            PickaxeView()
            #endif
            #if DEBUG
            ForEach(RuneType.allCases) { rune in
                RuneView(runeType: rune)
            }
            #endif
            HStack {
                CodexWalletView(gemAmount: gemAmount)
                #if DEBUG
                
                Button(action: {
                    viewModel.updateGems(amount: -50)
                }) {
                    StatButton(add: false, frame: .fifty)
                }
                Button(action: {
                    viewModel.updateGems(amount: 50)
                }) {
                    StatButton(add: true, frame: .fifty)
                }
                
                #endif
            }.background(Color(UIColor.backgroundGray))
            
        }
    }
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileViewModel(profile: .debugProfile)
        PlayerStatsView(viewModel: profileVM)
    }
}
