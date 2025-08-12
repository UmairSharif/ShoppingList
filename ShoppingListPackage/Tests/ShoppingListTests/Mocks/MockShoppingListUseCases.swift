import Foundation
@testable import ShoppingList

@MainActor
class MockShoppingListUseCases: ShoppingListUseCases {
    var allItems: [ShoppingItem] = []
    var filteredItems: [ShoppingItem] = []
    var newItem: ShoppingItem?
    var updatedItem: ShoppingItem?
    var toggledItem: ShoppingItem?
    var deletedItemIds: [UUID] = []
    var searchResults: [ShoppingItem] = []
    var shouldThrowError = false
    var syncCalled = false
    
    func getAllItems() async throws -> [ShoppingItem] {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        return allItems
    }
    
    func getFilteredItems(_ filter: ShoppingListFilter) async throws -> [ShoppingItem] {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        return filteredItems
    }
    
    func addItem(name: String, quantity: Int, note: String) async throws -> ShoppingItem {
        if shouldThrowError {
            throw ShoppingListError.validationError("Mock validation error")
        }
        
        guard let item = newItem else {
            let item = ShoppingItem(name: name, quantity: quantity, note: note)
            return item
        }
        
        return item
    }
    
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        if shouldThrowError {
            throw ShoppingListError.validationError("Mock validation error")
        }
        
        return updatedItem ?? item
    }
    
    func toggleItemBought(_ item: ShoppingItem) async throws -> ShoppingItem {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        
        return toggledItem ?? item
    }
    
    func deleteItem(by id: UUID) async throws {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        
        deletedItemIds.append(id)
    }
    
    func syncItems() async throws {
        if shouldThrowError {
            throw ShoppingListError.syncError("Mock sync error")
        }
        
        syncCalled = true
    }
    
    func searchItems(query: String) async throws -> [ShoppingItem] {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        
        return searchResults
    }
    
    func reset() {
        allItems.removeAll()
        filteredItems.removeAll()
        newItem = nil
        updatedItem = nil
        toggledItem = nil
        deletedItemIds.removeAll()
        searchResults.removeAll()
        shouldThrowError = false
        syncCalled = false
    }
}