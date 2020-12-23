//
//  Deck.swift
//  RingLord
//
//  Created by Greg Langmead on 12/22/20.
//

import Foundation

public struct Deck: Codable, Identifiable, CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    public let name: String
    public var id: String {return name}
    public let heroes: [CardCopies]
    public let allies: [CardCopies]
    public let events: [CardCopies]
    public let attachments: [CardCopies]
    public let quests: [CardCopies]
    public let encounters: [CardCopies]
    public let special: [CardCopies]
    public let setup: [CardCopies]
    public let sidequest: [CardCopies]
    public let sideboard: [CardCopies]
    public var description: String {
        return "Deck \(name): Heroes \(heroes)"
    }
    public var playgroundDescription: Any { return description }
}

extension Deck {
public static func testDecks() -> [Deck] {
    return [
        Deck(name: "Seastan Core Solo", heroes: [CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9002", name: "Théodred", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9007", name: "Éowyn", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9012", name: "Beravor", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil))], allies: [CardCopies(count: 3, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9013", name: "Guard of the Citadel", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9014", name: "Faramir", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9015", name: "Son of Arnor", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 3, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9016", name: "Snowbourn Scout", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9017", name: "Silverlode Archer", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9031", name: "Beorn", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9045", name: "Northern Tracker", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9059", name: "Erebor Hammersmith", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9060", name: "Henamarth Riversong", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9061", name: "Miner of the Iron Hills", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9062", name: "Gléowine", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 3, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9073", name: "Gandalf", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil))], events: [CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9020", name: "Ever Vigilant", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9023", name: "Sneak Attack", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9025", name: "Grim Resolve", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9046", name: "The Galadhrim\'s Greeting", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9048", name: "Hasty Stroke", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9050", name: "A Test of Will", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9051", name: "Stand and Fight", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9053", name: "Dwarven Tomb", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9064", name: "Lórien\'s Wealth", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil))], attachments: [CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9026", name: "Steward of Gondor", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9027", name: "Celebrían\'s Stone", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 1, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9057", name: "Unexpected Courage", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9069", name: "Forest Snare", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9070", name: "Protector of Lórien", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)), CardCopies(count: 2, card:
          Card(id: "51223bd0-ffd1-11df-a976-0801200c9072", name: "Self Preservation", number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil))], quests: [], encounters: [], special: [], setup: [], sidequest: [], sideboard: []),
    ]

}
}
