import Foundation

public protocol ShoppingListRepository {
    var delegate: ShoppingListRepositoryDelegate? { get set }
    
    func getAllItems() async throws -> [ShoppingItem]
    func getItem(by id: UUID) async throws -> ShoppingItem?
    func addItem(_ item: ShoppingItem) async throws -> ShoppingItem
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem
    func deleteItem(by id: UUID) async throws
    func searchItems(query: String) async throws -> [ShoppingItem]
    func getItemsWithSyncStatus(_ status: SyncStatus) async throws -> [ShoppingItem]
    
    func syncWithRemote() async throws
    func startBackgroundSync()
    func stopBackgroundSync()
}

public protocol ShoppingListRepositoryDelegate: AnyObject {
    func repository(_ repository: ShoppingListRepository, didUpdateItems items: [ShoppingItem])
    func repository(_ repository: ShoppingListRepository, didEncounterError error: ShoppingListError)
    func repository(_ repository: ShoppingListRepository, didChangeSyncStatus status: Bool)
}