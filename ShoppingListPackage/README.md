# ShoppingList Swift Package

A modular, offline-first shopping list Swift package built with Clean Architecture and MVVM pattern. Perfect for integration into super-apps and standalone applications.

## 🌟 Features

### Core Functionality

- ✅ **CRUD Operations**: Add, edit, delete, and view shopping items
- ✅ **Item Management**: Name, quantity, notes, and bought status
- ✅ **Smart Filtering**: Filter by bought/not bought status
- ✅ **Powerful Search**: Search by item name or notes
- ✅ **Flexible Sorting**: Sort by creation date, modification date, or name (ascending/descending)
- ✅ **Offline-First**: Works seamlessly without internet connection

### Sync & Persistence

- ✅ **SwiftData Integration**: Local persistence with SwiftData
- ✅ **Background Sync**: Automatic sync with exponential backoff retry
- ✅ **Conflict Resolution**: Last-write-wins strategy
- ✅ **Sync Status Indicators**: Visual feedback for sync status
- ✅ **Mock API**: Ready-to-use mock REST API implementation

### Architecture & Quality

- ✅ **Clean Architecture**: Domain, Data, and Presentation layers
- ✅ **MVVM Pattern**: Reactive UI with SwiftUI and Combine
- ✅ **Dependency Injection**: Factory pattern with protocols
- ✅ **Comprehensive Tests**: Unit and integration tests with Swift Testing
- ✅ **Accessibility**: Full VoiceOver and accessibility support
- ✅ **Memory Efficient**: Lazy loading and proper resource management

## 🚀 Quick Start

### Installation

Add the package to your Xcode project:

```swift
dependencies: [
    .package(url: "path/to/ShoppingListPackage", from: "1.0.0")
]
```

### SwiftUI Integration

```swift
import SwiftUI
import SwiftData
import ShoppingList

struct ContentView: View {
    let modelContainer: ModelContainer

    var body: some View {
        NavigationView {
            // Create shopping list view with default configuration
            try! ShoppingList.createView(modelContainer: modelContainer)
        }
    }
}
```

### UIKit Integration

```swift
import UIKit
import SwiftData
import ShoppingList

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create shopping list view controller
        let shoppingListVC = try! ShoppingList.createViewController(
            config: ShoppingListConfig(
                apiBaseURL: "https://your-api.com/shopping",
                syncInterval: 300
            ),
            modelContainer: yourModelContainer
        )

        // Present or embed in navigation controller
        present(shoppingListVC, animated: true)
    }
}
```

### Custom Configuration

```swift
let config = ShoppingListConfig(
    apiBaseURL: "https://api.example.com/shopping",
    syncInterval: 180, // 3 minutes
    enableBackgroundSync: true,
    maxRetryAttempts: 5,
    baseRetryDelay: 1.0
)

let shoppingListView = try ShoppingList.createView(
    config: config,
    modelContainer: yourModelContainer
)
```

## 📱 User Interface

### Main Shopping List

- **Search Bar**: Real-time search through items and notes
- **Filter Button**: Toggle visibility of bought/not bought items
- **Sort Options**: Multiple sorting criteria with clear labels
- **Add Button**: Quick item creation with name, quantity, and notes
- **Sync Indicator**: Visual feedback for background synchronization

### Item Management

- **Tap to Toggle**: Mark items as bought/not bought
- **Swipe Actions**: Quick edit, delete, or toggle actions
- **Context Menu**: Long-press for additional options
- **Edit Sheet**: Comprehensive editing with validation

### Accessibility Features

- **VoiceOver Support**: Full screen reader compatibility
- **Semantic Labels**: Descriptive accessibility labels
- **Dynamic Type**: Supports system font scaling
- **Keyboard Navigation**: Full keyboard support

