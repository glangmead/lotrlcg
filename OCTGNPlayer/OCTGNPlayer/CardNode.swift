//
//  CardNode.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/23/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SpriteKit

class CardNode : CardlikeNode {
    var card: Card
    var tlLabel: SKLabelNode
    var trLabel: SKLabelNode
    var brLabel: SKLabelNode
    var blLabel: SKLabelNode
    var buttons: [NodeButton]? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(card : Card, db : TextureDB, tableSize: CGSize, tableScale: CGFloat) {
        self.card = card
        let (frontTexture, backTexture) = db.get(card: card)
        var faceUp = false
        if case card.side = CardSide.faceUp {
            faceUp = true
        }
        tlLabel = SKLabelNode()
        trLabel = SKLabelNode()
        brLabel = SKLabelNode()
        blLabel = SKLabelNode()
        super.init(frontTexture: frontTexture, backTexture: backTexture, faceUp: faceUp, enlarged: false, position: CGPoint(x: CGFloat(card.posX), y: CGFloat(card.posY)))
        update(db: db, tableSize: tableSize, tableScale: tableScale)
        self.isUserInteractionEnabled = true
        for label in [tlLabel, trLabel, brLabel, blLabel] {
            label.fontName = "Futura-Medium"
            label.text = "0"
            label.fontColor = SKColor.white
            label.zPosition = 0
        }
    }
    
    override func getMenuButtons() -> [NodeButton] {
        if self.buttons == nil {
            self.buttons = [
                NodeButton(text: "cw", contextNode: self, compassPosition: .E, action: {print("rotating cw \(self)")}),
                NodeButton(text: "ccw", contextNode: self, compassPosition: .W, action: {print("rotating ccw \(self)")}),
                NodeButton(text: "flip", contextNode: self, compassPosition: .N, action: {self.flip()}),
                
                NodeButton(text: "+", contextNode: self, compassPosition: .NW, action: {print("+ \(self)")}),
                NodeButton(text: "+", contextNode: self, compassPosition: .NE, action: {print("+ \(self)")}),
                NodeButton(text: "-", contextNode: self, compassPosition: .SW, action: {print("- \(self)")}),
                NodeButton(text: "-", contextNode: self, compassPosition: .SE, action: {print("- \(self)")}),
                
                NodeButton(text: "-", contextNode: self, compassPosition: .WNW, action: {print("- \(self)")}),
                NodeButton(text: "-", contextNode: self, compassPosition: .ENE, action: {print("- \(self)")}),
                NodeButton(text: "+", contextNode: self, compassPosition: .WSW, action: {print("+ \(self)")}),
                NodeButton(text: "+", contextNode: self, compassPosition: .ESE, action: {print("+ \(self)")}),
            ]
        }
        return self.buttons!
    }
    
    override func syncToModel() {
        card.posX = Double(self.position.x / self.tableSize.width)
        card.posY = Double(self.position.y / self.tableSize.height)
    }
    
    override func update(db : TextureDB, tableSize: CGSize, tableScale: CGFloat) {
        super.update(db: db, tableSize: tableSize, tableScale: tableScale)
        self.position = CGPoint(x: tableSize.width * CGFloat(card.posX), y: tableSize.height * CGFloat(card.posY))
        let margin : CGFloat = self.size.maxDim() * 0.1
        let halfX : CGFloat = (self.size.width / 2) - margin
        let halfY : CGFloat = (self.size.height / 2) - margin
        tlLabel.position = CGPoint(x: -halfX, y: halfY)
        trLabel.position = CGPoint(x: halfX, y: halfY)
        brLabel.position = CGPoint(x: halfX, y: -halfY)
        blLabel.position = CGPoint(x: -halfX, y: -halfY)

        let labels = [tlLabel, trLabel, brLabel, blLabel]
        for i in [0, 1, 2, 3] {
            labels[i].text = String(card.counters[i])
            labels[i].fontSize = self.size.maxDim() * 0.2
            if card.counters[i] != 0 {
                if labels[i].parent == nil {
                    self.addChild(labels[i])
                }
            } else {
                if labels[i].parent != nil {
                    labels[i].removeFromParent()
                }
            }
        }
    }
}
