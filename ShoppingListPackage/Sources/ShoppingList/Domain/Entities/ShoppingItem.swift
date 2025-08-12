import Foundation

public struct ShoppingItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var quantity: Int
    public var note: String
    public var isBought: Bool
    public var createdAt: Date
    public var modifiedAt: Date
    public var syncStatus: SyncStatus
    
    public init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        note: String = "",
        isBought: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        syncStatus: SyncStatus = .notSynced
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.syncStatus = syncStatus
    }
    
    public mutating func markAsBought(_ bought: Bool = true) {
        isBought = bought
        modifiedAt = Date()
        syncStatus = .notSynced
    }
    
    public mutating func updateContent(name: String? = nil, quantity: Int? = nil, note: String? = nil) {
        if let name = name { self.name = name }
        if let quantity = quantity { self.quantity = quantity }
        if let note = note { self.note = note }
        modifiedAt = Date()
        syncStatus = .notSynced
    }
}

public enum SyncStatus: String, Codable, CaseIterable {
    case notSynced = "not_synced"
    case syncing = "syncing"
    case synced = "synced"
    case failed = "failed"
}