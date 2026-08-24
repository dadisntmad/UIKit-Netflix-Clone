import UIKit

final class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var onFinish: (() -> Void)?
    
    func start() {
        let vc = AccountViewController()
        vc.hidesBottomBarWhenPushed = true
        
        // Listen for back button press / swipe-to-dismiss
        vc.onDismiss = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
