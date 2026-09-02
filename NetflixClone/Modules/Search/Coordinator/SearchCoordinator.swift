import UIKit

final class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let movieService: MovieServiceProtocol
    
    init(
        navigationController: UINavigationController,
        movieService: MovieServiceProtocol
    ) {
        self.navigationController = navigationController
        self.movieService = movieService
    }
    
    var onFinish: (() -> Void)?
    
    func start() {
        let searchViewModel = SearchViewModel(movieService: movieService)
        let vc = SearchViewController(searchViewModel: searchViewModel)
        
        vc.onDidDisappear = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
