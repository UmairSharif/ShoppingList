import Foundation

public struct ShoppingListFilter {
    public var showBought: Bool
    public var showNotBought: Bool
    public var searchText: String
    public var sortOrder: SortOrder
    
    public init(
        showBought: Bool = true,
        showNotBought: Bool = true,
        searchText: String = "",
        sortOrder: SortOrder = .createdDateDescending
    ) {
        self.showBought = showBought
        self.showNotBought = showNotBought
        self.searchText = searchText
        self.sortOrder = sortOrder
    }
    
    public static let `default` = ShoppingListFilter()
}

public enum SortOrder: String, CaseIterable, Identifiable {
    case createdDateAscending = "created_asc"
    case createdDateDescending = "created_desc"
    case modifiedDateAscending = "modified_asc"
    case modifiedDateDescending = "modified_desc"
    case nameAscending = "name_asc"
    case nameDescending = "name_desc"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .createdDateAscending: return "Created (Oldest First)"
        case .createdDateDescending: return "Created (Newest First)"
        case .modifiedDateAscending: return "Modified (Oldest First)"
        case .modifiedDateDescending: return "Modified (Newest First)"
        case .nameAscending: return "Name (A-Z)"
        case .nameDescending: return "Name (Z-A)"
        }
    }
}