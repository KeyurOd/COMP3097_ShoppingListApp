//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//

import SwiftUI

@main
struct ShoppingListApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView() 
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showSplash = false
                        }
                    }
            } else {
                CategoryListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}

