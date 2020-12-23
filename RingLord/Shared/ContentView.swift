//
//  ContentView.swift
//  Shared
//
//  Created by Greg Langmead on 12/20/20.
//

import SwiftUI
import CoreData
import RingCards

struct CardView: View, Identifiable {
    var card: Card
    var id: String { card.id }
    var body: some View {
        ScrollView {
            VStack {
                getImage(root: "/Users/glangmead/proj/lotrlcg/RingLord/images")!.resizable().aspectRatio(contentMode: .fit)
                Text(card.name)
                HStack {
                    Text((card.sphere ?? ""))
                    Text((card.type ?? "") + ".")
                }
                Text((card.traits ?? ""))
                Text("\(card.cost ?? "")/\(card.willpower ?? "")/\(card.attack ?? "")/\(card.defense ?? "")/\(card.health ?? "")")
                Text(card.keywords ?? "")
                Text(card.text ?? "").fixedSize(horizontal: false, vertical: true).padding(20)
                Spacer()
            }
        }.navigationBarTitle(card.name)
    }
    public func getImage(root: String) -> Image? {
        guard let uiimg = UIImage(contentsOfFile: "\(root)/\(card.id).jpg") else {
            return nil
        }
        return Image(uiImage: uiimg)
    }
}

struct CardRow: View, Identifiable {
    var card: Card
    var id: String { card.id }
    var body: some View {
        NavigationLink(
            destination: CardView(card: card),
            label: {
                Text(card.name)
            })
    }
}

struct SetView: View, Identifiable {
    var myset: CardSet
    var id: String { myset.id }
    var body: some View {
        List {
            ForEach(myset.cards) { card in
                CardRow(card: card)
            }
        }.navigationBarTitle(myset.name)
    }
}

struct DeckView: View, Identifiable {
    var deck: Deck
    var id: String { deck.id }
    var body: some View {
        List {
            ForEach(deck.heroes.map { $0.card }) { card in
                CardRow(card: card)
            }
        }.navigationBarTitle(deck.name)
    }
}

struct SetRow: View, Identifiable {
    var myset: CardSet
    var id: String { myset.id }

    var body: some View {
        NavigationLink(
            destination: SetView(myset: myset),
            label: {
                Text(myset.name)
            })
    }
}

struct DeckRow: View, Identifiable {
    var deck: Deck
    var id: String { deck.id }

    var body: some View {
        NavigationLink(
            destination: DeckView(deck: deck),
            label: {
                Text(deck.name)
            })
        
    }
}

struct StringWithId: Identifiable {
    let id: String
    let string: String
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    public var sets: [CardSet] = [CardSet.coreSet()]
    public var decks: [Deck] = Deck.testDecks()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(StringWithId(id: "1", string: "Sets").string)) {
                    ForEach(sets) { set in
                        SetRow(myset: set)
                    }
                }
                Section(header: Text(StringWithId(id: "2", string: "Decks").string)) {
                    ForEach(decks) { deck in
                        DeckRow(deck: deck)
                    }
                }
            }.navigationBarTitle("Lord of the Rings")
            .listStyle(GroupedListStyle())
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

