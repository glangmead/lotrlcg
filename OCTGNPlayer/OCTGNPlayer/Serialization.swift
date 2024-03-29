//
//  Serialization.swift
//  CardKit
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class Serialization {
    let testData = """
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<deck game="a21af4e8-be4b-4cda-a6b6-534f9717391f">
  <section name="Hero" shared="False">
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9002">Théodred</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9007">Éowyn</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9012">Beravor</card>
  </section>
  <section name="Ally" shared="False">
    <card qty="3" id="51223bd0-ffd1-11df-a976-0801200c9013">Guard of the Citadel</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9014">Faramir</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9015">Son of Arnor</card>
    <card qty="3" id="51223bd0-ffd1-11df-a976-0801200c9016">Snowbourn Scout</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9017">Silverlode Archer</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9031">Beorn</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9045">Northern Tracker</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9059">Erebor Hammersmith</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9060">Henamarth Riversong</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9061">Miner of the Iron Hills</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9062">Gléowine</card>
    <card qty="3" id="51223bd0-ffd1-11df-a976-0801200c9073">Gandalf</card>
  </section>
  <section name="Attachment" shared="False">
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9026">Steward of Gondor</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9027">Celebrían&#039;s Stone</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9057">Unexpected Courage</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9069">Forest Snare</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9070">Protector of Lórien</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9072">Self Preservation</card>
  </section>
  <section name="Event" shared="False">
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9020">Ever Vigilant</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9023">Sneak Attack</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9025">Grim Resolve</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9046">The Galadhrim&#039;s Greeting</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9048">Hasty Stroke</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9050">A Test of Will</card>
    <card qty="2" id="51223bd0-ffd1-11df-a976-0801200c9051">Stand and Fight</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9053">Dwarven Tomb</card>
    <card qty="1" id="51223bd0-ffd1-11df-a976-0801200c9064">Lórien&#039;s Wealth</card>
  </section>
  <section name="Side Quest" shared="False">
  </section>
  <section name="Sideboard" shared="False">
  </section>
  <section name="Quest" shared="True" />
  <section name="Encounter" shared="True" />
  <section name="Special" shared="True" />
  <section name="Setup" shared="True" />
  <notes><![CDATA[]]></notes>
</deck>
"""
    func testXML() {
        let deck = deckFromOCTGNXML(data: testData.data(using: .utf8)!)
        print(deck)
    }
    func deckFromOCTGNXML(data : Data) -> Deck {
        let xml = XML.parse(data)
        var ckCards : [Card] = []
        for section in xml.deck.section {
            let secName = section.attributes["name"]!
            for card in section.card {
                let quantity = Int(card.attributes["qty"]!)!
                let id = card.attributes["id"]
                for _ in 1...quantity {
                    ckCards.append(Card(id: id!, type: secName))
                }
            }
        }
        return Deck(name: "Deck", cards: ckCards)
    }
}
