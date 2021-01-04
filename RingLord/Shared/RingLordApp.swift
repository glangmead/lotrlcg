//
//  RingLordApp.swift
//  Shared
//
//  Created by Greg Langmead on 12/20/20.
//

import SwiftUI
import CoreData

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

//struct BackgroundManagedObjectContextKey: EnvironmentKey {
//    static var defaultValue: NSManagedObjectContext? = nil
//}
//
//extension EnvironmentValues {
//    var backgroundManagedObjectContext: NSManagedObjectContext? {
//        get { self[BackgroundManagedObjectContextKey.self] }
//        set { self[BackgroundManagedObjectContextKey.self] = newValue }
//    }
//}
