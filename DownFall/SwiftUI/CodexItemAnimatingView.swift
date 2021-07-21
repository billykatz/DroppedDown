//
//  CodexItemAnimatingView.swift
//  DownFall
//
//  Created by Billy on 7/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SwiftUI

struct Square: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        return path
    }
}

struct CodexItemAnimatingView: View {
    @State var offset: CGFloat = 0
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var storeOffer: StoreOffer
    var spriteSheet: Image {
        Image(storeOffer.textureName)
    }
    
    var columns: CGFloat {
        CGFloat(storeOffer.spriteSheetColumns ?? 1)
    }
    
    var spriteSize: CGFloat {
        CGFloat(dimension * columns)
    }
    
    var initialOffset: CGFloat {
        if columns.truncatingRemainder(dividingBy: 2) == 0 {
            return (columns / 2 - 1) * dimension + dimension/2
        } else {
            return floor(columns / 2) * dimension
        }
    }
    
    let dimension: CGFloat = 32
     
    var body: some View {
        ZStack {
            if (storeOffer.hasSpriteSheet) {
                spriteSheet
                    .offset(x: initialOffset - offset, y: 0)
                    .clipShape(
                        Square().path(in: CGRect(x: initialOffset, y: 0, width: dimension, height: dimension))
                    )
                    .onReceive(timer, perform: { _ in
                        offset += dimension
                        if offset >= dimension * columns {
                            offset = 0
                        }
                    })
            } else {
                spriteSheet
            }
        }
    }
}

struct CodexItemAnimatingView_Previews: PreviewProvider {
    static var previews: some View {
        let testOffer = StoreOffer.offer(type: .greaterHeal, tier: 1)
        
        CodexItemAnimatingView(storeOffer: testOffer).scaleEffect(4.0)
    }
}
