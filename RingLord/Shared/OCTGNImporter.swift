//
//  OCTGNImporter.swift
//  RingLord
//
//  Created by Greg Langmead on 12/22/20.
//

import Foundation
import CoreData
import SwiftUI

public class OCTGNFullImporter {
    public static func importFromRootDir(dir: URL, context: NSManagedObjectContext, logString: Binding<String>) {
        let fileSystem = FileManager.default
        let lotrID = "a21af4e8-be4b-4cda-a6b6-534f9717391f"
        let setsSubdir = "Sets"
        let gameDBSubdir = "GameDatabase"
        let imgSubdir = "ImageDatabase"
        
        let imgURLDict = OCTGNImageHandler.imageURLsByUUIDFromImageURL(rootPath: dir.appendingPathComponent(imgSubdir).appendingPathComponent(lotrID), startUpLevels: 0, logString: logString)
        
        let dates = dateInfo()
        
        let setsParent = dir
            .appendingPathComponent(gameDBSubdir)
            .appendingPathComponent(lotrID)
            .appendingPathComponent(setsSubdir)
        let setsChildren = try! fileSystem.contentsOfDirectory(atPath: setsParent.path)
        setsChildren.forEach { setDir in
            let setXMLURL = setsParent.appendingPathComponent(setDir).appendingPathComponent("set.xml")
            logString.wrappedValue += "Adding set from \(setXMLURL)\n"
            do {
                let setXMLData = try String(contentsOf: setXMLURL, encoding: .utf8)
                var set = OCTGNSetParser().parseFromString(string: setXMLData)
                if let date = dates[set.name] {
                    set.releaseDate = date
                }
                set.addToCoreData(context: context)
                try context.save()
                OCTGNImageHandler.updateCardsWithImages(context: context, urlDict: imgURLDict, logString: logString)
                try context.save()
            } catch {
                logString.wrappedValue += "Skipping nonexistent set: \(setXMLURL)"
            }
        }
    }
    
    static func dateInfo() -> [String: Date] {
        let rawInfo = [
            ["Core Set", "2011-04-20"],
            ["The Hunt for Gollum", "2011-07-21"],
            ["Conflict at the Carrock", "2011-08-10"],
            ["A Journey to Rhosgobel", "2011-09-01"],
            ["The Hills of Emyn Muil", "2011-09-30"],
            ["The Dead Marshes", "2011-11-02"],
            ["Return to Mirkwood", "2011-11-23"],
            ["Khazad-dûm", "2012-01-06"],
            ["Khazad-dum", "2012-01-06"],
            ["The Redhorn Gate", "2012-03-01"],
            ["Road to Rivendell", "2012-03-21"],
            ["The Watcher in the Water", "2012-04-25"],
            ["The Long Dark", "2012-05-16"],
            ["Foundations of Stone", "2012-06-20"],
            ["Shadow and Flame", "2012-08-08"],
            ["Over Hill and Under Hill", "2012-08-17"],
            ["Heirs of Númenor", "2012-11-26"],
            ["On the Doorstep", "2013-02-22"],
            ["The Steward's Fear", "2013-05-09"],
            ["The Drúadan Forest", "2013-05-31"],
            ["Encounter at Amon Dîn", "2013-07-05"],
            ["Assault on Osgiliath", "2013-08-09"],
            ["The Black Riders", "2013-09-20"],
            ["The Blood of Gondor", "2013-10-17"],
            ["The Morgul Vale", "2013-11-15"],
            ["Print on Demand", "2014-01-01"],
            ["The Voice of Isengard", "2014-02-21"],
            ["The Dunland Trap", "2014-06-26"],
            ["The Three Trials", "2014-07-24"],
            ["Trouble in Tharbad", "2014-08-21"],
            ["The Road Darkens", "2014-10-03"],
            ["The Nîn-in-Eilph", "2014-10-23"],
            ["Celebrimbor's Secret", "2014-11-13"],
            ["The Antlered Crown", "2014-12-23"],
            ["The Old Forest", "2015-01-01"],
            ["Fog on the Barrow-downs", "2015-01-01"],
            ["The Lost Realm", "2015-04-03"],
            ["The Treason of Saruman", "2015-04-23"],
            ["The Wastes of Eriador", "2015-07-02"],
            ["Escape from Mount Gram", "2015-07-30"],
            ["Across the Ettenmoors", "2015-09-03"],
            ["The Treachery of Rhudaur", "2015-09-24"],
            ["The Battle of Carn Dûm", "2015-11-06"],
            ["The Land of Shadow", "2015-11-19"],
            ["The Dread Realm", "2015-12-17"],
            ["The Grey Havens", "2016-02-11"],
            ["Flight of the Stormcaller", "2016-05-05"],
            ["The Thing in the Depths", "2016-06-02"],
            ["The Drowned Ruins", "2016-08-01"],
            ["The Flame of the West", "2016-08-03"],
            ["Temple of the Deceived", "2016-09-01"],
            ["A Storm on Cobas Haven", "2016-09-29"],
            ["The City of Corsairs", "2016-10-27"],
            ["The Sands of Harad", "2016-11-23"],
            ["The Mûmakil", "2017-01-30"],
            ["Beneath the Sands", "2017-02-01"],
            ["Race Across Harad", "2017-04-01"],
            ["The Black Serpent", "2017-07-20"],
            ["The Mountain of Fire", "2017-08-16"],
            ["The Dungeons of Cirith Gurat", "2017-12-07"],
            ["The Crossings of Poros", "2018-02-08"],
            ["The Wilds of Rhovanion", "2018-06-14"],
            ["The Withered Heath", "2018-08-16"],
            ["Two-Player Limited Edition Starter", "2018-08-24"],
            ["Roam Across Rhovanion", "2018-10-18"],
            ["Fire in the Night", "2018-12-07"],
            ["The Ghost of Framsburg", "2019-02-07"],
            ["Mount Gundabad", "2019-04-04"],
            ["The Fate of Wilderland", "2019-06-06"],
            ["A Shadow in the East", "2019-08-02"],
            ["Wrath and Ruin", "2019-11-15"],
            ["The City of Ulfast", "2020-01-10"],
            ["Challenge of the Wainriders", "2020-02-07"],
            ["Under the Ash Mountains", "2020-02-18"],
            ["The Land of Sorrow", "2020-02-18"],
            ["Messenger of the King Allies", "2020-02-21"],
            ["The Fortress of Nurn", "2020-06-29"],
            ["The Hunt for the Dreadnaught", "2020-10-01"]
        ]
        
        var dict: [String: Date] = [:]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        rawInfo.forEach { pair in
            dict[pair[0]] = df.date(from: pair[1])
        }
        return dict
    }
}

