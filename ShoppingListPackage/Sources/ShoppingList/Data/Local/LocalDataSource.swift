import Foundation
import SwiftData

public protocol LocalDataSource {
    func getAllItems() async throws -> [ShoppingItem]
    func getItem(by id: UUID) async throws -> ShoppingItem?
    func insertItem(_ item: ShoppingItem) async throws
    func updateItem(_ item: ShoppingItem) async throws
    func deleteItem(by id: UUID) async throws
    func searchItems(query: String) async throws -> [ShoppingItem]
    func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem]
}

@ModelActor
public actor SwiftDataLocalDataSource: LocalDataSource {
    public func getAllItems() async throws -> [ShoppingItem] {
        let descriptor = FetchDescriptor<ShoppingItemModel>()
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomainModel() }
    }
    
    public func getItem(by id: UUID) async throws -> ShoppingItem? {
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomainModel()
    }
    
    public func insertItem(_ item: ShoppingItem) async throws {
        let model = ShoppingItemModel.fromDomainModel(item)
        modelContext.insert(model)
        try modelContext.save()
    }
    
    public func updateItem(_ item: ShoppingItem) async throws {
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.id == item.id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existingModel = try modelContext.fetch(descriptor).first {
            existingModel.updateFromDomainModel(item)
            try modelContext.save()
        } else {
            throw ShoppingListError.itemNotFound(item.id)
        }
    }
    
    public func deleteItem(by id: UUID) async throws {
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        } else {
            throw ShoppingListError.itemNotFound(id)
        }
    }
    
    public func searchItems(query: String) async throws -> [ShoppingItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.name.localizedStandardContains(trimmedQuery) ||
            model.note.localizedStandardContains(trimmedQuery)
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomainModel() }
    }
    
    public func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem] {
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.syncStatus == status.rawValue
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomainModel() }
    }
}