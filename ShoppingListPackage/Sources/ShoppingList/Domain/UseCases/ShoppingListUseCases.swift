import Foundation

public protocol ShoppingListUseCases {
    func getAllItems() async throws -> [ShoppingItem]
    func getFilteredItems(_ filter: ShoppingListFilter) async throws -> [ShoppingItem]
    func addItem(name: String, quantity: Int, note: String) async throws -> ShoppingItem
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem
    func toggleItemBought(_ item: ShoppingItem) async throws -> ShoppingItem
    func deleteItem(by id: UUID) async throws
    func syncItems() async throws
    func searchItems(query: String) async throws -> [ShoppingItem]
}

public class DefaultShoppingListUseCases: ShoppingListUseCases {
    private let repository: ShoppingListRepository
    
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    public func getAllItems() async throws -> [ShoppingItem] {
        return try await repository.getAllItems()
    }
    
    public func getFilteredItems(_ filter: ShoppingListFilter) async throws -> [ShoppingItem] {
        var items = try await repository.getAllItems()
        
        items = items.filter { item in
            let matchesBoughtFilter = (filter.showBought && item.isBought) || (filter.showNotBought && !item.isBought)
            let matchesSearch = filter.searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(filter.searchText) ||
                item.note.localizedCaseInsensitiveContains(filter.searchText)
            
            return matchesBoughtFilter && matchesSearch
        }
        
        items = sortItems(items, by: filter.sortOrder)
        
        return items
    }
    
    public func addItem(name: String, quantity: Int = 1, note: String = "") async throws -> ShoppingItem {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ShoppingListError.validationError("Item name cannot be empty")
        }
        
        guard quantity > 0 else {
            throw ShoppingListError.validationError("Quantity must be greater than 0")
        }
        
        let item = ShoppingItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        return try await repository.addItem(item)
    }
    
    public func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        guard !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ShoppingListError.validationError("Item name cannot be empty")
        }
        
        guard item.quantity > 0 else {
            throw ShoppingListError.validationError("Quantity must be greater than 0")
        }
        
        return try await repository.updateItem(item)
    }
    
    public func toggleItemBought(_ item: ShoppingItem) async throws -> ShoppingItem {
        var updatedItem = item
        updatedItem.markAsBought(!item.isBought)
        return try await repository.updateItem(updatedItem)
    }
    
    public func deleteItem(by id: UUID) async throws {
        try await repository.deleteItem(by: id)
    }
    
    public func syncItems() async throws {
        try await repository.syncWithRemote()
    }
    
    public func searchItems(query: String) async throws -> [ShoppingItem] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return try await getAllItems()
        }
        
        return try await repository.searchItems(query: query)
    }
    
    private func sortItems(_ items: [ShoppingItem], by sortOrder: SortOrder) -> [ShoppingItem] {
        switch sortOrder {
        case .createdDateAscending:
            return items.sorted { $0.createdAt < $1.createdAt }
        case .createdDateDescending:
            return items.sorted { $0.createdAt > $1.createdAt }
        case .modifiedDateAscending:
            return items.sorted { $0.modifiedAt < $1.modifiedAt }
        case .modifiedDateDescending:
            return items.sorted { $0.modifiedAt > $1.modifiedAt }
        case .nameAscending:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
}