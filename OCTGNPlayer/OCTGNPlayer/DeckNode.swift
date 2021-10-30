//
//  DeckNode.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/23/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class DeckNode : CardlikeNode {
    var deck : Deck
    var countLabel : SKLabelNode
    var buttons : [NodeButton]? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(deck: Deck, db : TextureDB, tableSize: CGSize, tableScale: CGFloat) {
        self.deck = deck
        let (_, firstBack) = db.get(card: deck.cards.first!)
        let (lastFront, _) = db.get(card: deck.cards.last!)
        self.countLabel = SKLabelNode()

        super.init(frontTexture: lastFront, backTexture: firstBack, faceUp: deck.side == .faceUp, enlarged: false, position: CGPoint(x: CGFloat(deck.posX), y: CGFloat(deck.posY)))

        update(db: db, tableSize: tableSize, tableScale: tableScale)
        self.isUserInteractionEnabled = true
        countLabel.fontName = "Futura-Medium"
        countLabel.text = "0"
        countLabel.fontColor = SKColor.blue
        countLabel.zPosition = 0
        self.addChild(countLabel)
    }

    override func update(db : TextureDB, tableSize: CGSize, tableScale: CGFloat) {
        let (_, firstBack) = db.get(card: deck.cards.first!)
        let (lastFront, _) = db.get(card: deck.cards.last!)
        self.frontTexture = lastFront
        self.backTexture = firstBack
        self.texture = faceUp ? lastFront : firstBack
        super.update(db: db, tableSize: tableSize, tableScale: tableScale)
        self.position = CGPoint(x: tableSize.width * CGFloat(deck.posX), y: tableSize.height * CGFloat(deck.posY))
        self.countLabel.fontSize = self.size.maxDim() * 0.2
        self.countLabel.position = CGPoint(x: self.size.width * 0.4, y: -self.size.height * 0.4)

//        let cardSize = CGSize(width: frontTexture.size().width * tableScale, height: frontTexture.size().height * tableScale)
//        self.scale(to: cardSize)
    }

    override func dragRequiresLongTouch() -> Bool {
        return true
    }
    
    override func getMenuButtons() -> [NodeButton] {
        if self.buttons == nil {
            self.buttons = [
                NodeButton(text: "cw", contextNode: self, compassPosition: .E, action: {print("rotating cw \(self)")}),
                NodeButton(text: "ccw", contextNode: self, compassPosition: .W, action: {print("rotating ccw \(self)")}),
                NodeButton(text: "flip", contextNode: self, compassPosition: .N, action: {self.flip()}),
                NodeButton(text: "shuffle", contextNode: self, compassPosition: .S, action: {print("shuffle \(self)")}),
            ]
        }
        return self.buttons!
    }

    override func syncToModel() {
        deck.posX = Double(self.position.x / self.tableSize.width)
        deck.posY = Double(self.position.y / self.tableSize.height)
    }
    
    func newCardNodeFromTop(db : TextureDB, tableSize: CGSize, tableScale: CGFloat) -> CardNode {
        let topCardNode = CardNode(card: deck.removeTopCard(), db: db, tableSize: tableSize, tableScale: tableScale)
        self.update(db: db, tableSize: tableSize, tableScale: tableScale)
        return topCardNode
    }
}
