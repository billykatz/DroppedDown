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

    // show exaclty how much gold was gained as well
    let differencePrefix = difference < 0 ? "" : "+"
    let color: UIColor = difference < 0 ? .lightBarRed : .highlightGold
    let gainedGoldLabel = ParagraphNode(text: "\(differencePrefix)\(difference)", paragraphWidth: Style.HUD.labelParagraphWidth, fontName: UIFont.pixelFontName, fontSize: .fontExtraLargeSize, fontColor: color)
    gainedGoldLabel.position = oldPosition.translateVertically(40.0)
    parentNode.addChildSafely(gainedGoldLabel)
    let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 25), duration: AnimationSettings.HUD.goldGainedTime)
    let fade = SKAction.fadeOut(withDuration: AnimationSettings.HUD.goldGainedTime)
    let groupMoveUpFade = SKAction.group([moveUp, fade])
    let sequence = SKAction.sequence([groupMoveUpFade, SKAction.removeFromParent()])
    gainedGoldLabel.run(sequence)
    
    
    // animate everything we just created
//    animator.animate(animations) {
        let newParagraph = ParagraphNode(text: "\(start+difference)", paragraphWidth: paragraphNode.paragraphWidth)
        newParagraph.name = oldNodeName
        newParagraph.position = oldPosition
        completion(newParagraph)
//    }
    
}
