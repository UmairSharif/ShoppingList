# ShoppingList Package - Design Document

## 🎯 Architecture Overview

This document describes the detailed architecture, design decisions, and implementation patterns used in the ShoppingList Swift package.

## 📐 Clean Architecture Implementation

### Layer Separation

```
┌─────────────────────────────────────────────────┐
│                 Presentation                    │
│  ┌─────────────┐ ┌─────────────┐ ┌────────────┐ │
│  │    Views    │ │ ViewModels  │ │ViewControllers│ │
│  └─────────────┘ └─────────────┘ └────────────┘ │
├─────────────────────────────────────────────────┤
│                   Domain                        │
│  ┌─────────────┐ ┌─────────────┐ ┌────────────┐ │
│  │  Entities   │ │ Use Cases   │ │Repositories│ │
│  │             │ │             │ │(Protocols) │ │
│  └─────────────┘ └─────────────┘ └────────────┘ │
├─────────────────────────────────────────────────┤
│                    Data                         │
│  ┌─────────────┐ ┌─────────────┐ ┌────────────┐ │
│  │   Local     │ │   Remote    │ │Repository  │ │
│  │DataSources  │ │DataSources  │ │   Impl     │ │
│  └─────────────┘ └─────────────┘ └────────────┘ │
├─────────────────────────────────────────────────┤
│            Dependency Injection                 │
│  ┌─────────────┐ ┌─────────────┐ ┌────────────┐ │
│  │   Factory   │ │ Container   │ │   Config   │ │
│  └─────────────┘ └─────────────┘ └────────────┘ │
└─────────────────────────────────────────────────┘
```

### Dependency Rule

- **Outer layers depend on inner layers**
- **Inner layers never depend on outer layers**
- **Dependencies point inward only**
- **Business logic is isolated from frameworks**

## 🏗️ Detailed Component Design

### Domain Layer

#### Entities

**ShoppingItem**
```swift
public struct ShoppingItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var quantity: Int
    public var note: String
    public var isBought: Bool
    public var createdAt: Date
    public var modifiedAt: Date
    public var syncStatus: SyncStatus
}
```

**Design Decisions:**
- **Struct over Class**: Immutability by default, value semantics
- **UUID Identity**: Unique identification across devices
- **Sync Status**: Track synchronization state for offline-first approach
- **Validation**: Business rules enforced in use cases, not entities

#### Use Cases

**DefaultShoppingListUseCases**
- **Single Responsibility**: Each method handles one business operation
- **Input Validation**: All user inputs validated before processing
- **Error Handling**: Comprehensive error types with recovery suggestions
- **Filtering & Sorting**: Complex business logic for item filtering

```swift
public func getFilteredItems(_ filter: ShoppingListFilter) async throws -> [ShoppingItem] {
    // 1. Fetch all items
    // 2. Apply bought/not bought filter
    // 3. Apply search text filter
    // 4. Apply sorting
    // 5. Return filtered and sorted results
}
```

#### Repository Protocol

**ShoppingListRepository**
- **Abstraction**: Domain doesn't depend on data layer implementations
- **Async/Await**: Modern concurrency for all operations
- **Delegate Pattern**: Real-time updates to presentation layer

### Data Layer

#### Local Data Source

**SwiftDataLocalDataSource**
- **ModelActor**: Thread-safe SwiftData operations
- **Predicate Building**: Type-safe query construction
- **Domain Mapping**: Clean separation between persistence models and domain entities

```swift
@ModelActor
public actor SwiftDataLocalDataSource: LocalDataSource {
    public func searchItems(query: String) async throws -> [ShoppingItem] {
        let predicate = #Predicate<ShoppingItemModel> { model in
            model.name.localizedStandardContains(trimmedQuery) ||
            model.note.localizedStandardContains(trimmedQuery)
        }
        // Execute query and map to domain models
    }
}
```

#### Remote Data Source

**MockRemoteDataSource**
- **HTTP Client**: URLSession-based REST API client
- **JSON Serialization**: Custom date formatting for API compatibility
- **Error Mapping**: Network errors mapped to domain errors
- **Testability**: Protocol-based design for easy mocking

