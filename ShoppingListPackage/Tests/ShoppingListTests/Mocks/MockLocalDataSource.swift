import Foundation
@testable import ShoppingList

@MainActor
final class MockLocalDataSource: LocalDataSource {
    var items: [ShoppingItem] = []
    var insertedItems: [ShoppingItem] = []
    var updatedItems: [ShoppingItem] = []
    var deletedItemIds: [UUID] = []
    var searchQueries: [String] = []
    var requestedStatuses: [SyncStatus] = []
    var shouldThrowNotFoundOnUpdate = false
    var shouldThrowNotFoundOnDelete = false

    func getAllItems() async throws -> [ShoppingItem] {
        return items
    }

    func getItem(by id: UUID) async throws -> ShoppingItem? {
        return items.first { $0.id == id }
    }

    func insertItem(_ item: ShoppingItem) async throws {
        insertedItems.append(item)
        items.append(item)
    }

    func updateItem(_ item: ShoppingItem) async throws {
        if shouldThrowNotFoundOnUpdate && !items.contains(where: { $0.id == item.id }) {
            throw ShoppingListError.itemNotFound(item.id)
        }
        updatedItems.append(item)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func deleteItem(by id: UUID) async throws {
        if shouldThrowNotFoundOnDelete && !items.contains(where: { $0.id == id }) {
            throw ShoppingListError.itemNotFound(id)
        }
        deletedItemIds.append(id)
        items.removeAll { $0.id == id }
    }

    func searchItems(query: String) async throws -> [ShoppingItem] {
        searchQueries.append(query)
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return items }
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(trimmed) ||
            item.note.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem] {
        requestedStatuses.append(status)
        return items.filter { $0.syncStatus == status }
    }
}

