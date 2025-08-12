import Testing
import Foundation
@testable import ShoppingList

@MainActor
struct ShoppingListUseCasesTests {
    
    @Test("Add valid item")
    func testAddValidItem() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item = try await useCases.addItem(name: "Test Item", quantity: 2, note: "Test note")
        
        #expect(item.name == "Test Item")
        #expect(item.quantity == 2)
        #expect(item.note == "Test note")
        #expect(item.syncStatus == .notSynced)
        #expect(mockRepository.addedItems.count == 1)
        #expect(mockRepository.addedItems.first?.name == "Test Item")
    }
    
    @Test("Add item with empty name throws validation error")
    func testAddItemWithEmptyName() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        await #expect(throws: ShoppingListError.self) {
            try await useCases.addItem(name: "", quantity: 1, note: "")
        }
        
        await #expect(throws: ShoppingListError.self) {
            try await useCases.addItem(name: "   ", quantity: 1, note: "")
        }
    }
    
    @Test("Add item with invalid quantity throws validation error")
    func testAddItemWithInvalidQuantity() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        await #expect(throws: ShoppingListError.self) {
            try await useCases.addItem(name: "Test", quantity: 0, note: "")
        }
        
        await #expect(throws: ShoppingListError.self) {
            try await useCases.addItem(name: "Test", quantity: -1, note: "")
        }
    }
    
    @Test("Update valid item")
    func testUpdateValidItem() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let originalItem = ShoppingItem(name: "Original", quantity: 1)
        mockRepository.items = [originalItem]
        
        var updatedItem = originalItem
        updatedItem.updateContent(name: "Updated", quantity: 3)
        
        let result = try await useCases.updateItem(updatedItem)
        
        #expect(result.name == "Updated")
        #expect(result.quantity == 3)
        #expect(mockRepository.updatedItems.count == 1)
    }
    
    @Test("Update item with empty name throws validation error")
    func testUpdateItemWithEmptyName() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        var item = ShoppingItem(name: "Original")
        item.updateContent(name: "")
        
        await #expect(throws: ShoppingListError.self) {
            try await useCases.updateItem(item)
        }
    }
    
    @Test("Toggle item bought status")
    func testToggleItemBought() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item = ShoppingItem(name: "Test Item", isBought: false)
        mockRepository.items = [item]
        
        let toggledItem = try await useCases.toggleItemBought(item)
        
        #expect(toggledItem.isBought == true)
        #expect(toggledItem.syncStatus == .notSynced)
        #expect(mockRepository.updatedItems.count == 1)
    }
    
    @Test("Get filtered items - show all")
    func testGetFilteredItemsShowAll() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Item 1", isBought: false)
        let item2 = ShoppingItem(name: "Item 2", isBought: true)
        mockRepository.items = [item1, item2]
        
        let filter = ShoppingListFilter(showBought: true, showNotBought: true)
        let results = try await useCases.getFilteredItems(filter)
        
        #expect(results.count == 2)
    }
    
    @Test("Get filtered items - show only bought")
    func testGetFilteredItemsShowOnlyBought() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Item 1", isBought: false)
        let item2 = ShoppingItem(name: "Item 2", isBought: true)
        mockRepository.items = [item1, item2]
        
        let filter = ShoppingListFilter(showBought: true, showNotBought: false)
        let results = try await useCases.getFilteredItems(filter)
        
        #expect(results.count == 1)
        #expect(results.first?.isBought == true)
    }
    
    @Test("Get filtered items - search by name")
    func testGetFilteredItemsSearchByName() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Apple", note: "Red")
        let item2 = ShoppingItem(name: "Banana", note: "Yellow")
        mockRepository.items = [item1, item2]
        
        let filter = ShoppingListFilter(searchText: "apple")
        let results = try await useCases.getFilteredItems(filter)
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Apple")
    }
    
    @Test("Get filtered items - search by note")
    func testGetFilteredItemsSearchByNote() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Apple", note: "Red fruit")
        let item2 = ShoppingItem(name: "Banana", note: "Yellow fruit")
        mockRepository.items = [item1, item2]
        
        let filter = ShoppingListFilter(searchText: "yellow")
        let results = try await useCases.getFilteredItems(filter)
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Banana")
    }
    
    @Test("Get filtered items - sort by name ascending")
    func testGetFilteredItemsSortByNameAsc() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Zebra")
        let item2 = ShoppingItem(name: "Apple")
        mockRepository.items = [item1, item2]
        
        let filter = ShoppingListFilter(sortOrder: .nameAscending)
        let results = try await useCases.getFilteredItems(filter)
        
        #expect(results.count == 2)
        #expect(results.first?.name == "Apple")
        #expect(results.last?.name == "Zebra")
    }
    
    @Test("Delete item")
    func testDeleteItem() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item = ShoppingItem(name: "Test Item")
        
        try await useCases.deleteItem(by: item.id)
        
        #expect(mockRepository.deletedItemIds.contains(item.id))
    }
    
    @Test("Search items with query")
    func testSearchItems() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let results = try await useCases.searchItems(query: "test query")
        
        #expect(mockRepository.searchQueries.contains("test query"))
    }
    
    @Test("Search items with empty query returns all items")
    func testSearchItemsEmptyQuery() async throws {
        let mockRepository = MockShoppingListRepository()
        let useCases = DefaultShoppingListUseCases(repository: mockRepository)
        
        let item1 = ShoppingItem(name: "Item 1")
        let item2 = ShoppingItem(name: "Item 2")
        mockRepository.items = [item1, item2]
        
        let results = try await useCases.searchItems(query: "")
        
        #expect(results.count == 2)
        #expect(mockRepository.getAllItemsCalled == true)
    }
}