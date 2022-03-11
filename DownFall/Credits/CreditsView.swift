//
//  CreditsView.swift
//  DownFall
//
//  Created by Billy on 3/11/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import SwiftUI

struct RockLineView: View {
    var body: some View {
        HStack {
            Image("redRock").resizable().frame(width: 50, height: 50)
            Image("blueRock").resizable().frame(width: 50, height: 50)
            Image("greenRock").resizable().frame(width: 50, height: 50)
            Image("purpleRock").resizable().frame(width: 50, height: 50)
            Image("brownRock").resizable().frame(width: 50, height: 50)
        }
    }
}

struct BetaTesterView: View {
    
    var body: some View {
        Text("BETA TESTERS")
            .font(.creditsNameCodexFont)
            .underline()
        Text("Thank you, testers, for your endless energy. Shift Shaft is a better game because of the time and effort you put in. \n")
            .font(.creditsNameCodexFont)
            .multilineTextAlignment(.center)
        
        ForEach(betaTesters) { betaTester in
            Text(betaTester.name)
                .font(.creditsNameCodexFont)
        }
        
        RockLineView()
    }


}

struct SpecialThanksView: View {
    var body: some View {
        Text("Special thanks to my rock, \nChloe\n Thanks for always believing in me and helping me grow.  I could not have done this without you.")
            .font(.creditsNameCodexFont)
            .multilineTextAlignment(.center)
            .padding([.trailing, .leading], 20)
        
        RockLineView()
        
        Text("Hi Mom! Hi Dad! I love you both. Thanks for helping me find my path. I hope you can get past level 5 someday.")
            .font(.creditsNameCodexFont)
            .multilineTextAlignment(.center)
            .padding([.trailing, .leading], 20)
        
        RockLineView()
    }
    
}

struct ThankYou: View {
    var body: some View {
        Text("And thank you for playing.  If you enjoyed it please rate and review and share with your friends. ")
            .font(.creditsSubTitleCodexFont)
            .multilineTextAlignment(.center)
            .padding([.trailing, .leading], 20)
        
        RockLineView()
    }
}


struct LinkTree: View {
    var body: some View {
        Spacer().frame(height: 25)
        
        Button {
            let url = URL(string: "https://linktr.ee/shiftshaft")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } label: {
            Text("--- Shift Shaft Team ---")
                .font(.creditsSubTitleCodexFont)
                .multilineTextAlignment(.center)

        }

             
    }
}

struct TeamNameView: View {
    var body: some View {
        VStack {
            Group{
                Text("Game Design\nProgramming")
                    .font(.creditsSubTitleCodexFont)
                    .multilineTextAlignment(.center)
                Text("Art and Animation")
                    .font(.creditsSubTitleCodexFont)
                    .underline()

                Text("Billy Katz")
                    .font(.creditsBigNameCodexFont)
            }
            Group {
                
                RockLineView()
                Text("Art")
                    .font(.creditsSubTitleCodexFont)
                Text("UX Design")
                    .font(.creditsSubTitleCodexFont)
                    .underline()
                
                Text("Cori Huang")
                    .font(.creditsBigNameCodexFont)
                RockLineView()
                
                Text("Music Composer")
                    .font(.creditsSubTitleCodexFont)
                    .underline()
                
                Text("Barry Sebastian")
                    .font(.creditsBigNameCodexFont)
                
                RockLineView()
                
                Text("Art")
                    .font(.creditsSubTitleCodexFont)
                    .underline()
                Text("Bailey Zanhiser")
                    .font(.creditsBigNameCodexFont)
            }
        }
    }
}

struct CreditsView: View {
    var body: some View {
        ScrollView {
            TeamNameView()
            RockLineView()
            SpecialThanksView()
            BetaTesterView()
            ThankYou()
            LinkTree()
            Spacer().frame(height: 20)
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
