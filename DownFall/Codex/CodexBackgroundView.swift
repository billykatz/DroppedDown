//
//  CodexBackgroundView.swift
//  DownFall
//
//  Created by Billy on 7/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct CodexBackgroundView: View {
    let width: CGFloat
    let height: CGFloat
    let backgroundColor: UIColor
    let borderColor: UIColor
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .stroke(Color(borderColor), lineWidth: 5.0)
            .background(
                RoundedRectangle(cornerRadius: 10.0).fill(Color(backgroundColor))
            )
            .frame(width: width, height: height, alignment: .center)
    }
}

struct CodexBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        CodexBackgroundView(width: 100, height: 125, backgroundColor: .codexItemBackgroundBlue, borderColor: .codexItemStrokeBlue)
    }
}
