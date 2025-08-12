import Foundation
#if canImport(BackgroundTasks) && os(iOS)
import BackgroundTasks
#endif

public class BackgroundSyncManager {
    private let taskIdentifier = "com.shoppinglist.background-sync"
    private let remoteDataSource: RemoteDataSource
    private let localDataSource: LocalDataSource
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval
    private let maxRetryAttempts = 3
    private let baseRetryDelay: TimeInterval = 2.0
    
    public init(
        remoteDataSource: RemoteDataSource,
        localDataSource: LocalDataSource,
        syncInterval: TimeInterval = 300
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncInterval = syncInterval
    }
    
    public func startBackgroundSync() {
        registerBackgroundTask()
        startPeriodicSync()
    }
    
    public func stopBackgroundSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    private func registerBackgroundTask() {
#if canImport(BackgroundTasks) && os(iOS)
        // Only try to submit if we're not in a testing environment
        guard !ProcessInfo.processInfo.environment.keys.contains("XCTestConfigurationFilePath") else {
            return
        }
        
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            let nsError = error as NSError
            switch nsError.code {
            case 3:
                // Background task unavailable, continue without background sync
                break
            case 2:
                // Too many pending requests, skip this one
                break
            case 1:
                // Not permitted, possibly due to Low Power Mode
                break
            default:
                print("Background task submission failed: \(error)")
            }
        }
#endif
    }
    
    private func startPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.performSync()
            }
        }
    }
    
    public func performSync() async {
        await performSyncWithRetry()
    }
    
    private func performSyncWithRetry(attempt: Int = 0) async {
        do {
            try await syncUnsyncedItems()
        } catch {
            if attempt < maxRetryAttempts {
                let delay = baseRetryDelay * pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await performSyncWithRetry(attempt: attempt + 1)
            } else {
                await markFailedItems()
            }
        }
    }
    
    private func syncUnsyncedItems() async throws {
        let unsyncedItems = try await localDataSource.getItemsWithSyncStatus(.notSynced)
        
        for var item in unsyncedItems {
            do {
                item.syncStatus = .syncing
                try await localDataSource.updateItem(item)
                
                let syncedItem = try await remoteDataSource.updateItem(item)
                var finalItem = syncedItem
                finalItem.syncStatus = .synced
                try await localDataSource.updateItem(finalItem)
                
            } catch {
                item.syncStatus = .failed
                try await localDataSource.updateItem(item)
                throw error
            }
        }
        
        let failedItems = try await localDataSource.getItemsWithSyncStatus(.failed)
        
        for var item in failedItems {
            do {
                item.syncStatus = .syncing
                try await localDataSource.updateItem(item)
                
                let syncedItem = try await remoteDataSource.updateItem(item)
                var finalItem = syncedItem
                finalItem.syncStatus = .synced
                try await localDataSource.updateItem(finalItem)
                
            } catch {
                item.syncStatus = .failed
                try await localDataSource.updateItem(item)
                throw error
            }
        }
    }
    
    private func markFailedItems() async {
        do {
            let syncingItems = try await localDataSource.getItemsWithSyncStatus(.syncing)
            for var item in syncingItems {
                item.syncStatus = .failed
                try await localDataSource.updateItem(item)
            }
        } catch {
            print("Failed to mark items as failed: \(error)")
        }
    }
}
