import UIKit

final class MovieDetailsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    private let movieId: Int
    private let movieService: MovieServiceProtocol
    
    init(
        navigationController: UINavigationController,
        movieId: Int,
        movieService: MovieServiceProtocol
    ) {
        self.navigationController = navigationController
        self.movieId = movieId
        self.movieService = movieService
    }
    
    func start() {
        let vm = MovieDetailsViewModel(movieService: movieService)
        let vc = MovieDetailsViewController(
            movieId: movieId,
            movieDetailsViewModel: vm
        )
        
        vc.onDismiss = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