public class OCTGNImageHandler {
    
    public static func updateCardsWithImages(context: NSManagedObjectContext, urlDict: [UUID: URL], logString: Binding<String>) {
        // fetch Cards with nil images and see if we can fill them in
        let cardFetch: NSFetchRequest<Card> = Card.fetchRequest()
        let nilImgPred: NSPredicate = NSPredicate(format: "%K == nil", "image1")
        cardFetch.predicate = nilImgPred
        do {
            let cards = try context.fetch(cardFetch)
            var numImageFound = 0
            logString.wrappedValue += "Found \(cards.count) cards in need of images\n"
            cards.forEach { card in
                logString.wrappedValue += "Card \(card.name ?? "unk"): "
                if let imageURL = urlDict[card.id!] {
                    if let img = UIImage(contentsOfFile: imageURL.path) {
                        logString.wrappedValue += "found\n"
                        card.image1 = img.pngData()
                        numImageFound += 1
                    } else {
                        logString.wrappedValue += "not found\n"
                    }
                }
            }
            logString.wrappedValue += "Found \(numImageFound) images\n"
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    // return a dictionary from card UUID to image URL, starting from a single such
    // Assumes OCTGN directory layout so that the example image is in ImageDatabase/<game_uuid>/Sets/<set_uuid>/Cards/<card_uuid>.jpg (or .png or whatever)
    public static func imageURLsByUUIDFromImageURL(rootPath: URL, startUpLevels: Int, logString: Binding<String>) -> [UUID: URL] {
        let allImageURLs = leafURLsFromURL(rootPath: rootPath, startUpLevels: startUpLevels, maxResults: 5000, logString: logString)
        return hashURLsByCardID(urls: allImageURLs)
    }
    
    // from an array of URLs of the form /path/to/<uuid>.<extension> (e.g. /Images/0000-0000...jpg), return a dictionary from UUID to URL
    private static func hashURLsByCardID(urls: [URL]) -> [UUID: URL] {
        var dict: [UUID: URL] = [:]
        urls.forEach { url in
            let lastComponent = url.deletingPathExtension().lastPathComponent
            if let id = UUID(uuidString: lastComponent) {
                dict[id] = url
            }
        }
        return dict
    }
    
    private static func leafURLsFromURL(rootPath: URL, startUpLevels: Int, maxResults: Int, logString: Binding<String>) -> [URL] {
        let fileSystem = FileManager.default
        var leaves: [URL] = []
        var startingPath = rootPath
        for _ in 0...startUpLevels {
            startingPath = startingPath.deletingLastPathComponent()
        }
        logString.wrappedValue += "Searching for images from \(startingPath)"
        if let fsTree = fileSystem.enumerator(at: startingPath, includingPropertiesForKeys: nil) {
            while let innerURL = fsTree.nextObject() as? URL {
                var isDir: ObjCBool = false
                fileSystem.fileExists(atPath: innerURL.absoluteString, isDirectory: &isDir)
                if !isDir.boolValue {
                    logString.wrappedValue += "visiting \(innerURL)\n"
                    leaves.append(innerURL)
                    if leaves.count > 6000 {
                        break // escape valve
                    }
                }
            }
        }
        logString.wrappedValue += "Found \(leaves.count) images in the directory"
        return leaves
    }
}

public class OCTGNDeckParser: NSObject, XMLParserDelegate {
    override public init() {
        super.init()
    }
    private var deck: GregDeck? = nil
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

    public func parseFromPath(path: String) -> GregDeck {
        return parseFromString(string: try! String(contentsOfFile: path))
    }
    
    // Read local path XML
    public func parseFromURL(url: URL) -> GregDeck {
        return parseFromString(string: try! String(contentsOf: url, encoding: .utf8))
    }
    
    // Read local path XML
    public func parseFromString(string: String) -> GregDeck {
        let fileData = string.data(using: .utf8)!
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
            deck = GregDeck(name: parseDeckName, heroes: heroes, allies: allies, events: events, attachments: attachments, quests: quests, encounters: encounters, special: special, setup: setup, sidequest: sidequest, sideboard: sideboard)
        } else if elementName == "section" {
            // convert all the saved card info into Cards in the right array
            for i in 0..<parseCardIDs.count {
                let c = MemoryCard(id: parseCardIDs[i], name: parseCardNames[i], number: nil, quantity: nil, unique: nil, type: nil, sphere: nil, traits: nil, keywords: nil, cost: nil, willpower: nil, attack: nil, defense: nil, health: nil, text: nil)
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
    private var cards: [MemoryCard] = []
    
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
        return parseFromString(string: try! String(contentsOfFile: path))
    }
    
    // Read local path XML
    public func parseFromURL(url: URL) -> CardSet {
        return parseFromString(string: try! String(contentsOf: url, encoding: .utf8))
    }
    
    public func parseFromString(string : String) -> CardSet {
        let fileData = string.data(using: .utf8)!
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
            set = CardSet(name: parseSetName, id: parseSetID, cards: cards, releaseDate: Date.init(timeIntervalSinceNow: 0))
        } else if elementName == "card" {
            cards.append(MemoryCard(id: parseCardID,
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

extension GregDeck {
    func addToCoreData(context: NSManagedObjectContext) {
        let d = Deck(context: context)
        d.name = name
        d.id = UUID()
        // heroes
        // allies
        // events
        // attachments
        // quests
        // encounters
        // special
        // setup
        // sidequest
        // sideboard
        let lists = [heroes, allies, events, attachments, quests, encounters, special, setup, sidequest, sideboard]
        lists.forEach { list in
            list.forEach { card in
                let dc = DeckCard(context: context)
                dc.deck = d
                
            }
        }
        
        
        
        
    }
}

extension CardSet {
    func addToCoreData(context: NSManagedObjectContext) {
        let prod = Product(context: context)
        prod.name = name
        prod.id = UUID(uuidString: id)
        prod.releasedOn = releaseDate
        // TODO prod.releasedOn =
        cards.forEach { card in
            // join table
            let prodCard = ProductCard(context: context)
            prodCard.count = Int32(card.quantity ?? 1)
            prodCard.product = prod
            // card table
            let coreDataCard = Card(context: context)
            coreDataCard.name = card.name
            coreDataCard.id = UUID(uuidString: card.id)
            coreDataCard.quantityInSet = Int32(card.quantity ?? 1)
            coreDataCard.numberInSet = Int32(card.number!)
            coreDataCard.attack = card.attack
            coreDataCard.cost = card.cost
            coreDataCard.defense = card.defense
            coreDataCard.health = card.health
            coreDataCard.keywords = card.keywords
            coreDataCard.sphere = card.sphere
            coreDataCard.text = card.text
            coreDataCard.traits = card.traits
            coreDataCard.type = card.type
            coreDataCard.willpower = card.willpower
            coreDataCard.unique = card.unique
            prodCard.card = coreDataCard
        }
    }
}
