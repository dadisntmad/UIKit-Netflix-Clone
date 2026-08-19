import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var movieService: MovieServiceProtocol
    
    init(
        navigationController: UINavigationController,
        movieService: MovieServiceProtocol,
    ) {
        self.navigationController = navigationController
        self.movieService = movieService
    }
    
    func start() {
        let homeViewModel = HomeViewModel(movieService: movieService)
        let vc = HomeViewController(homeViewModel: homeViewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
}
