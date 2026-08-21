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
        navigationController.setViewControllers([vc], animated: false)
    }
}