#### Background Sync Manager

**BackgroundSyncManager**
- **Exponential Backoff**: 2^attempt * baseDelay retry strategy
- **Background Tasks**: Integration with iOS BackgroundTasks framework
- **Conflict Resolution**: Last-write-wins with timestamp comparison
- **Batch Processing**: Efficient handling of multiple unsynchronized items

```swift
private func performSyncWithRetry(attempt: Int = 0) async {
    do {
        try await syncUnsyncedItems()
    } catch {
        if attempt < maxRetryAttempts {
            let delay = baseRetryDelay * pow(2.0, Double(attempt))
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            await performSyncWithRetry(attempt: attempt + 1)
        }
    }
}
```

### Presentation Layer

#### MVVM Implementation

**ShoppingListViewModel**
- **ObservableObject**: SwiftUI reactive updates
- **MainActor**: UI updates on main thread
- **State Management**: Centralized UI state with proper error handling
- **Repository Delegate**: Real-time updates from data layer

```swift
@MainActor
public class ShoppingListViewModel: ObservableObject {
    @Published public var items: [ShoppingItem] = []
    @Published public var filteredItems: [ShoppingItem] = []
    @Published public var filter = ShoppingListFilter.default
    @Published public var isLoading = false
    @Published public var errorMessage: String?
}
```

#### SwiftUI Views

**Component Architecture**
- **Single Responsibility**: Each view has one clear purpose
- **Composition**: Complex views built from smaller components
- **Accessibility**: Full VoiceOver and accessibility support
- **State Driven**: UI reflects view model state

**View Hierarchy**
```
ShoppingListView
├── SearchBar
├── EmptyStateView
├── List
│   └── ShoppingItemRow
│       └── SyncStatusIndicator
├── FilterView (Sheet)
├── AddItemView (Sheet)
└── EditItemView (Sheet)
```

#### UIKit Integration

**ShoppingListViewController**
- **Hosting Controller**: SwiftUI embedded in UIKit
- **Lifecycle Management**: Proper view controller lifecycle
- **Navigation**: Integration with UINavigationController

### Dependency Injection

#### Factory Pattern

**ShoppingListFactory**
- **Creation Methods**: Factory methods for different entry points
- **Configuration**: Centralized configuration management
- **Error Handling**: Comprehensive initialization error handling

#### Dependency Container

**DefaultDependencyContainer**
- **Lazy Initialization**: Dependencies created on first access
- **Singleton Pattern**: Shared instances where appropriate
- **Protocol Conformance**: Easy testing and mocking

```swift
public class DefaultDependencyContainer: DependencyContainer {
    private lazy var repository: ShoppingListRepository = {
        DefaultShoppingListRepository(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            backgroundSyncManager: backgroundSyncManager
        )
    }()
}
```

## 🔄 Data Flow Patterns

### User Action Flow

```
1. User Interaction (View)
       ↓
2. ViewModel Method Call
       ↓
3. Use Case Invocation
       ↓
4. Repository Operation
       ↓
5. Data Source Update
       ↓
6. Repository Delegate Callback
       ↓
7. ViewModel State Update
       ↓
8. UI Re-render (SwiftUI)
```

### Synchronization Flow

```
1. Local Change
       ↓
2. Mark as .notSynced
       ↓
3. Background Sync Trigger
       ↓
4. Retry with Exponential Backoff
       ↓
5. Success: Mark as .synced
   Failure: Mark as .failed
       ↓
6. UI Status Update
```

## 🧪 Testing Strategy

### Test Architecture

```
Tests/
├── Domain/
│   ├── ShoppingItemTests.swift
│   └── ShoppingListUseCasesTests.swift
├── Data/
│   └── RemoteDataSourceTests.swift
├── Presentation/
│   └── ShoppingListViewModelTests.swift
└── Mocks/
    ├── MockShoppingListRepository.swift
    └── MockShoppingListUseCases.swift
```

### Testing Patterns

