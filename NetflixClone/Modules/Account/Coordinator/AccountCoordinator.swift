import UIKit

final class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var onFinish: (() -> Void)?
    var onSignOut: (() -> Void)?
    
    func start() {
        let vc = AccountViewController()
        vc.hidesBottomBarWhenPushed = true
        
        // Listen for back button press / swipe-to-dismiss
        vc.onDismiss = { [weak self] in
            self?.onFinish?()
        }
        
        vc.onSignOutTapped = { [weak self] in
            self?.onSignOut?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
