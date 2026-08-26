import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private let window: UIWindow
    private let authService: AuthServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let movieService: MovieServiceProtocol
    private let userService: UserServiceProtocol
    
    init(
        window: UIWindow,
        authService: AuthServiceProtocol,
        keychainService: KeychainServiceProtocol,
        movieService: MovieServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.window = window
        self.navigationController = UINavigationController()
        self.authService = authService
        self.keychainService = keychainService
        self.movieService = movieService
        self.userService = userService
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        Task {
            await resolveInitialFlow()
        }
    }
    
    // MARK: - Private
    private func resolveInitialFlow() async {
        let sessionId = await keychainService.load(forKey: AppConstants.sessionId)
        sessionId != nil ? showMain() : showAuth()
    }
    
    private func showAuth() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            authService: authService,
            keychainService: keychainService
        )
        
        // weak self AND weak authCoordinator — to avoid retain cycle
        // between AppCoordinator (which holds authCoordinator in childCoordinators)
        // and the closure that authCoordinator holds in itself.
        authCoordinator.onFinish = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }
            self.removeChild(authCoordinator)
            self.showMain()
        }
        
        addChild(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMain() {
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            movieService: movieService,
            userService: userService
        )
        
        mainCoordinator.onSignOut = { [weak self] in
            Task { [weak self] in
                guard let self else { return }
                
                let sessionId = await keychainService.load(forKey: AppConstants.sessionId)
                
                guard let sessionId = sessionId else { return }
                
                let _ = try await authService.signOut(sessionId: sessionId)
                keychainService.delete(forKey: AppConstants.sessionId)
                
                self.childCoordinators.removeAll()
                self.showAuth()
            }
        }
        
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
}
