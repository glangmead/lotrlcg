//
//  NodeButton.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 3/28/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import SpriteKit

enum CompassPosition : Int {
    case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
}

class NodeButton : SKNode {
    let compassPosition : CompassPosition
    let action : () -> Void
    let contextNode : SKNode
    var tapGR : UITapGestureRecognizer
    
    init(imageNamed: String, contextNode: SKNode, compassPosition: CompassPosition, action: @escaping () -> Void) {
        self.compassPosition = compassPosition
        self.action = action
        self.contextNode = contextNode
        self.tapGR = UITapGestureRecognizer()
        super.init()
        
        // node hierarchy: contextNode, inside of which is self, inside of which is an inner node to hold the image or text
        let innerNode = SKSpriteNode(imageNamed: imageNamed)
        self.addChild(innerNode)
        innerNode.position = CGPoint.zero
        self.tapGR.addTarget(self, action: #selector(performAction))
        contextNode.addChild(self)
        self.isHidden = true // start out hidden
    }
    
    init(text: String, contextNode: SKNode, compassPosition: CompassPosition, action: @escaping () -> Void) {
        self.compassPosition = compassPosition
        self.action = action
        self.contextNode = contextNode
        self.tapGR = UITapGestureRecognizer()
        super.init()
        
        // node hierarchy: contextNode, inside of which is self, inside of which is an inner node to hold the image or text
        let innerNode = SKLabelNode(text: text)
        innerNode.fontSize = 20
        innerNode.fontColor = UIColor.white
        self.addChild(innerNode)
        innerNode.position = CGPoint.zero
        self.tapGR.addTarget(self, action: #selector(performAction))
        contextNode.addChild(self)
        self.isHidden = true // start out hidden
    }
    
    func setPosition() {
        let contextHalfWidth = self.contextNode.frame.size.width / 2.0
        let contextHalfHeight = self.contextNode.frame.size.height / 2.0
        let contextQuarterWidth = self.contextNode.frame.size.width / 4.0
        let contextQuarterHeight = self.contextNode.frame.size.height / 4.0
        let selfHalfWidth = self.frame.size.width / 2.0
        let selfHalfHeight = self.frame.size.height / 2.0
        var position : CGPoint = CGPoint.zero
        switch compassPosition {
        case .N:
            position.x = 0
            position.y = contextHalfHeight + selfHalfHeight
        case .NNE:
            position.x = contextQuarterWidth
            position.y = contextHalfHeight + selfHalfHeight
        case .NE:
            position.x = contextHalfWidth + selfHalfWidth
            position.y = contextHalfHeight + selfHalfHeight
        case .ENE:
            position.x = contextHalfWidth + selfHalfWidth
            position.y = contextQuarterHeight
        case .E:
            position.x = contextHalfWidth + selfHalfWidth
            position.y = 0
        case .ESE:
            position.x = contextHalfWidth + selfHalfWidth
            position.y = -contextQuarterHeight
        case .SE:
            position.x = contextHalfWidth + selfHalfWidth
            position.y = -contextHalfHeight - selfHalfHeight
        case .SSE:
            position.x = contextQuarterWidth
            position.y = -contextHalfHeight - selfHalfHeight
        case .S:
            position.x = 0
            position.y = -contextHalfHeight - selfHalfHeight
        case .SSW:
            position.x = -contextQuarterWidth
            position.y = -contextHalfHeight - selfHalfHeight
        case .SW:
            position.x = -contextHalfWidth - selfHalfWidth
            position.y = -contextHalfHeight - selfHalfHeight
        case .WSW:
            position.x = -contextHalfWidth - selfHalfWidth
            position.y = -contextQuarterHeight
        case .W:
            position.x = -contextHalfWidth - selfHalfWidth
            position.y = 0
        case .WNW:
            position.x = -contextHalfWidth - selfHalfWidth
            position.y = contextQuarterHeight
        case .NW:
            position.x = -contextHalfWidth - selfHalfWidth
            position.y = contextHalfHeight + selfHalfHeight
        case .NNW:
            position.x = -contextQuarterWidth
            position.y = contextHalfHeight + selfHalfHeight
        }
        self.position = position
    }
    
    @objc func performAction() {
        self.action()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

}
