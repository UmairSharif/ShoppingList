### List of tools

- ChatGPT desktop
- GPT-assisted test case generation

### Summarize architecture decisions

- Layered package structure: `Data` (Local/Remote/Repository), `Domain` (Entities/UseCases), `Presentation` (ViewModels/Views) inside `ShoppingListPackage` for clear separation and testability.
- MVVM: `ShoppingListViewModel` owns UI state and orchestrates async use cases; Views stay declarative.
- Repository pattern: `DefaultShoppingListRepository` mediates Local/Remote, normalizes errors, and reports via a delegate for UI updates.
- Offline-first persistence: SwiftData-backed `SwiftDataLocalDataSource` (`@ModelActor`) for thread-safe local storage; all mutations persist locally first.
- Background sync: `BackgroundSyncManager` periodically syncs, with exponential backoff and safe BGTask submission guards; toggled via `ShoppingListConfig`.
- Networking: `MockRemoteDataSource` uses `URLSession` with JSON encode/decode and explicit date strategies; minimal dependencies.
- Use cases: `DefaultShoppingListUseCases` provide validation, filtering, and sorting; keep ViewModel lean and domain logic centralized.
- Dependency Injection: `DefaultDependencyContainer` wires Local/Remote/Repo/UseCases; `ShoppingListFactory` produces `ShoppingListView`/`ShoppingListViewController`, accepts external `ModelContainer` to avoid store collisions and starts background sync based on config.
- Error model: Centralized `ShoppingListError` distinguishes validation, persistence, sync, and network failures.

### Rejected alternatives (with reasoning)

- Online-first writes (remote-first): Rejected because it couples UX to network availability and increases perceived latency. Offline-first with background sync preserves responsiveness, enables retries, and degrades gracefully.
- Reactive pipelines (Combine) for data flow: Rejected to reduce complexity and dependencies. Async/await plus a simple repository delegate keeps concurrency explicit, testable, and compatible across environments without maintaining reactive plumbing.
