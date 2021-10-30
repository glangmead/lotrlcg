//
//  InteractiveNode.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/25/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SpriteKit

// base clas of both cards and decks, which show as a single card
class CardlikeNode : SKSpriteNode {
    var frontTexture: SKTexture
    var backTexture: SKTexture
    var faceUp = true
    var enlarged = false
    var savedPosition : CGPoint
    var tableSize : CGSize
    
    init(frontTexture: SKTexture, backTexture: SKTexture, faceUp: Bool, enlarged: Bool, position: CGPoint) {
        self.frontTexture = frontTexture
        self.backTexture = backTexture
        self.faceUp = faceUp
        self.enlarged = enlarged
        self.savedPosition = position
        self.tableSize = CGSize.zero
        
        super.init(texture: faceUp ? frontTexture : backTexture, color: .clear, size: frontTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func update(db : TextureDB, tableSize: CGSize, tableScale: CGFloat) {
        self.tableSize = tableSize
        self.texture = faceUp ? frontTexture : backTexture
        let cardSize = CGSize.aspectFit(originalSize: self.texture!.size(), boundingSize: CGSize(width: tableSize.width * tableScale, height: tableSize.height * tableScale))
        self.scale(to: cardSize)
    }
    
    func getMenuButtons() -> [NodeButton] {
        return []
    }
    
    func dragRequiresLongTouch() -> Bool {
        return false
    }
    
    @objc func flip() {
        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.4)
        
        setScale(1.0)
        
        if self.faceUp {
            run(firstHalfFlip, completion: {
                self.texture = self.backTexture
                self.run(secondHalfFlip)
            })
        } else {
            run(firstHalfFlip, completion: {
                self.texture = self.frontTexture
                self.run(secondHalfFlip)
            })
        }
        faceUp = !faceUp
    }
    
    func syncToModel() {
        // override
    }
    
    // touch handling
    let longPressTime : TimeInterval = 1.0
    var singleTouchStarted : TimeInterval = 0.0
    var moveBegan = false
    var dragStartLocation = CGPoint.zero
    var selfStartLocation = CGPoint.zero
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if (touches.count == 1) {
//            for touch in touches {
//                singleTouchStarted = touch.timestamp
//                dragStartLocation = touch.location(in: self.scene!)
//                selfStartLocation = self.position
//            }
//        }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            var doDrag = false
//            if (!dragRequiresLongTouch() || self.moveBegan || (!self.moveBegan && (touch.timestamp - singleTouchStarted > longPressTime))) {
//                doDrag = true
//            }
//            if (doDrag) {
//                self.moveBegan = true
//                self.position = CGPoint(x: selfStartLocation.x + touch.location(in: self.scene!).x - dragStartLocation.x, y: selfStartLocation.y + touch.location(in: self.scene!).y - dragStartLocation.y)
//            }
//        }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        singleTouchStarted = 0.0
//        moveBegan = false
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touchesEnded(touches, with: event)
//    }
}
