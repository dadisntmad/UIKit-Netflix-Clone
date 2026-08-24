import UIKit

final class AccountViewController: UIViewController {
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Triggers only when pushed/popped from navigation stack, not when presenting modally
        if isMovingFromParent {
            onDismiss?()
        }
    }
}
