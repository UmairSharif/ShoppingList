//
//  ContentView.swift
//  ShoppingList
//
//  Created by Umair on 11/08/2025.
//

import SwiftUI
import ShoppingListSDK

struct ContentView: View {
    var body: some View {
        TabView {
            // Simple demo tab without SwiftData
            Text("Demo")
                .tabItem {
                    Label("Demo", systemImage: "list.bullet")
                }
            
            // New Shopping List Package
            ShoppingListPackageView()
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }
        }
    }
}

struct ShoppingListPackageView: View {
    @State private var shoppingListView: ShoppingListView?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Group {
            if let shoppingListView = shoppingListView {
                shoppingListView
            } else {
                LoadingView()
            }
        }
        .onAppear {
            loadShoppingListPackage()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadShoppingListPackage() {
        do {
            // Let the package create its own ModelContainer with the correct schema
            let view = try ShoppingList.createView(
                config: .default
            )
            
            self.shoppingListView = view
        } catch {
            alertMessage = "Failed to load ShoppingList package: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct LoadingView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading Shopping List...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Shopping List")
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
