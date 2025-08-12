import Testing
import Foundation
@testable import ShoppingList

struct ShoppingItemTests {
    
    @Test("ShoppingItem initialization with default values")
    func testDefaultInitialization() {
        let item = ShoppingItem(name: "Test Item")
        
        #expect(item.name == "Test Item")
        #expect(item.quantity == 1)
        #expect(item.note == "")
        #expect(item.isBought == false)
        #expect(item.syncStatus == .notSynced)
        #expect(!item.id.uuidString.isEmpty)
    }
    
    @Test("ShoppingItem initialization with custom values")
    func testCustomInitialization() {
        let id = UUID()
        let createdAt = Date()
        let item = ShoppingItem(
            id: id,
            name: "Custom Item",
            quantity: 5,
            note: "Custom note",
            isBought: true,
            createdAt: createdAt,
            syncStatus: .synced
        )
        
        #expect(item.id == id)
        #expect(item.name == "Custom Item")
        #expect(item.quantity == 5)
        #expect(item.note == "Custom note")
        #expect(item.isBought == true)
        #expect(item.createdAt == createdAt)
        #expect(item.syncStatus == .synced)
    }
    
    @Test("Mark item as bought")
    func testMarkAsBought() {
        var item = ShoppingItem(name: "Test Item")
        let originalModifiedAt = item.modifiedAt
        
        // Small delay to ensure modifiedAt changes
        Thread.sleep(forTimeInterval: 0.001)
        
        item.markAsBought(true)
        
        #expect(item.isBought == true)
        #expect(item.syncStatus == .notSynced)
        #expect(item.modifiedAt > originalModifiedAt)
    }
    
    @Test("Mark item as not bought")
    func testMarkAsNotBought() {
        var item = ShoppingItem(name: "Test Item", isBought: true)
        let originalModifiedAt = item.modifiedAt
        
        Thread.sleep(forTimeInterval: 0.001)
        
        item.markAsBought(false)
        
        #expect(item.isBought == false)
        #expect(item.syncStatus == .notSynced)
        #expect(item.modifiedAt > originalModifiedAt)
    }
    
    @Test("Update item content")
    func testUpdateContent() {
        var item = ShoppingItem(name: "Original", quantity: 1, note: "Original note")
        let originalModifiedAt = item.modifiedAt
        
        Thread.sleep(forTimeInterval: 0.001)
        
        item.updateContent(name: "Updated", quantity: 3, note: "Updated note")
        
        #expect(item.name == "Updated")
        #expect(item.quantity == 3)
        #expect(item.note == "Updated note")
        #expect(item.syncStatus == .notSynced)
        #expect(item.modifiedAt > originalModifiedAt)
    }
    
    @Test("Update partial content")
    func testUpdatePartialContent() {
        var item = ShoppingItem(name: "Original", quantity: 1, note: "Original note")
        let originalName = item.name
        let originalNote = item.note
        
        item.updateContent(quantity: 5)
        
        #expect(item.name == originalName)
        #expect(item.quantity == 5)
        #expect(item.note == originalNote)
        #expect(item.syncStatus == .notSynced)
    }
    
    @Test("ShoppingItem equality")
    func testEquality() {
        let id = UUID()
        let date = Date()
        
        let item1 = ShoppingItem(
            id: id,
            name: "Test",
            quantity: 1,
            note: "Note",
            isBought: false,
            createdAt: date,
            modifiedAt: date,
            syncStatus: .synced
        )
        
        let item2 = ShoppingItem(
            id: id,
            name: "Test",
            quantity: 1,
            note: "Note",
            isBought: false,
            createdAt: date,
            modifiedAt: date,
            syncStatus: .synced
        )
        
        #expect(item1 == item2)
    }
    
    @Test("ShoppingItem inequality")
    func testInequality() {
        let item1 = ShoppingItem(name: "Test1")
        let item2 = ShoppingItem(name: "Test2")
        
        #expect(item1 != item2)
    }
}