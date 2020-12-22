//
//  Card.swift
//  RingLord
//
//  Created by Greg Langmead on 12/22/20.
//

import Foundation

public struct Card: Codable, Identifiable, CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    public let id: String
    public let name: String
    public let number: Int?
    public let quantity: Int?
    public let unique: String?
    public let type: String?
    public let sphere: String?
    public let traits: String?
    public let keywords: String?
    public let cost: String?
    public let willpower: String?
    public let attack: String?
    public let defense: String?
    public let health: String?
    public let text: String?
    public var description: String {
        return "\(quantity ?? 1)x \(name) (\(sphere ?? "") \(type ?? ""))"
    }
    public var playgroundDescription: Any { return description }
}

public struct CardCopies: Codable, CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    public let count: Int
    public let card: Card
    public var description: String {
        return "\(count)x \(card)"
    }
    public var playgroundDescription: Any { return description }
}

