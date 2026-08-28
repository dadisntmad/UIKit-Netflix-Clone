import UIKit

final class NewAndHotCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let moviService: MovieServiceProtocol
    
    init(
        navigationController: UINavigationController,
        moviService: MovieServiceProtocol
    ) {
        self.navigationController = navigationController
        self.moviService = moviService
    }
    
    func start() {
        let viewModel = NewAndHotViewModel(movieService: moviService)
        let vc = NewAndHotViewController(newAndHotViewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
}