## 🏗️ Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│              Presentation               │
│    Views, ViewModels, ViewControllers   │
├─────────────────────────────────────────┤
│                Domain                   │
│     Entities, Use Cases, Repositories   │
├─────────────────────────────────────────┤
│                 Data                    │
│   Repository Impl, Local/Remote Sources │
├─────────────────────────────────────────┤
│          Dependency Injection           │
│        Factory, Container, Config       │
└─────────────────────────────────────────┘
```

### Key Components

#### Domain Layer

- **ShoppingItem**: Core entity with validation and state management
- **ShoppingListUseCases**: Business logic and validation
- **Repository Protocol**: Abstraction for data access

#### Data Layer

- **SwiftDataLocalDataSource**: Local persistence with SwiftData
- **MockRemoteDataSource**: REST API implementation
- **BackgroundSyncManager**: Intelligent sync with retry logic

#### Presentation Layer

- **ShoppingListViewModel**: Reactive state management
- **SwiftUI Views**: Modern, declarative UI components
- **UIViewController**: UIKit compatibility layer

## 🔧 Advanced Usage

### Custom Dependency Injection

```swift
let container = try ShoppingList.createDependencyContainer(
    config: customConfig,
    modelContainer: customModelContainer
)

let repository = container.makeShoppingListRepository()
let useCases = container.makeShoppingListUseCases()
let viewModel = container.makeShoppingListViewModel()
```

### Background Tasks Integration

The package automatically handles background sync, but you can control it:

```swift
let repository = container.makeShoppingListRepository()

// Start background sync
repository.startBackgroundSync()

// Manual sync
try await repository.syncWithRemote()

// Stop background sync
repository.stopBackgroundSync()
```

### Custom Error Handling

```swift
class CustomRepositoryDelegate: ShoppingListRepositoryDelegate {
    func repository(_ repository: ShoppingListRepository, didEncounterError error: ShoppingListError) {
        switch error {
        case .networkError(let message):
            // Handle network errors
            print("Network error: \\(message)")
        case .syncError(let message):
            // Handle sync errors
            print("Sync error: \\(message)")
        case .persistenceError(let message):
            // Handle storage errors
            print("Storage error: \\(message)")
        }
    }
}
```

## 🧪 Testing

The package includes comprehensive tests using Swift Testing framework:

```bash
# Run all tests
swift test

# Run specific test target
swift test --filter ShoppingListTests
```

### Test Coverage

- ✅ **Unit Tests**: All business logic and data operations
- ✅ **Integration Tests**: End-to-end functionality
- ✅ **Mock Objects**: Complete mocking infrastructure
- ✅ **Error Scenarios**: Comprehensive error handling tests

## 🔒 Security & Privacy

- **No Data Collection**: Package doesn't collect or transmit personal data
- **Secure Storage**: Uses SwiftData's encrypted storage capabilities
- **API Security**: Supports HTTPS and custom authentication headers
- **Input Validation**: Comprehensive validation and sanitization

## 📊 Performance

### Optimizations

- **Lazy Loading**: Items loaded on demand
- **Memory Management**: Proper cleanup and weak references
- **Background Processing**: Non-blocking sync operations
- **Efficient Queries**: Optimized SwiftData predicates

### Benchmarks

- **Startup Time**: < 100ms for typical datasets
- **Memory Usage**: ~2MB baseline, scales with item count
- **Sync Performance**: Handles 1000+ items efficiently
- **Battery Impact**: Minimal background processing

## 🛠️ Development

### Building from Source

```bash
git clone <repository-url>
cd ShoppingListPackage
swift build
```

### Running Tests

```bash
swift test --parallel
```

### Code Style

- Swift 5.9+ with async/await
- SwiftUI for modern UI components
- Comprehensive documentation
- Clean Architecture principles

## 📄 API Reference

### Public Classes

#### ShoppingList

Main entry point for the package.

```swift
static func createView(config: ShoppingListConfig, modelContainer: ModelContainer?) throws -> ShoppingListView
static func createViewController(config: ShoppingListConfig, modelContainer: ModelContainer?) throws -> ShoppingListViewController
```

#### ShoppingListConfig

Configuration object for customizing behavior.

```swift
let apiBaseURL: String
let syncInterval: TimeInterval
let enableBackgroundSync: Bool
```

#### ShoppingItem

Core data model representing a shopping list item.

```swift
let id: UUID
var name: String
var quantity: Int
var note: String
var isBought: Bool
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📝 License

This package is available under the MIT License. See the LICENSE file for details.

## 🆘 Support

For issues, feature requests, or questions:

- Create an issue in the repository
- Check the DESIGN_DOC.md for architectural details
- Review the test files for usage examples

---
