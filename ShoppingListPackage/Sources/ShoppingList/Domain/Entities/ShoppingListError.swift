import Foundation

public enum ShoppingListError: Error, LocalizedError, Equatable {
    case networkError(String)
    case syncError(String)
    case persistenceError(String)
    case validationError(String)
    case itemNotFound(UUID)
    case backgroundTaskFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .syncError(let message):
            return "Sync error: \(message)"
        case .persistenceError(let message):
            return "Storage error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .itemNotFound(let id):
            return "Item not found: \(id.uuidString)"
        case .backgroundTaskFailed(let message):
            return "Background task failed: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again."
        case .syncError:
            return "The item will be synced when connection is restored."
        case .persistenceError:
            return "Try restarting the app."
        case .validationError:
            return "Please check your input and try again."
        case .itemNotFound:
            return "The item may have been deleted."
        case .backgroundTaskFailed:
            return "Background sync will retry automatically."
        }
    }
}