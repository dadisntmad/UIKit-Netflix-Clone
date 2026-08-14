import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // IMPORTANT: SceneDelegate must hold a strong reference to the coordinator.
    // window.rootViewController does NOT hold an AppCoordinator, so without this
    // property the coordinator will be freed from memory immediately after start(),
    // and all its Combine/Task subscriptions will be terminated.
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let coordinator = AppCoordinator(
            window: window,
            authService: AuthService(),
            keychainService: KeychainService()
        )
        
        self.appCoordinator = coordinator
        coordinator.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

