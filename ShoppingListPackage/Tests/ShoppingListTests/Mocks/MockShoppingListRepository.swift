import Foundation
@testable import ShoppingList

@MainActor
class MockShoppingListRepository: ShoppingListRepository {
    var items: [ShoppingItem] = []
    var addedItems: [ShoppingItem] = []
    var updatedItems: [ShoppingItem] = []
    var deletedItemIds: [UUID] = []
    var searchQueries: [String] = []
    var syncStatus: [SyncStatus] = []
    var getAllItemsCalled = false
    var syncWithRemoteCalled = false
    var startBackgroundSyncCalled = false
    var stopBackgroundSyncCalled = false
    
    weak var delegate: ShoppingListRepositoryDelegate?
    
    func getAllItems() async throws -> [ShoppingItem] {
        getAllItemsCalled = true
        return items
    }
    
    func getItem(by id: UUID) async throws -> ShoppingItem? {
        return items.first { $0.id == id }
    }
    
    func addItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        addedItems.append(item)
        items.append(item)
        return item
    }
    
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        updatedItems.append(item)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
        return item
    }
    
    func deleteItem(by id: UUID) async throws {
        deletedItemIds.append(id)
        items.removeAll { $0.id == id }
    }
    
    func searchItems(query: String) async throws -> [ShoppingItem] {
        searchQueries.append(query)
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.note.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem] {
        syncStatus.append(status)
        return items.filter { $0.syncStatus == status }
    }
    
    func syncWithRemote() async throws {
        syncWithRemoteCalled = true
    }
    
    func startBackgroundSync() {
        startBackgroundSyncCalled = true
    }
    
    func stopBackgroundSync() {
        stopBackgroundSyncCalled = true
    }
    
    func reset() {
        items.removeAll()
        addedItems.removeAll()
        updatedItems.removeAll()
        deletedItemIds.removeAll()
        searchQueries.removeAll()
        syncStatus.removeAll()
        getAllItemsCalled = false
        syncWithRemoteCalled = false
        startBackgroundSyncCalled = false
        stopBackgroundSyncCalled = false
    }
}