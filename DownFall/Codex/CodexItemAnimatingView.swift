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
    let unlockable: Unlockable
    
    var storeOffer: StoreOffer {
        return unlockable.item
    }
    
    @State var offset: CGFloat = 0
    
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    
    var spriteSheet: some View {
        Image(storeOffer.textureName)
                .saturation(unlockable.isPurchased ? 1.0 : 0.0)
                .contrast(unlockable.isUnlocked ? 1.0: 0.0)
    }
    
    var clippedSpriteSheet: some View {
        Image(storeOffer.spriteSheetName ?? "")
            .saturation(unlockable.isPurchased ? 1.0 : 0.0)
            .contrast(unlockable.isUnlocked ? 1.0: 0.0)
            .offset(x: initialOffset - offset, y: 0)
            .clipShape(
                Square().path(in: CGRect(x: initialOffset, y: 0, width: dimension, height: dimension))
            )
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
    
    var dimension: CGFloat {
        32
    }
     
    var body: some View {
        ZStack {
            if (storeOffer.hasSpriteSheet && unlockable.isPurchased) {
                clippedSpriteSheet
                    .onReceive(timer, perform: { _ in
                        offset += dimension
                        if offset >= dimension * columns {
                            offset = 0
                        }
                    })
                
            } else if (storeOffer.hasSpriteSheet){
                clippedSpriteSheet
            }
            else {
                spriteSheet
            }
        }
    }
}

struct CodexItemAnimatingView_Previews: PreviewProvider {
    static var previews: some View {
        let testOffer = StoreOffer.offer(type: .greaterHeal, tier: 1)
        
        let unlock = Unlockable(stat: .clockwiseRotations, item: testOffer, purchaseAmount: 50, isPurchased: false, isUnlocked:  false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false)
        
        let unlock2 = Unlockable(stat: .clockwiseRotations, item: StoreOffer.offer(type: .killMonsterPotion, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked:  true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false)
        
        let unlock3 = Unlockable(stat: .clockwiseRotations, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 50, isPurchased: true, isUnlocked:  true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false)
        
        VStack(spacing: 100) {
            CodexItemAnimatingView(unlockable: unlock)
            CodexItemAnimatingView(unlockable: unlock2).scaleEffect(4.0)
            CodexItemAnimatingView(unlockable: unlock3).scaleEffect(4.0)
            
        }
    }
}
