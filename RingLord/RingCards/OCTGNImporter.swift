//
//  OCTGNImporter.swift
//  RingLord
//
//  Created by Greg Langmead on 12/22/20.
//

import Foundation

public class OCTGNDeckParser: NSObject, XMLParserDelegate {
    override public init() {
        super.init()
    }
    private var deck: Deck? = nil
    private var currentElement = ""
    
    private var parseDeckName = ""
    private var parseSectionName = ""
    private var parseCardIDs: [String] = []
    private var parseCardName = ""
    private var parseCardNames: [String] = []
    private var parseCardCounts: [Int] = []
    
    private var heroes: [CardCopies] = []
    private var allies: [CardCopies] = []
    private var events: [CardCopies] = []
    private var attachments: [CardCopies] = []
    private var quests: [CardCopies] = []
    private var encounters: [CardCopies] = []
    private var special: [CardCopies] = []
    private var setup: [CardCopies] = []
    private var sidequest: [CardCopies] = []
    private var sideboard: [CardCopies] = []

    // Read local path XML
    public func parseFromPath(path: String) -> Deck {
        let fileContents = try! String(contentsOfFile: path)
        let fileData = fileContents.data(using: .utf8)!
        let parser = XMLParser(data: fileData)
        parser.delegate = self
        parser.parse()
        return deck!
    }
    
    //MARK: - XMLParser Delegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "section" {
            parseSectionName = attributeDict["name"]!
        } else if currentElement == "card" {
            parseCardIDs.append(attributeDict["id"]!)
            parseCardCounts.append(Int(attributeDict["qty"]!)!)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "card": parseCardName.append(string)
        default: break
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "card" {
            parseCardNames.append(parseCardName)
            parseCardName = ""
            currentElement = ""
        } else if elementName == "deck" {
            deck = Deck(name: parseDeckName, heroes: heroes, allies: allies, events: events, attachments: attachments, quests: quests, encounters: encounters, special: special, setup: setup, sidequest: sidequest, sideboard: sideboard)
        } else if elementName == "section" {
            // convert all the saved card info into Cards in the right array
            for i in 0..<parseCardIDs.count {
                let c = Card(id: parseCardIDs[i], name: parseCardNames[i], number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)
                let cc = CardCopies(count: parseCardCounts[i], card: c)
                if parseSectionName == "Hero" {
                    heroes.append(cc)
                } else if parseSectionName == "Ally" {
                    allies.append(cc)
                } else if parseSectionName == "Attachment" {
                    attachments.append(cc)
                } else if parseSectionName == "Event" {
                    events.append(cc)
                } else if parseSectionName == "Side Quest" {
                    sidequest.append(cc)
                } else if parseSectionName == "Sideboard" {
                    sideboard.append(cc)
                } else if parseSectionName == "Quest" {
                    quests.append(cc)
                } else if parseSectionName == "Encounter" {
                    encounters.append(cc)
                } else if parseSectionName == "Special" {
                    special.append(cc)
                } else if parseSectionName == "Setup" {
                    setup.append(cc)
                }
            }
            parseCardIDs = []
            parseCardName = ""
            parseCardNames = []
            parseCardCounts = []
        }
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        deck = nil
        parseDeckName = ""
        parseSectionName = ""
        parseCardIDs = []
        parseCardName = ""
        parseCardNames = []
        parseCardCounts = []
        heroes = []
        allies = []
        events = []
        attachments = []
        quests = []
        encounters = []
        special = []
        setup = []
        sidequest = []
        sideboard = []
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }}

public class OCTGNSetParser: NSObject, XMLParserDelegate {
    override public init() {
        super.init()
    }
    private var set: CardSet? = nil
    private var cards: [Card] = []
    
    // Reach to destinated Tag Here i.e item in feed
    private var currentElement = ""

    private var parseSetName = ""
    private var parseSetID = ""

    private var parseCardName = ""
    private var parseCardID = ""

    private var parseCardNum: String? = nil
    private var parseCardQuantity: String? = nil
    private var parseCardSphere: String? = nil
    private var parseCardTraits: String? = nil
    private var parseCardCost: String? = nil
    private var parseCardWillpower: String? = nil
    private var parseCardUnique: String? = nil
    private var parseCardType: String? = nil
    private var parseCardKeywords: String? = nil
    private var parseCardAttack: String? = nil
    private var parseCardDefense: String? = nil
    private var parseCardHealth: String? = nil
    private var parseCardText: String? = nil

    // Read local path XML
    public func parseFromPath(path: String) -> CardSet {
        let fileContents = try! String(contentsOfFile: path)
        let fileData = fileContents.data(using: .utf8)!
        let parser = XMLParser(data: fileData)
        parser.delegate = self
        parser.parse()
        return set!
    }
    
    //MARK: - XMLParser Delegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "set" {
            parseSetID = attributeDict["id"]!
            parseSetName = attributeDict["name"]!
        }
        if currentElement == "card" {
            parseCardID = attributeDict["id"]!
            parseCardName = attributeDict["name"]!
            parseCardNum = nil
            parseCardQuantity = nil
            parseCardSphere = nil
            parseCardTraits = nil
            parseCardCost = nil
            parseCardWillpower = nil
            parseCardUnique = nil
            parseCardType = nil
            parseCardKeywords = nil
            parseCardAttack = nil
            parseCardDefense = nil
            parseCardHealth = nil
            parseCardText = nil
        }
        if currentElement == "property" {
            let propName = attributeDict["name"]
            let propVal = attributeDict["value"]
            if propName == "Card Number" {
                parseCardNum = propVal
            }
            if propName == "Quantity" {
                parseCardQuantity = propVal
            }
            if propName == "Unique" {
                parseCardUnique = propVal
            }
            if propName == "Type" {
                parseCardType = propVal
            }
            if propName == "Sphere" {
                parseCardSphere = propVal
            }
            if propName == "Traits" {
                parseCardTraits = propVal
            }
            if propName == "Keywords" {
                parseCardKeywords = propVal
            }
            if propName == "Cost" {
                parseCardCost = propVal
            }
            if propName == "Willpower" {
                parseCardWillpower = propVal
            }
            if propName == "Attack" {
                parseCardAttack = propVal
            }
            if propName == "Defense" {
                parseCardDefense = propVal
            }
            if propName == "Health" {
                parseCardHealth = propVal
            }
            if propName == "Text" {
                parseCardText = propVal
            }
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title": parseCardName += string
            default: break
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "set" {
            set = CardSet(name: parseSetName, id: parseSetID, cards: cards)
        } else if elementName == "card" {
            cards.append(Card(id: parseCardID,
                name: parseCardName,
                number: Int(parseCardNum ?? "0"),
                quantity: Int(parseCardQuantity ?? "1"),
                unique: parseCardUnique,
                type: parseCardType,
                sphere: parseCardSphere,
                traits: parseCardTraits,
                keywords: parseCardKeywords,
                cost: parseCardCost,
                willpower: parseCardWillpower,
                attack: parseCardAttack,
                defense: parseCardDefense,
                health: parseCardHealth,
                text: parseCardText
            ))
        }
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        set = nil
        cards = []
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}

