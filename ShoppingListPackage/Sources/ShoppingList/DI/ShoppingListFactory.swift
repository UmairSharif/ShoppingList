import Foundation
import SwiftData
import SwiftUI

public class ShoppingListFactory {
    @MainActor
    public static func createShoppingListView(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> ShoppingListView {
        let container = try createModelContainer(modelContainer)
        let dependencyContainer = DefaultDependencyContainer(config: config, modelContainer: container)
        let viewModel = dependencyContainer.makeShoppingListViewModel()
        
        if config.enableBackgroundSync {
            dependencyContainer.makeShoppingListRepository().startBackgroundSync()
        }
        
        return ShoppingListView(viewModel: viewModel)
    }
    
#if canImport(UIKit)
    @MainActor
    public static func createShoppingListViewController(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> ShoppingListViewController {
        let container = try createModelContainer(modelContainer)
        let dependencyContainer = DefaultDependencyContainer(config: config, modelContainer: container)
        let viewController = dependencyContainer.makeShoppingListViewController()
        
        if config.enableBackgroundSync {
            dependencyContainer.makeShoppingListRepository().startBackgroundSync()
        }
        
        return viewController
    }
#endif
    
    public static func createDependencyContainer(
        config: ShoppingListConfig = .default,
        modelContainer: ModelContainer? = nil
    ) throws -> DependencyContainer {
        let container = try createModelContainer(modelContainer)
        return DefaultDependencyContainer(config: config, modelContainer: container)
    }
    
    private static func createModelContainer(_ modelContainer: ModelContainer?) throws -> ModelContainer {
        if let container = modelContainer {
            return container
        }
        
        let schema = Schema([ShoppingItemModel.self])
        // Use a dedicated SQLite file to avoid colliding with the host app's default.store
        let supportDir: URL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let storeURL = supportDir.appendingPathComponent("shoppinglist.store")
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            throw ShoppingListError.persistenceError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }
}