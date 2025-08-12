import Foundation
import SwiftData

@Model
public final class ShoppingItemModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var quantity: Int
    public var note: String
    public var isBought: Bool
    public var createdAt: Date
    public var modifiedAt: Date
    public var syncStatus: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        note: String = "",
        isBought: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        syncStatus: String = SyncStatus.notSynced.rawValue
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
}

extension ShoppingItemModel {
    func toDomainModel() -> ShoppingItem {
        return ShoppingItem(
            id: id,
            name: name,
            quantity: quantity,
            note: note,
            isBought: isBought,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            syncStatus: SyncStatus(rawValue: syncStatus) ?? .notSynced
        )
    }
    
    func updateFromDomainModel(_ item: ShoppingItem) {
        self.name = item.name
        self.quantity = item.quantity
        self.note = item.note
        self.isBought = item.isBought
        self.modifiedAt = item.modifiedAt
        self.syncStatus = item.syncStatus.rawValue
    }
    
    static func fromDomainModel(_ item: ShoppingItem) -> ShoppingItemModel {
        return ShoppingItemModel(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            note: item.note,
            isBought: item.isBought,
            createdAt: item.createdAt,
            modifiedAt: item.modifiedAt,
            syncStatus: item.syncStatus.rawValue
        )
    }
}