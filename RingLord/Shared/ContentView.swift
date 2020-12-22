//
//  ContentView.swift
//  Shared
//
//  Created by Greg Langmead on 12/20/20.
//

import SwiftUI
import CoreData
import RingCards

struct SetRow: View {
    var set: CardSet

    var body: some View {
        Text(set.name)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    public var sets: [CardSet] = [CardSet.coreSet()]

    var body: some View {
        NavigationView {
//            List{
//                Text("Row1")
//                Text("Row2")
//                Text("Row3")
//            }
            List(sets) { set in
                SetRow(set: set)
            }
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
