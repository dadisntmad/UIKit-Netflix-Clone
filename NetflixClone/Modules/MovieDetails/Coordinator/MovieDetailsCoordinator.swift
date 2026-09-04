import UIKit

final class MovieDetailsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MovieDetailsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
