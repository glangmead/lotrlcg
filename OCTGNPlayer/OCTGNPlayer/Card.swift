//
//  Card.swift
//  CardKit
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation

enum CardSide : Int {
    case faceUp = 0
    case faceDown = 1
}

enum CardOrientation : Int {
    case north = 0
    case east = 1
    case south = 2
    case west = 3
}

class Card : Hashable, Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs === rhs
    }
    
    let id : String
    let type : String

    // game state
    var counters : [Int] = [0, 0, 0, 0]
    var posX : Double = 0.5
    var posY : Double = 0.5
    var side : CardSide = .faceUp
    var orientation : CardOrientation = .north
    
    var hashValue : Int {
        return id.hashValue
    }
    
    convenience init(id: String, type: String) {
        self.init(id: id, counters: [0, 0, 0, 0], type: type, posX: 0.5, posY: 0.67)
    }
    
    init(id: String, counters: [Int], type: String, posX: Double, posY: Double) {
        self.id = id
        self.counters = counters
        self.type = type
        self.posX = posX
        self.posY = posY
    }

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let type = json["type"] as? String,
            let counters = json["counters"] as? [Int],
            let side = json["face"] as? Int,
            let orientation = json["orientation"] as? Int,
            let x = json["x"] as? Double,
            let y = json["y"] as? Double
        else {
            return nil
        }
        self.id = id
        self.type = type
        if counters.count == 0 {
            self.counters = [0, 0, 0, 0]
        } else {
            self.counters = counters
        }
        self.posX = x
        self.posY = y
        self.side = CardSide(rawValue: side) ?? .faceUp
        self.orientation = CardOrientation(rawValue: orientation) ?? .north
    }
    
    func toJson() -> String {
        let countersAsStr = counters.map { String($0) }
        let countersStr = countersAsStr.joined(separator: ", ")
        let jsonStr = "{ \"id\": \"\(id)\", \"type\": \"\(type)\", \"counters\": [ \(countersStr) ], \"x\": \(posX), \"y\": \(posY), \"face\": \(self.side.rawValue), \"orientation\": \(self.orientation.rawValue) }"
        return jsonStr
    }
}

extension Card : CustomStringConvertible {
    var description : String {
        return "\(id) (\(type)) \(counters)"
    }
}
