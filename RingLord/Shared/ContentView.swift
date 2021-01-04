//
//  ContentView.swift
//  Shared
//
//  Created by Greg Langmead on 12/20/20.
//

import SwiftUI
import CoreData
import UIKit

struct CardView: View, Identifiable {
    @ObservedObject var card: Card
    var id: String { card.id!.uuidString }
    var body: some View {
        ScrollView {
            VStack {
                if let imgdata = card.image1 {
                    if let img = UIImage(data: imgdata) {
                        Image(uiImage: img)
                    }
                }
                Text(card.name!)
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
        }.navigationBarTitle(card.name!)
    }
    public func getImage(root: String) -> Image? {
        guard let uiimg = UIImage(contentsOfFile: "\(root)/\(card.id!.uuidString).jpg") else {
            return nil
        }
        return Image(uiImage: uiimg)
    }
}

struct CardRow: View, Identifiable {
    @ObservedObject var card: Card
    var id: String { card.id!.uuidString }
    var body: some View {
        NavigationLink(
            destination: CardView(card: card),
            label: {
                Text(card.name!)
            })
    }
}

struct SetView: View, Identifiable {
    @ObservedObject var myset: Product
    var id: UUID { myset.id! }
    var body: some View {
        List {
            ForEach(productCardArray(prod: myset)) { card in
                CardRow(card: card)
            }
        }.navigationBarTitle(myset.name!)
    }
}

func productCardArray(prod: Product) -> [Card] {
    let pcs = prod.productcards as? Set<ProductCard> ?? []
    let cs = pcs.map { pc in
        pc.card!
    }
    return cs.sorted(by: \.numberInSet)
}

func deckCardArray(deck: Deck) -> [Card] {
    let dcs = deck.deckcards as? Set<DeckCard> ?? []
    let cs = dcs.map { dc in
        dc.card!
    }
    return cs.sorted(by: \.numberInSet)
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

struct DeckView: View, Identifiable {
    @ObservedObject var deck: Deck
    var id: UUID { deck.id! }
    var body: some View {
        List {
            ForEach(deckCardArray(deck: deck)) { card in
                CardRow(card: card)
            }
        }.navigationBarTitle(deck.name!)
    }
}

struct SetRow: View, Identifiable {
    @ObservedObject var myset: Product
    var id: UUID { myset.id! }

    var body: some View {
        NavigationLink(
            destination: SetView(myset: myset),
            label: {
                Text(myset.name!)
            })
    }
}

struct DeckRow: View, Identifiable {
    @ObservedObject var deck: Deck
    var id: UUID { deck.id! }

    var body: some View {
        NavigationLink(
            destination: DeckView(deck: deck),
            label: {
                Text(deck.name!)
            })
        
    }
}

struct StringWithId: Identifiable {
    let id: String
    let string: String
}

enum ActiveSheet: Identifiable {
    case docPicker
    
    var id: Int {
        hashValue
    }
}

struct LogView: View {
    @Binding var log: String
    var body: some View {
        ScrollView {
            Text(log)
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.releasedOn, ascending: true)],
        animation: .default) var products: FetchedResults<Product>
//    private var sets: [Product] = []//[CardSet.coreSet()]
    private var decks: [Deck] = []//Deck.testDecks()
    @State var activeSheet: ActiveSheet?
    @State private var showDocPicker = false
    @State private var urlsToImport: [URL] = []

    @State private var importLogMessages: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text(StringWithId(id: "1", string: "Sets (\(products.count))").string)) {
                        ForEach(products) { set in
                            SetRow(myset: set)
                        }
                    }
                    Section(header: Text(StringWithId(id: "2", string: "Decks (\(decks.count))").string)) {
                        ForEach(decks) { deck in
                            DeckRow(deck: deck)
                        }
                    }
                    if !importLogMessages.isEmpty {
                        Section(header: Text(StringWithId(id: "3", string: "Log").string)) {
                            NavigationLink(destination:LogView(log: $importLogMessages), label: { Text("Log").fixedSize(horizontal: false, vertical: true).padding(2) })
                        }
                    }
                }
                .navigationBarTitle("Lord of the Rings")
                .listStyle(GroupedListStyle())
                .navigationBarItems(trailing: Button(action: {
                    activeSheet = .docPicker
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                )
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .docPicker:
                        DocumentPicker(urlsToImport: $urlsToImport)
                    }
                }
                .onChange(of: urlsToImport, perform: { urls in
                    urls.forEach { url in
                        let ext = url.pathExtension
                        if ext.contains(".o8d") {
                            let deck = OCTGNDeckParser().parseFromURL(url: url)
                            print(deck)
                        }
                        if ext == "" {
                            let backgroundContext = persistenceController.container.newBackgroundContext()
                            backgroundContext.automaticallyMergesChangesFromParent = true
                            backgroundContext.perform {
                                // https://duncsand.medium.com/threading-43a9081284e5
                                guard url.startAccessingSecurityScopedResource() else {
                                    // Handle the failure here.
                                    return
                                }
                                defer { url.stopAccessingSecurityScopedResource() }
                                OCTGNFullImporter.importFromRootDir(dir: url, context: backgroundContext, logString: $importLogMessages)
                            }
                        }
                    }
                    print(importLogMessages)
                })
            }
        }
    }
}

extension Card {
    func addToCoreData() {
        
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    
    @Binding var urlsToImport: [URL]

    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(urlsToImport: $urlsToImport)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) ->  UIDocumentPickerViewController {
        // https://capps.tech/blog/read-files-with-documentpicker-in-swiftui
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) { }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @Binding var urlsToImport: [URL]
    init(urlsToImport: Binding<[URL]>) {
        _urlsToImport = urlsToImport
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urlsToImport = urls
    }
}
