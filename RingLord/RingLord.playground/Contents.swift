import SwiftUI
import PlaygroundSupport

//let decoder = JSONDecoder()
//let dateFormatter = DateFormatter()
//dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//dateFormatter.locale = Locale(identifier: "en_US")
//dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//decoder.dateDecodingStrategy = .formatted(dateFormatter)

//let testSet = OCTGNSetParser().parseFromPath(path: "/Users/glangmead/proj/RingLord/octgn_lotr_gamedatabase/Sets/f4cf78f5-83dc-40e5-8175-b634844fb641/set.xml")
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

public struct Deck: Codable, Identifiable {
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
//    public var description: String {
//        return "Deck \(name): Heroes \(heroes)"
//    }
//    public var playgroundDescription: Any { return description }
}

public struct Card: Codable, Identifiable {
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
//    public var description: String {
//        return "\(quantity ?? 1)x \(name) (\(sphere ?? "") \(type ?? ""))"
//    }
//    public var playgroundDescription: Any { return description }
}

public struct CardCopies: Codable {
    public let count: Int
    public let card: Card
//    public var description: String {
//        return "\(count)x \(card)"
//    }
//    public var playgroundDescription: Any { return description }
}

public struct Cycle {} // ordered list of packs
public struct Quest {} // list of quest cards and list of encounter cards (also heroes?) with duplication. Future: "Staging Setup" and other octgn details

public struct CardSet: Codable, Identifiable {
    public let name: String
    public let id: String
    public let cards: [Card]
//    public var description: String { return "Set '\(name)', \(cards.count) cards\n  \(cards)" }
//    public var playgroundDescription: Any { return description }
}

public struct Pack: Codable, Identifiable {
    public let name: String
    public let code: String
    public let position: Int
    public let cyclePosition: Int
    public let ringdDBId: Int
    public var id: Int { return ringdDBId }
//    public var description: String {
//        return "Pack \(name)"
//    }
//    public var playgroundDescription: Any { return description }
}
let fm = FileManager()
let setsDir = NSHomeDirectory().appending("/proj/RingLord/octgn_lotr_gamedatabase/Sets/")
let setEnum = fm.enumerator(atPath: setsDir)
var sets: [CardSet] = []
var totalCards = 0
while let file = setEnum?.nextObject() as? String {
    if file.hasSuffix("0801200c9000/set.xml") {
        let set = OCTGNSetParser().parseFromPath(path: "\(setsDir)/\(file)")
        let numCards = set.cards.count
        sets.append(set)
        totalCards += numCards
        print("read \(file) with \(numCards) cards, \(totalCards) total")
    }
}
sets.map {print($0)}
//let scenarioDeckPaths = Path.glob("octgn_lotr_gamedatabase/Decks/Quests/*/*.o8d")
//let scenarioDecks = scenarioDeckPaths.map {deckParser.parseFromPath($0.string)}
//
//let seastanCoreDeck = deckParser.parseFromPath(path: "/Users/glangmead/proj/RingLord/seastan-s-single-core-set-solo-2.0.o8d")
