//
//  Deck.swift
//  CardKit
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation

class Deck : Hashable, CustomStringConvertible, Comparable {
    static func < (lhs: Deck, rhs: Deck) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        return lhs === rhs
    }
    
    var name : String
    var cards : [Card]

    // game state
    var posX : Double = 0.5
    var posY : Double = 0.5
    var side : CardSide = .faceUp
    var orientation : CardOrientation = .north

    var description : String {
        return "\(cards)"
    }
    var hashValue : Int {
        return cards.map{$0.hashValue}.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
    
    init(name: String, cards: [Card]) {
        self.name = name
        self.cards = cards
    }
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
            let cardsJSON = json["cards"] as? [[String: Any]],
            let side = json["face"] as? Int,
            let orientation = json["orientation"] as? Int,
            let x = json["x"] as? Double,
            let y = json["y"] as? Double
        else {
                return nil
        }
        
        self.name = name
        var cards : [Card] = []
        for cardJSON in cardsJSON {
            guard let card = Card(json: cardJSON) else {
                return nil
            }
            cards.append(card)
        }
        self.cards = cards
        self.posX = x
        self.posY = y
        self.side = CardSide(rawValue: side) ?? .faceUp
        self.orientation = CardOrientation(rawValue: orientation) ?? .north
    }
    
    func toJson() -> String {
        let cardsStrs = cards.map {$0.toJson()}
        let cardsStr = cardsStrs.joined(separator: ", ")
        let jsonStr = "{ \"name\": \"\(name)\", \"cards\": [ \(cardsStr) ], \"x\": \(posX), \"y\": \(posY), \"face\": \(self.side.rawValue), \"orientation\": \(self.orientation.rawValue) }"
        return jsonStr
    }
    
    func firstCard() -> Card {
        return cards.first!
    }
    
    func removeFirstCard() -> Card {
        return cards.remove(at: 0)
    }

    func lastCard() -> Card {
        return cards.last!
    }
    
    func removeLastCard() -> Card {
        return cards.remove(at: cards.endIndex - 1)
    }
    
    func removeTopCard() -> Card {
        switch self.side {
        case .faceUp:
            return removeLastCard()
        case .faceDown:
            return removeFirstCard()
        }
    }
}