#### Swift Testing Framework
- **#Test Attribute**: Modern test declaration
- **#expect Macro**: Expressive assertions
- **Async Testing**: Proper async/await test patterns
- **Error Testing**: Comprehensive error scenario coverage

#### Mock Objects
- **Protocol Conformance**: Mocks implement the same protocols as real objects
- **State Tracking**: Mocks track method calls and state changes
- **Configurable Behavior**: Mocks can simulate success and error scenarios

```swift
@MainActor
class MockShoppingListRepository: ShoppingListRepository {
    var items: [ShoppingItem] = []
    var addedItems: [ShoppingItem] = []
    var shouldThrowError = false
    
    func addItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        if shouldThrowError {
            throw ShoppingListError.persistenceError("Mock error")
        }
        addedItems.append(item)
        return item
    }
}
```

## 🔒 Security Considerations

### Data Protection
- **SwiftData Encryption**: Leverages iOS data protection
- **No Sensitive Logging**: Careful logging to avoid exposing user data
- **Input Sanitization**: All user inputs validated and sanitized

### Network Security
- **HTTPS Only**: All network requests use secure connections
- **Certificate Pinning**: Ready for certificate pinning implementation
- **Timeout Handling**: Proper timeout and retry logic

## 🚀 Performance Optimizations

### Memory Management
- **Weak References**: Avoid retain cycles in delegates
- **Actor Isolation**: Thread-safe data access with minimal overhead
- **Lazy Loading**: Dependencies and data loaded on demand

### Database Performance
- **Optimized Predicates**: Efficient SwiftData queries
- **Batch Operations**: Multiple operations combined for efficiency
- **Index Strategy**: UUID primary keys for fast lookups

### UI Performance
- **Main Actor**: UI updates guaranteed on main thread
- **Efficient Filtering**: Smart filtering with minimal data processing
- **View Recycling**: List views with proper cell reuse

## 🔧 Configuration & Extensibility

### Configuration Options

**ShoppingListConfig**
```swift
public struct ShoppingListConfig {
    public let apiBaseURL: String
    public let syncInterval: TimeInterval
    public let enableBackgroundSync: Bool
    public let maxRetryAttempts: Int
    public let baseRetryDelay: TimeInterval
}
```

### Extension Points
- **Custom Data Sources**: Implement LocalDataSource or RemoteDataSource protocols
- **Custom Use Cases**: Extend or replace DefaultShoppingListUseCases
- **Custom Views**: Use ShoppingListViewModel with custom SwiftUI views
- **Custom Error Handling**: Implement ShoppingListRepositoryDelegate

## 📊 Monitoring & Observability

### Error Tracking
- **Structured Errors**: Comprehensive error types with context
- **Error Propagation**: Proper error bubbling through layers
- **User-Friendly Messages**: Error messages with recovery suggestions

### Logging Strategy
- **Layer-Specific Logging**: Different log levels for each layer
- **No PII Logging**: Careful to avoid logging personal information
- **Debug Information**: Rich debugging information in development

## 🔄 Migration & Versioning

### Data Migration
- **SwiftData Migration**: Automatic schema migration support
- **Version Compatibility**: Backwards compatible data models
- **Migration Testing**: Comprehensive migration test coverage

### API Versioning
- **Version Headers**: API version in HTTP headers
- **Graceful Degradation**: Fallback for unsupported API versions
- **Feature Flags**: Runtime feature toggling capability

## 🎯 Design Principles Applied

### SOLID Principles
- **S**: Single Responsibility - Each class has one reason to change
- **O**: Open/Closed - Open for extension, closed for modification
- **L**: Liskov Substitution - Implementations interchangeable via protocols
- **I**: Interface Segregation - Focused protocols, no fat interfaces
- **D**: Dependency Inversion - High-level modules don't depend on low-level modules

### Additional Patterns
- **Repository Pattern**: Abstraction over data access
- **Factory Pattern**: Object creation encapsulated
- **Observer Pattern**: Reactive updates via delegates and Combine
- **Strategy Pattern**: Configurable behavior via protocols

---

This design document serves as the technical blueprint for the ShoppingList package, ensuring maintainability, testability, and extensibility for future enhancements.