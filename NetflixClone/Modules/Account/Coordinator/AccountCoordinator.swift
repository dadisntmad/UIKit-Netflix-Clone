import UIKit

final class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    private let userService: UserServiceProtocol
    
    init(
        navigationController: UINavigationController,
        userService: UserServiceProtocol
    ) {
        self.navigationController = navigationController
        self.userService = userService
    }
    
    var onFinish: (() -> Void)?
    var onSignOut: (() -> Void)?
    
    func start() {
        let accountViewModel = AccountViewModel(userService: userService)
        let vc = AccountViewController(accountViewModel: accountViewModel)
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
