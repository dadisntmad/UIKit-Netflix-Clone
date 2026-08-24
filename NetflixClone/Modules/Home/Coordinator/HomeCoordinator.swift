import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let movieService: MovieServiceProtocol
    private let userService: UserServiceProtocol
    
    
    init(
        navigationController: UINavigationController,
        movieService: MovieServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.navigationController = navigationController
        self.movieService = movieService
        self.userService = userService
    }
    
    func start() {
        let homeViewModel = HomeViewModel(movieService: movieService)
        let accountViewModel = AccountViewModel(userService: userService)
        let vc = HomeViewController(homeViewModel: homeViewModel, accountViewModel: accountViewModel)
        
        vc.onProfileTapped = { [weak self] in
            self?.showAccountFlow()
        }
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showAccountFlow() {
        let accountCoordinator = AccountCoordinator(navigationController: navigationController)
        
        // Handle cleanup when AccountViewController is popped
        accountCoordinator.onFinish = { [weak self, weak accountCoordinator] in
            guard let self, let accountCoordinator else { return }
            self.removeChild(accountCoordinator)
        }
        
        addChild(accountCoordinator)
        accountCoordinator.start()
    }
}
