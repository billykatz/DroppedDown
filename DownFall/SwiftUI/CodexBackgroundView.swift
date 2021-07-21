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
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15.0)
            .stroke(Color(UIColor.codexItemStrokeBlue), lineWidth: 5.0)
            .background(
                RoundedRectangle(cornerRadius: 15.0).fill(Color(UIColor.codexItemBackgroundBlue))
            )
            .frame(width: width, height: height, alignment: .center)
    }
}

struct CodexBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        CodexBackgroundView(width: 100, height: 125)
    }
}
