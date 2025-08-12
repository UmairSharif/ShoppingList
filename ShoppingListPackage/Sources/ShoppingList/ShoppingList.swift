import Foundation
import SwiftData
import SwiftUI

@_exported import struct Foundation.UUID
@_exported import struct Foundation.Date

public struct ShoppingList {
    @MainActor
    public static func createView(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> ShoppingListView {
        return try ShoppingListFactory.createShoppingListView(
            config: config,
            modelContainer: modelContainer
        )
    }
    
#if canImport(UIKit)
    @MainActor
    public static func createViewController(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> ShoppingListViewController {
        return try ShoppingListFactory.createShoppingListViewController(
            config: config,
            modelContainer: modelContainer
        )
    }
#endif
    
    public static func createDependencyContainer(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> DependencyContainer {
        return try ShoppingListFactory.createDependencyContainer(
            config: config,
            modelContainer: modelContainer
        )
    }
}