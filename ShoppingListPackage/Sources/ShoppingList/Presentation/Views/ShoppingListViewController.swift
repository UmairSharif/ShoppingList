#if canImport(UIKit)
import UIKit
import SwiftUI

public class ShoppingListViewController: UIViewController {
    private let viewModel: ShoppingListViewModel
    private var hostingController: UIHostingController<ShoppingListView>?
    
    public init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let shoppingListView = ShoppingListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: shoppingListView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.hostingController = hostingController
        
        title = "Shopping List"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await viewModel.loadItems()
        }
    }
    
    deinit {
        hostingController?.removeFromParent()
    }
}
#endif