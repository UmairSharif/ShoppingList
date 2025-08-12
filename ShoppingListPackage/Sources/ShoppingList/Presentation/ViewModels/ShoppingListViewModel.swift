import Foundation
import SwiftUI

@MainActor
public class ShoppingListViewModel: ObservableObject {
    @Published public var items: [ShoppingItem] = []
    @Published public var filteredItems: [ShoppingItem] = []
    @Published public var filter = ShoppingListFilter.default
    @Published public var isLoading = false
    @Published public var isSyncing = false
    @Published public var errorMessage: String?
    @Published public var showingAddSheet = false
    @Published public var showingEditSheet = false
    @Published public var editingItem: ShoppingItem?
    
    private let useCases: ShoppingListUseCases
    private var repository: ShoppingListRepository
    
    public init(useCases: ShoppingListUseCases, repository: ShoppingListRepository) {
        self.useCases = useCases
        self.repository = repository
        self.repository.delegate = self
        
        Task {
            await loadItems()
        }
    }
    
    public func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await useCases.getAllItems()
            await applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func applyFilter() async {
        do {
            filteredItems = try await useCases.getFilteredItems(filter)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func addItem(name: String, quantity: Int = 1, note: String = "") async {
        do {
            let newItem = try await useCases.addItem(name: name, quantity: quantity, note: note)
            items.append(newItem)
            await applyFilter()
            showingAddSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func updateItem(_ item: ShoppingItem) async {
        do {
            let updatedItem = try await useCases.updateItem(item)
            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[index] = updatedItem
            }
            await applyFilter()
            showingEditSheet = false
            editingItem = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func toggleItemBought(_ item: ShoppingItem) async {
        do {
            let updatedItem = try await useCases.toggleItemBought(item)
            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[index] = updatedItem
            }
            await applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func deleteItem(_ item: ShoppingItem) async {
        do {
            try await useCases.deleteItem(by: item.id)
            items.removeAll { $0.id == item.id }
            await applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func syncItems() async {
        do {
            try await useCases.syncItems()
            await loadItems()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func searchItems(query: String) async {
        filter.searchText = query
        await applyFilter()
    }
    
    public func updateFilter(_ newFilter: ShoppingListFilter) async {
        filter = newFilter
        await applyFilter()
    }
    
    public func showAddSheet() {
        showingAddSheet = true
    }
    
    public func showEditSheet(for item: ShoppingItem) {
        editingItem = item
        showingEditSheet = true
    }
    
    public func dismissError() {
        errorMessage = nil
    }
}

extension ShoppingListViewModel: ShoppingListRepositoryDelegate {
    public func repository(_ repository: ShoppingListRepository, didUpdateItems items: [ShoppingItem]) {
        Task { @MainActor in
            self.items = items
            await applyFilter()
        }
    }
    
    public func repository(_ repository: ShoppingListRepository, didEncounterError error: ShoppingListError) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
        }
    }
    
    public func repository(_ repository: ShoppingListRepository, didChangeSyncStatus status: Bool) {
        Task { @MainActor in
            isSyncing = status
        }
    }
}
