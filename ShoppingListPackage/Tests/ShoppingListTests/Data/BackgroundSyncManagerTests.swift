import Testing
import Foundation
@testable import ShoppingList

@MainActor
struct BackgroundSyncManagerTests {
    final class RemoteStub: RemoteDataSource {
        var updated: [ShoppingItem] = []
        func getAllItems() async throws -> [ShoppingItem] { return [] }
        func createItem(_ item: ShoppingItem) async throws -> ShoppingItem { return item }
        func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem { updated.append(item); return item }
        func deleteItem(by id: UUID) async throws { }
    }

    @Test("performSync transitions item statuses and updates local")
    func testPerformSync() async throws {
        let local = MockLocalDataSource()
        let remote = RemoteStub()
        let manager = BackgroundSyncManager(remoteDataSource: remote, localDataSource: local, syncInterval: 9999)

        var a = ShoppingItem(name: "A"); a.syncStatus = .notSynced
        var b = ShoppingItem(name: "B"); b.syncStatus = .failed
        local.items = [a, b]

        await manager.performSync()

        // After sync, items should be marked synced in local
        let synced = try await local.getAllItems()
        #expect(synced.allSatisfy { $0.syncStatus == .synced })
    }
}

