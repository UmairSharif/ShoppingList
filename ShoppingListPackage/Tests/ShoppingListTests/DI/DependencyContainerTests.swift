import Testing
import SwiftData
@testable import ShoppingList

@MainActor
struct DependencyContainerTests {
    @Test("Factory creates view and optionally starts background sync")
    func testFactoryCreateView() async throws {
        let schema = Schema([ShoppingItemModel.self])
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])

        let view = try ShoppingListFactory.createShoppingListView(config: .init(enableBackgroundSync: false), modelContainer: container)
        _ = view // ensure type compiles

        let view2 = try ShoppingList.createView(config: .init(enableBackgroundSync: false), modelContainer: container)
        _ = view2
    }

    @Test("Create dependency container")
    func testCreateDependencyContainer() async throws {
        let schema = Schema([ShoppingItemModel.self])
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        let di = try ShoppingListFactory.createDependencyContainer(config: .default, modelContainer: container)
        _ = di.makeShoppingListUseCases()
        _ = di.makeShoppingListRepository()
        _ = di
    }
}

