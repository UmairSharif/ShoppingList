
⸻

📱 iOS Engineer Code Challenge – Architecture Focused

# Overview

Build a modular Shopping List feature in Swift designed to integrate into a larger super-app. The module should follow offline-first principles, maintain a clean architecture, and support local persistence, background sync, and filtering/searching functionalities.

⸻

✨ Feature Requirements
   ### Users must be able to:
    •    Add, edit, or delete a shopping item with:
    •    name (required)
    •    quantity (required)
    •    note (optional)
    •    Mark an item as “bought”
    •    Bought items are hidden by default and can be toggled with a filter
    •    The list must support:
    •    Filtering (bought / not bought)
    •    Searching by name or note
    •    Sorting by creation/modification date (ascending or descending)

⸻

💾 Data Requirements
    •    Local persistence using one of:
    •    SwiftData, Core Data, or Realm
    •    Remote sync to a JSON-based REST API (mock or stub is acceptable)
    •    Offline-first behavior:
    •    The feature must work fully offline
    •    Background sync must reconcile changes using a last-write-wins strategy (based on timestamps)

⸻

🏗 Architecture Requirements
    •    Use a layered architecture:
    •    Clean Architecture, MVVM, or MVI
    •    Implement a Repository Layer
    •    Define clear module boundaries

⸻

📦 Technical Requirements

Modular Design
    •    Package the feature as either:
    •    A Swift Package
    •    A standalone Framework
    •    Expose a single clean interface, such as:
    •    ShoppingListViewController (UIKit)
    •    ShoppingListView (SwiftUI)

Dependency Injection
    •    Use one of the following:
    •    Resolver
    •    Factory Pattern
    •    Manual injection
    •    Be prepared to explain your DI strategy

Testing
    •    Write unit tests for ViewModels/business logic
    •    Include at least one UI test using XCTest or Swift Testing (#Test macros)

Git Requirements
    •    Use at least 5 incremental commits
    •    Each commit must have a descriptive message representing meaningful development steps

⸻

📄 Project Artifacts
    •    README.md
    •    Build and run instructions
    •    List of AI tools and/or prompts used (if any)
    •    DESIGN_DOC.md (max 600 words)
    •    Summarize architecture decisions
    •    Highlight two rejected alternatives with reasoning

⸻

🏅 Extra Credit

You can earn bonus points by implementing:
    •    Background sync using BackgroundTasks or Combine + URLSession
    •    Include retry logic with exponential back-off
    •    Use Swift Testing macros (#Test, #expect) instead of XCTest
    •    Provide well-documented, clean, and modular code
    •    Ensure the code is memory-efficient and easy to understand
