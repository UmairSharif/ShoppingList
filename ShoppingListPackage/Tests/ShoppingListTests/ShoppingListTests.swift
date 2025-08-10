import Testing
@testable import ShoppingList

struct ShoppingListTests {
    @Test
    func info_hasDefaultVersion() {
        let info = ShoppingListAPI.makeInfo()
        #expect(info.version == "0.1.0")
    }
}


