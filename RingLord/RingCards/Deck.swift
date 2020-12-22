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

