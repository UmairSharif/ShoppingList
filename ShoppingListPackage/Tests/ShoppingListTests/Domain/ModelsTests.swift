import Testing
@testable import ShoppingList

struct ModelsTests {
    @Test("ShoppingListError descriptions and recovery suggestions")
    func testErrorDescriptions() {
        let errors: [ShoppingListError] = [
            .networkError("x"), .syncError("x"), .persistenceError("x"), .validationError("x"), .itemNotFound(UUID()), .backgroundTaskFailed("x")
        ]
        for e in errors { #expect(e.errorDescription != nil); #expect(e.recoverySuggestion != nil) }
    }

    @Test("ShoppingListFilter defaults and SortOrder displayName")
    func testFilterAndSortOrder() {
        let filter = ShoppingListFilter.default
        #expect(filter.showBought && filter.showNotBought)
        for order in SortOrder.allCases { _ = order.displayName }
    }
}

