//
//  AppApp.swift
//  App
//
//  Created by Lorenzo Giacomelli on 28.04.25.
//

import SwiftUI

@main
struct AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
