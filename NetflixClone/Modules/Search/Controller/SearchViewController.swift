import UIKit

final class SearchViewController: UIViewController {
    var onDidDisappear: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed  {
            onDidDisappear?()
        }
    }
}
