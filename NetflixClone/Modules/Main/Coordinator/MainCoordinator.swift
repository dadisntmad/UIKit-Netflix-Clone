import UIKit

final class MainCoordinator: Coordinator {
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
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNav,
            movieService: movieService,
            userService: userService
        )
        
        homeCoordinator.onSignOut = { [weak self] in
            self?.onSignOut?()
        }
        
        addChild(homeCoordinator)
        homeCoordinator.start()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: Icon.home), tag: 0)
        
        let newAndHotNav = UINavigationController()
        let newAndHotCoordinator = NewAndHotCoordinator(
            navigationController: newAndHotNav,
            moviService: movieService
        )
        addChild(newAndHotCoordinator)
        newAndHotCoordinator.start()
        newAndHotNav.tabBarItem = UITabBarItem(title: "New & Hot", image: UIImage(named: Icon.new), tag: 1)
        
        let favoritesNav = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNav)
        addChild(favoritesCoordinator)
        favoritesCoordinator.start()
        favoritesNav.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: Icon.more), tag: 2)
        
        let tabBarController = MainTabBarController(viewControllers: [homeNav, newAndHotNav, favoritesNav])
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
