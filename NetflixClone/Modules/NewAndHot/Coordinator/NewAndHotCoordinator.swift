import UIKit

final class NewAndHotCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = NewAndHotViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
