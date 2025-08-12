import Foundation

public struct ShoppingListConfig {
    public let apiBaseURL: String
    public let syncInterval: TimeInterval
    public let enableBackgroundSync: Bool
    public let maxRetryAttempts: Int
    public let baseRetryDelay: TimeInterval
    
    public init(
        apiBaseURL: String = "https://api.example.com/shopping",
        syncInterval: TimeInterval = 300,
        enableBackgroundSync: Bool = true,
        maxRetryAttempts: Int = 3,
        baseRetryDelay: TimeInterval = 2.0
    ) {
        self.apiBaseURL = apiBaseURL
        self.syncInterval = syncInterval
        self.enableBackgroundSync = enableBackgroundSync
        self.maxRetryAttempts = maxRetryAttempts
        self.baseRetryDelay = baseRetryDelay
    }
    
    public static let `default` = ShoppingListConfig()
}