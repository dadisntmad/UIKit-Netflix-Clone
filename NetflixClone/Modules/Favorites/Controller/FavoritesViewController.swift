import UIKit

final class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        getFavoriteMovies()
    }
    
    private func getFavoriteMovies() {
        Task {
            await viewModel.getFavoriteMovies()
        }
    }
}
