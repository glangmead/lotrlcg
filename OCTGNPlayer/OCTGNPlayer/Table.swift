//
//  Table.swift
//  CardKit
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation

class Table {
    var cards : [Card]
    var decks : [Deck]
    var config : [String: String]
    
    init() {
        self.cards = []
        self.decks = []
        self.config = ["scale": "0.2"]
    }
    
    init?(json: [String: Any]) {
        guard let cardsJSON = json["cards"] as? [[String: Any]],
            let decksJSON = json["decks"] as? [[String: Any]],
            let config = json["config"] as? [String: String]
        else {
            return nil
        }
        
        self.cards = []
        self.decks = []
        self.config = [:]
        
        for key in config.keys {
            self.config[key] = config[key]
        }
        
        for cardJSON in cardsJSON {
            self.cards.append(Card(json: cardJSON)!)
        }
        
        for deckJSON in decksJSON {
            self.decks.append(Deck(json: deckJSON)!)
        }
    }
    
    func addDeck(_ deck : Deck) {
        self.decks.append(deck)
    }
    
    func toJson() -> String {
        let cardsStr = cards.map {$0.toJson()}.joined(separator: ", ")
        let decksStr = decks.map {$0.toJson()}.joined(separator: ", ")
        return "{ \"cards\": [ \(cardsStr) ], \"decks\": [ \(decksStr) ], \"config\": { } }"
    }
}
