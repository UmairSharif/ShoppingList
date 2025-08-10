//
//  ContentView.swift
//  ShoppingList
//
//  Created by Umair on 13/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Simple demo tab without SwiftData
            Text("Demo")
                .tabItem {
                    Label("Demo", systemImage: "list.bullet")
                }
            
            // New Shopping List Package
            Text("Shopping List")
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }
        }
    }
}

#Preview {
    ContentView()
}
