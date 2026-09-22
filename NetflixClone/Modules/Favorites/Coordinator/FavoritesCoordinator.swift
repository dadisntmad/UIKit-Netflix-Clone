import UIKit

final class FavoritesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let movieService: MovieServiceProtocol
    
    init(navigationController: UINavigationController, movieService: MovieServiceProtocol) {
        self.navigationController = navigationController
        self.movieService = movieService
    }
    
    func start() {
        let vm = FavoritesViewModel(movieService: movieService)
        let vc = FavoritesViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: false)
    }
}
