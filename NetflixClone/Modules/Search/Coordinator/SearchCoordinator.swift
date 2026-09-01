import UIKit

final class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var onFinish: (() -> Void)?
    
    func start() {
        let vc = SearchViewController()
        
        vc.onDidDisappear = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
