import UIKit
import Combine

final class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    private let authService: AuthServiceProtocol
    private let keychainService: KeychainServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        navigationController: UINavigationController,
        authService: AuthServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.keychainService = keychainService
    }
    
    func start() {
        let vm = AuthViewModel(authService: authService, keychainService: keychainService)
        let vc = AuthViewController(viewModel: vm)
        
        vm.$isAuthenticated
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onFinish?()
            }
            .store(in: &cancellables)
        
        navigationController.setViewControllers([vc], animated: true)
    }
}
