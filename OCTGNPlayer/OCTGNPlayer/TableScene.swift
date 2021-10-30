//
//  TableScene.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/20/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SpriteKit

class TableScene : SKScene, UIGestureRecognizerDelegate {
    var table : Table
    let tapAction : (() -> ())
    var cardNodes : [Card:CardNode]
    var deckNodes : [Deck:DeckNode]
    var scale : CGFloat {
        didSet {
            self.table.config["scale"] = String(Float(scale))
        }
    }
    
    var selectedNode : SKNode? = nil

    var longPressTakingPlace = false
    var tapGR : UITapGestureRecognizer
    var dragGR : UIPanGestureRecognizer
    var doubleTapGR : UITapGestureRecognizer
    var longPressGR : UILongPressGestureRecognizer
    
    var textureDB : TextureDB
    
    init(table: Table, size: CGSize, tapAction: @escaping (() -> ()) ){
        self.table = table
        self.tapAction = tapAction
        self.scale = CGFloat(Float(table.config["scale", default: "0.2"])!)
        self.cardNodes = [:]
        self.deckNodes = [:]
        self.tapGR = UITapGestureRecognizer()
        self.dragGR = UIPanGestureRecognizer()
        self.doubleTapGR = UITapGestureRecognizer()
        self.longPressGR = UILongPressGestureRecognizer()
        self.textureDB = TextureDB()
        super.init(size: size)

        for gr in [self.tapGR, self.dragGR, self.doubleTapGR, self.longPressGR] {
            gr.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        self.tapGR.addTarget(self, action: #selector(callTapAction))
        self.dragGR.addTarget(self, action: #selector(handlePanFrom))
        self.doubleTapGR.addTarget(self, action: #selector(callTapAction))
        self.longPressGR.addTarget(self, action: #selector(longPressAction))
        self.view?.addGestureRecognizer(self.tapGR)
        self.view?.addGestureRecognizer(self.dragGR)
        self.view?.addGestureRecognizer(self.doubleTapGR)
        self.view?.addGestureRecognizer(self.longPressGR)
    }
    
    func syncFromModel(tableSize: CGSize) {
        for card in self.table.cards {
            if let cardNode = cardNodes[card] {
                cardNode.update(db: textureDB, tableSize: tableSize, tableScale: self.scale)
            } else {
                let node = CardNode(card: card, db: textureDB, tableSize: tableSize, tableScale: self.scale)
                cardNodes[card] = node
                node.position = CGPoint(x: tableSize.width * CGFloat(card.posX), y: tableSize.height * CGFloat(card.posY))
                self.addChild(node)     
            }
        }
        for deck in self.table.decks {
            if let deckNode = deckNodes[deck] {
                deckNode.update(db: textureDB, tableSize: tableSize, tableScale: self.scale)
            } else {
                let node = DeckNode(deck: deck, db: textureDB, tableSize: tableSize, tableScale: self.scale)
                deckNodes[deck] = node
                node.position = CGPoint(x: tableSize.width * CGFloat(deck.posX), y: tableSize.height * CGFloat(deck.posY))
                self.addChild(node)
            }
        }

    }
    
    func syncToModel() {
        self.cardNodes.values.forEach {$0.syncToModel()}
        self.deckNodes.values.forEach {$0.syncToModel()}
        self.table.cards = self.cardNodes.keys.sorted()
        self.table.decks = self.deckNodes.keys.sorted()
    }
    
    @objc func longPressAction() {
        self.longPressTakingPlace = true
        self.selectedNode = nil
    }
    
    @objc func callTapAction(recognizer: UITapGestureRecognizer) {
        // intended to be for actions like toggling the toolbar, i.e. table-wide UI
        self.longPressTakingPlace = false
        self.tapAction()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.longPressGR && otherGestureRecognizer == self.dragGR {
            return true
        }
        return false
    }
    
    func selectNodeForTouch(_ touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            if selectedNode == nil || !selectedNode!.isEqual(touchedNode) {
                if touchedNode is DeckNode && !self.longPressTakingPlace {
                    let topCardNode = (touchedNode as! DeckNode).newCardNodeFromTop(db: textureDB, tableSize: self.size, tableScale: self.scale)
                    cardNodes[topCardNode.card] = topCardNode
                    topCardNode.position = touchedNode.position
                    self.addChild(topCardNode)
                    self.selectedNode = topCardNode
                } else {
                    self.selectedNode?.removeAllActions()
                    self.selectedNode = touchedNode as! SKSpriteNode
                }
            }
        }
    }
    
    func panForTranslation(_ translation: CGPoint) {
        let position = selectedNode!.position
        
        self.selectedNode!.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
    }
    
    @objc func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.selectedNode = nil
            var touchLocation = recognizer.location(in: recognizer.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            
            self.selectNodeForTouch(touchLocation)
        } else if recognizer.state == .changed {
            var translation = recognizer.translation(in: recognizer.view!)
            translation = CGPoint(x: translation.x, y: -translation.y)
            
            self.panForTranslation(translation)
            
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        } else if recognizer.state == .ended {
            self.selectedNode!.removeAllActions()
            syncToModel()
            self.selectedNode = nil
        }
        self.longPressTakingPlace = false
    }
}
