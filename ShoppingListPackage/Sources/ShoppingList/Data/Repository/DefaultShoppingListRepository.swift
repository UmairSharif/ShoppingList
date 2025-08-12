import Foundation

public class DefaultShoppingListRepository: ShoppingListRepository {
    private let localDataSource: LocalDataSource
    private let remoteDataSource: RemoteDataSource
    private let backgroundSyncManager: BackgroundSyncManager
    public weak var delegate: ShoppingListRepositoryDelegate?
    
    public init(
        localDataSource: LocalDataSource,
        remoteDataSource: RemoteDataSource,
        backgroundSyncManager: BackgroundSyncManager
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.backgroundSyncManager = backgroundSyncManager
    }
    
    public func getAllItems() async throws -> [ShoppingItem] {
        do {
            let items = try await localDataSource.getAllItems()
            delegate?.repository(self, didUpdateItems: items)
            return items
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func getItem(by id: UUID) async throws -> ShoppingItem? {
        do {
            return try await localDataSource.getItem(by: id)
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func addItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        do {
            var newItem = item
            newItem.syncStatus = .notSynced
            
            try await localDataSource.insertItem(newItem)
            
            Task {
                await tryBackgroundSync()
            }
            
            return newItem
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        do {
            var updatedItem = item
            updatedItem.syncStatus = .notSynced
            
            try await localDataSource.updateItem(updatedItem)
            
            Task {
                await tryBackgroundSync()
            }
            
            return updatedItem
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func deleteItem(by id: UUID) async throws {
        do {
            try await localDataSource.deleteItem(by: id)
            
            Task {
                do {
                    try await remoteDataSource.deleteItem(by: id)
                } catch {
                    print("Failed to delete item from remote: \(error)")
                }
            }
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func searchItems(query: String) async throws -> [ShoppingItem] {
        do {
            return try await localDataSource.searchItems(query: query)
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem] {
        do {
            return try await localDataSource.getItemsWithSyncStatus(status)
        } catch {
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.persistenceError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func syncWithRemote() async throws {
        delegate?.repository(self, didChangeSyncStatus: true)
        
        do {
            await backgroundSyncManager.performSync()
            delegate?.repository(self, didChangeSyncStatus: false)
        } catch {
            delegate?.repository(self, didChangeSyncStatus: false)
            let shoppingError = error as? ShoppingListError ?? ShoppingListError.syncError(error.localizedDescription)
            delegate?.repository(self, didEncounterError: shoppingError)
            throw shoppingError
        }
    }
    
    public func startBackgroundSync() {
        backgroundSyncManager.startBackgroundSync()
    }
    
    public func stopBackgroundSync() {
        backgroundSyncManager.stopBackgroundSync()
    }
    
    private func tryBackgroundSync() async {
        do {
            await backgroundSyncManager.performSync()
        } catch {
            print("Background sync failed: \(error)")
        }
    }
}