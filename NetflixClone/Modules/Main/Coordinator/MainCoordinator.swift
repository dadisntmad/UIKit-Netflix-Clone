import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        addChild(homeCoordinator)
        homeCoordinator.start()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: Icon.home), tag: 0)
        
        let newAndHotNav = UINavigationController()
        let newAndHotCoordinator = NewAndHotCoordinator(navigationController: newAndHotNav)
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
