//
//  CodexUnlockAtView.swift
//  DownFall
//
//  Created by Billy on 11/9/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexUnlockAtView: View {
    let unlockable: Unlockable
    let progress: Int
    let progressString: String
    let lineWidth: CGFloat = 10.0
    
    
    var trimTo: CGFloat {
        return CGFloat(progress) / CGFloat(unlockable.stat.amount)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(Color(.backgroundGray))
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.2)
                    .foregroundColor(Color(.backgroundGray))
                Circle()
                    .trim(from: 0.0, to: trimTo)
                    .rotation(Angle(degrees: 270))
                    .scale(x: -1)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(unlockable.stat.color))
                Image(unlockable.stat.textureName)
                    .resizable()
                    .frame(width: 60, height: 60)
                
            }.frame(width: 125, height: 125)
            Text("\(min(unlockable.stat.amount,progress)) / \(unlockable.stat.amount)")
                .font(.titleCodexFont).foregroundColor(.white).multilineTextAlignment(.center)
            if (progress < unlockable.stat.amount) {
                Text(progressString)
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Unlocked")
                    .font(.codexFont)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct CodexUnlockAtView_Previews: PreviewProvider {
    static var previews: some View {
        CodexUnlockAtView(unlockable: Unlockable.debugStartingUnlockables.first!, progress: 55, progressString: "Mine 45 more blue rocks to unlock this")
            .background(Color.gray).frame(height: 500.0)
    }
}
