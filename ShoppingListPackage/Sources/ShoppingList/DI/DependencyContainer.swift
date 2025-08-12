import Foundation
import SwiftData

public protocol DependencyContainer {
    func makeShoppingListRepository() -> ShoppingListRepository
    func makeShoppingListUseCases() -> ShoppingListUseCases
    @MainActor func makeShoppingListViewModel() -> ShoppingListViewModel
#if canImport(UIKit)
    @MainActor func makeShoppingListViewController() -> ShoppingListViewController
#endif
}

public class DefaultDependencyContainer: DependencyContainer {
    private let config: ShoppingListConfig
    private let modelContainer: ModelContainer
    
    private lazy var localDataSource: LocalDataSource = {
        SwiftDataLocalDataSource(modelContainer: modelContainer)
    }()
    
    private lazy var remoteDataSource: RemoteDataSource = {
        MockRemoteDataSource(baseURL: config.apiBaseURL)
    }()
    
    private lazy var backgroundSyncManager: BackgroundSyncManager = {
        BackgroundSyncManager(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
            syncInterval: config.syncInterval
        )
    }()
    
    private lazy var repository: ShoppingListRepository = {
        DefaultShoppingListRepository(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            backgroundSyncManager: backgroundSyncManager
        )
    }()
    
    private lazy var useCases: ShoppingListUseCases = {
        DefaultShoppingListUseCases(repository: repository)
    }()
    
    public init(config: ShoppingListConfig = .default, modelContainer: ModelContainer) {
        self.config = config
        self.modelContainer = modelContainer
    }
    
    public func makeShoppingListRepository() -> ShoppingListRepository {
        return repository
    }
    
    public func makeShoppingListUseCases() -> ShoppingListUseCases {
        return useCases
    }
    
    @MainActor
    public func makeShoppingListViewModel() -> ShoppingListViewModel {
        return ShoppingListViewModel(useCases: useCases, repository: repository)
    }
    
#if canImport(UIKit)
    @MainActor
    public func makeShoppingListViewController() -> ShoppingListViewController {
        return ShoppingListViewController(viewModel: makeShoppingListViewModel())
    }
#endif
}