import Testing
import Foundation
@testable import ShoppingList

@MainActor
struct ShoppingListViewModelTests {
    
    @Test("ViewModel initialization")
    func testViewModelInitialization() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.filteredItems.isEmpty)
        #expect(viewModel.filter.showBought == true)
        #expect(viewModel.filter.showNotBought == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSyncing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showingAddSheet == false)
        #expect(viewModel.showingEditSheet == false)
        #expect(viewModel.editingItem == nil)
    }
    
    @Test("Load items successfully")
    func testLoadItemsSuccess() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let items = [ShoppingItem(name: "Test Item")]
        mockUseCases.allItems = items
        mockUseCases.filteredItems = items
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        await viewModel.loadItems()
        
        #expect(viewModel.items.count == 1)
        #expect(viewModel.filteredItems.count == 1)
        #expect(viewModel.items.first?.name == "Test Item")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Load items with error")
    func testLoadItemsError() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        mockUseCases.shouldThrowError = true
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        await viewModel.loadItems()
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Add item successfully")
    func testAddItemSuccess() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let newItem = ShoppingItem(name: "New Item", quantity: 2, note: "Test note")
        mockUseCases.newItem = newItem
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        await viewModel.addItem(name: "New Item", quantity: 2, note: "Test note")
        
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "New Item")
        #expect(viewModel.showingAddSheet == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Add item with error")
    func testAddItemError() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        mockUseCases.shouldThrowError = true
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        await viewModel.addItem(name: "", quantity: 1, note: "")
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Update item successfully")
    func testUpdateItemSuccess() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        
        let originalItem = ShoppingItem(name: "Original Item")
        var updatedItem = originalItem
        updatedItem.updateContent(name: "Updated Item")
        
        mockUseCases.updatedItem = updatedItem
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        viewModel.items = [originalItem]
        viewModel.editingItem = originalItem
        viewModel.showingEditSheet = true
        
        await viewModel.updateItem(updatedItem)
        
        #expect(viewModel.items.first?.name == "Updated Item")
        #expect(viewModel.showingEditSheet == false)
        #expect(viewModel.editingItem == nil)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Toggle item bought status")
    func testToggleItemBought() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        
        let item = ShoppingItem(name: "Test Item", isBought: false)
        var toggledItem = item
        toggledItem.markAsBought(true)
        
        mockUseCases.toggledItem = toggledItem
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        viewModel.items = [item]
        
        await viewModel.toggleItemBought(item)
        
        #expect(viewModel.items.first?.isBought == true)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Delete item successfully")
    func testDeleteItemSuccess() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        
        let item = ShoppingItem(name: "Test Item")
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        viewModel.items = [item]
        
        await viewModel.deleteItem(item)
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(mockUseCases.deletedItemIds.contains(item.id))
    }
    
    @Test("Search items")
    func testSearchItems() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        mockUseCases.filteredItems = [ShoppingItem(name: "Apple")]
        
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        await viewModel.searchItems(query: "apple")
        
        #expect(viewModel.filter.searchText == "apple")
        #expect(viewModel.filteredItems.count == 1)
        #expect(viewModel.filteredItems.first?.name == "Apple")
    }
    
    @Test("Show add sheet")
    func testShowAddSheet() {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        viewModel.showAddSheet()
        
        #expect(viewModel.showingAddSheet == true)
    }
    
    @Test("Show edit sheet")
    func testShowEditSheet() {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        let item = ShoppingItem(name: "Test Item")
        viewModel.showEditSheet(for: item)
        
        #expect(viewModel.showingEditSheet == true)
        #expect(viewModel.editingItem?.id == item.id)
    }
    
    @Test("Dismiss error")
    func testDismissError() {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        viewModel.errorMessage = "Test error"
        viewModel.dismissError()
        
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Repository delegate methods")
    func testRepositoryDelegateMethods() async {
        let mockRepository = MockShoppingListRepository()
        let mockUseCases = MockShoppingListUseCases()
        let viewModel = ShoppingListViewModel(useCases: mockUseCases, repository: mockRepository)
        
        let items = [ShoppingItem(name: "Test Item")]
        
        // Test didUpdateItems
        viewModel.repository(mockRepository, didUpdateItems: items)
        
        await Task.yield() // Allow async task to complete
        
        #expect(viewModel.items.count == 1)
        
        // Test didEncounterError
        let error = ShoppingListError.networkError("Test error")
        viewModel.repository(mockRepository, didEncounterError: error)
        
        #expect(viewModel.errorMessage != nil)
        
        // Test didChangeSyncStatus
        viewModel.repository(mockRepository, didChangeSyncStatus: true)
        
        #expect(viewModel.isSyncing == true)
        
        viewModel.repository(mockRepository, didChangeSyncStatus: false)
        
        #expect(viewModel.isSyncing == false)
    }
}