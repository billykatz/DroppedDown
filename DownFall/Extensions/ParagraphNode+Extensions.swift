//
//  ParagraphNode+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 5/3/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit
    
func animate(parentNode: SKNode, animator: Animator = Animator(), paragraphNode: ParagraphNode, start: Int, difference: Int, completion: @escaping (ParagraphNode) -> ()) {
    guard difference != 0 else {
        paragraphNode.removeFromParent()
        completion(paragraphNode)
        return
    }
    let oldPosition = paragraphNode.position
    let oldNodeName = paragraphNode.name
    paragraphNode.removeFromParent()
    
//    var animations: [(SKSpriteNode, SKAction)] = []
//    for gain in 1..<abs(difference)+1 {
//        let newCurrencyLabel = ParagraphNode(text: "\(start + gain)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .lightText)
//        newCurrencyLabel.position = oldPosition
//        newCurrencyLabel.isHidden = true
//        parentNode.addChildSafely(newCurrencyLabel)
//        // construct the ticker animation
//
//        var actions: [SKAction] = []
//        // wait before adding it
//        let waitTime = AnimationSettings.Board.goldWaitTime
//        actions.append(SKAction.wait(forDuration: Double(gain) * waitTime))
//        // actually add it
//        actions.append(SKAction.unhide())
//        // wait before removing it
//        actions.append(SKAction.wait(forDuration: waitTime))
//        //remove all but the last one
//        actions.append(SKAction.removeFromParent())
//
//        animations.append((newCurrencyLabel, SKAction.sequence(actions)))
//    }
    
    // show exaclty how much gold was gained as well
    let differencePrefix = difference < 0 ? "-" : "+"
    let gainedGoldLabel = ParagraphNode(text: "\(differencePrefix)\(difference)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: UIFont.extraLargeSize, fontColor: .highlightGold)
    gainedGoldLabel.position = oldPosition.translateVertically(40.0)
    parentNode.addChildSafely(gainedGoldLabel)
    let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: AnimationSettings.HUD.goldGainedTime)
    let sequence = SKAction.sequence([moveUp, SKAction.removeFromParent()])
    gainedGoldLabel.run(sequence)
    
    
    // animate everything we just created
//    animator.animate(animations) {
        let newParagraph = ParagraphNode(text: "\(start+difference)", paragraphWidth: paragraphNode.paragraphWidth)
        newParagraph.name = oldNodeName
        newParagraph.position = oldPosition
        completion(newParagraph)
//    }
    
}
