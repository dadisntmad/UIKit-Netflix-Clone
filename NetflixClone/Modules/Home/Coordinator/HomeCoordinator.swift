import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let movieService: MovieServiceProtocol
    private let userService: UserServiceProtocol
    
    var onSignOut: (() -> Void)?
    
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
        let homeViewModel = HomeViewModel(movieService: movieService, userService: userService)
        let vc = HomeViewController(homeViewModel: homeViewModel)
        
        vc.onProfileTapped = { [weak self] in
            self?.showAccountFlow()
        }
        
        vc.onSearchTapped = { [weak self] in
            self?.showSearchFlow()
        }
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showAccountFlow() {
        let accountCoordinator = AccountCoordinator(
            navigationController: navigationController,
            userService: userService
        )
        
        // Handle cleanup when AccountViewController is popped
        accountCoordinator.onFinish = { [weak self, weak accountCoordinator] in
            guard let self, let accountCoordinator else { return }
            self.removeChild(accountCoordinator)
        }
        
        accountCoordinator.onSignOut = { [weak self] in
            self?.onSignOut?()
        }
        
        addChild(accountCoordinator)
        accountCoordinator.start()
    }
    
    private func showSearchFlow() {
        let searchCoordinator = SearchCoordinator(
            navigationController: navigationController,
            movieService: movieService
        )
        
        searchCoordinator.onFinish = { [weak self, weak searchCoordinator] in
            guard let self, let searchCoordinator else { return }
            self.removeChild(searchCoordinator)
        }
        
        addChild(searchCoordinator)
        searchCoordinator.start()
    }
}
