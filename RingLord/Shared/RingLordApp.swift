//
//  RingLordApp.swift
//  Shared
//
//  Created by Greg Langmead on 12/20/20.
//

import SwiftUI

@main
struct RingLordApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
