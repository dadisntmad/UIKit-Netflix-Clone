import UIKit

/// Basic protocol for all coordinators in the app
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinator {
    /// Adds a child coordinator and remembers it so it doesn't run out of memory
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Removes the child coordinator when its flow is complete (for example, after dismiss)
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
