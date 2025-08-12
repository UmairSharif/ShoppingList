import Testing
import SwiftData
@testable import ShoppingList

@MainActor
struct ShoppingListFacadeTests {
    @Test("Facade createView and createDependencyContainer")
    func testFacade() async throws {
        let schema = Schema([ShoppingItemModel.self])
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        let view = try ShoppingList.createView(config: .init(enableBackgroundSync: false), modelContainer: container)
        _ = view

        let di = try ShoppingList.createDependencyContainer(config: .default, modelContainer: container)
        _ = di
    }
}

