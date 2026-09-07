import UIKit

final class MovieDetailsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    private let movie: Movie
    
    init(navigationController: UINavigationController, movie: Movie) {
        self.navigationController = navigationController
        self.movie = movie
    }
    
    func start() {
        let vc = MovieDetailsViewController(movie: movie)
        
        vc.onDismiss = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
