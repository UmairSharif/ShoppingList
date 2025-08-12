import Testing
import Foundation
@testable import ShoppingList

@MainActor
struct DefaultShoppingListRepositoryTests {
    final class DelegateSpy: ShoppingListRepositoryDelegate {
        var updatedItems: [[ShoppingItem]] = []
        var errors: [ShoppingListError] = []
        var syncStatus: [Bool] = []
        func repository(_ repository: ShoppingListRepository, didUpdateItems items: [ShoppingItem]) { updatedItems.append(items) }
        func repository(_ repository: ShoppingListRepository, didEncounterError error: ShoppingListError) { errors.append(error) }
        func repository(_ repository: ShoppingListRepository, didChangeSyncStatus status: Bool) { syncStatus.append(status) }
    }

    final actor BackgroundSyncStub: Sendable {
        private let local: MockLocalDataSource
        private let remote: RemoteDataSource
        init(local: MockLocalDataSource, remote: RemoteDataSource) { self.local = local; self.remote = remote }
        func manager() -> BackgroundSyncManager {
            BackgroundSyncManager(remoteDataSource: remote, localDataSource: local, syncInterval: 9999)
        }
    }

    @Test("getAllItems returns local and notifies delegate")
    func testGetAllItems() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)
        let spy = DelegateSpy()
        repo.delegate = spy

        local.items = [ShoppingItem(name: "A"), ShoppingItem(name: "B")]

        let items = try await repo.getAllItems()
        #expect(items.count == 2)
        #expect(spy.updatedItems.count == 1)
    }

    @Test("addItem marks notSynced and triggers background sync")
    func testAddItem() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)

        let item = ShoppingItem(name: "New")
        let added = try await repo.addItem(item)
        #expect(added.syncStatus == .notSynced)
        #expect(local.insertedItems.contains(where: { $0.id == item.id }))
    }

    @Test("updateItem marks notSynced and updates local")
    func testUpdateItem() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)

        var item = ShoppingItem(name: "X")
        try await local.insertItem(item)
        item.updateContent(name: "Y")
        let updated = try await repo.updateItem(item)
        #expect(updated.syncStatus == .notSynced)
        #expect(local.updatedItems.contains(where: { $0.id == item.id }))
    }

    @Test("deleteItem removes local and attempts remote")
    func testDeleteItem() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)

        let item = ShoppingItem(name: "ToDelete")
        try await local.insertItem(item)
        try await repo.deleteItem(by: item.id)
        #expect(!local.items.contains(where: { $0.id == item.id }))
        #expect(local.deletedItemIds.contains(item.id))
    }

    @Test("searchItems uses local")
    func testSearchItems() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)

        local.items = [ShoppingItem(name: "Apple"), ShoppingItem(name: "Banana")]
        let res = try await repo.searchItems(query: "app")
        #expect(res.count == 1)
    }

    @Test("syncWithRemote toggles delegate sync status")
    func testSyncWithRemote() async throws {
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource(baseURL: "https://api.example.com/shopping")
        let bg = await BackgroundSyncStub(local: local, remote: remote).manager()
        let repo = DefaultShoppingListRepository(localDataSource: local, remoteDataSource: remote, backgroundSyncManager: bg)
        let spy = DelegateSpy()
        repo.delegate = spy

        try await repo.syncWithRemote()
        #expect(spy.syncStatus.first == true)
        #expect(spy.syncStatus.last == false)
    }
}

