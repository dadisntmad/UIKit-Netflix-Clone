import UIKit

final class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        // Disable Auto Layout estimated sizing so explicit itemSize works:
        layout.estimatedItemSize = .zero
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(FavoriteCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteCollectionViewCell.identifier)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
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
        title = "Favorite Movies"
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        getFavoriteMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        
        // Calculate cell size for exactly 2 columns based on screen width
        let padding: CGFloat = 16 * 3 // left (16) + right (16) + inter-item spacing (16)
        let width = (view.bounds.width - padding) / 2
        layout.itemSize = CGSize(width: width, height: width * 1.75)
    }
    
    private func getFavoriteMovies() {
        Task {
            await viewModel.getFavoriteMovies()
            await MainActor.run {
                self.collectionView.reloadData()
            }
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.favoriteMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCollectionViewCell.identifier, for: indexPath) as? FavoriteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie = viewModel.favoriteMovies[indexPath.item]
        
        cell.onUnmark = { [weak self, weak collectionView] in
            guard let self = self, let collectionView = collectionView else { return }
            
            Task {
                await self.viewModel.unmarkMovieAsFavorite(for: movie.id)
                
                // Refresh data and remove deleted item from collection view UI
                await MainActor.run {
                    if let currentIndexPath = collectionView.indexPath(for: cell) {
                        collectionView.deleteItems(at: [currentIndexPath])
                    } else {
                        collectionView.reloadData()
                    }
                }
            }
        }
        
        cell.configure(with: movie)
        
        return cell
    }
}
