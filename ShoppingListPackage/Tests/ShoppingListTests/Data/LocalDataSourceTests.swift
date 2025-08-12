import Testing
import Foundation
@testable import ShoppingList

@MainActor
struct LocalDataSourceTests {

    @Test("Insert, fetch, update, delete flow")
    func testCRUD() async throws {
        let ds = MockLocalDataSource()
        let item = ShoppingItem(name: "Milk", quantity: 2, note: "2%")

        // Insert
        try await ds.insertItem(item)
        #expect(ds.insertedItems.count == 1)

        // Get all
        let all = try await ds.getAllItems()
        #expect(all.count == 1)
        #expect(all.first?.id == item.id)

        // Get by id
        let fetched = try await ds.getItem(by: item.id)
        #expect(fetched?.name == "Milk")

        // Update
        var updated = item
        updated.updateContent(name: "Skim Milk", quantity: 1, note: "")
        try await ds.updateItem(updated)
        #expect(ds.updatedItems.contains(where: { $0.id == item.id }))

        // Search
        let results = try await ds.searchItems(query: "skim")
        #expect(results.count == 1)

        // Delete
        try await ds.deleteItem(by: item.id)
        #expect(ds.deletedItemIds.contains(item.id))
        #expect((try await ds.getAllItems()).isEmpty)
    }

    @Test("Get items with sync status")
    func testGetBySyncStatus() async throws {
        let ds = MockLocalDataSource()
        var a = ShoppingItem(name: "A"); a.syncStatus = .notSynced
        var b = ShoppingItem(name: "B"); b.syncStatus = .synced
        var c = ShoppingItem(name: "C"); c.syncStatus = .failed
        ds.items = [a,b,c]

        let failed = try await ds.getItemsWithSyncStatus(.failed)
        #expect(failed.count == 1)
        #expect(ds.requestedStatuses.contains(.failed))
    }

    @Test("Update/delete not found errors")
    func testNotFound() async {
        let ds = MockLocalDataSource()
        ds.shouldThrowNotFoundOnUpdate = true
        ds.shouldThrowNotFoundOnDelete = true
        let id = UUID()
        let item = ShoppingItem(id: id, name: "X")

        await #expect(throws: ShoppingListError.self) {
            try await ds.updateItem(item)
        }
        await #expect(throws: ShoppingListError.self) {
            try await ds.deleteItem(by: id)
        }
    }
}

