import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private let emptyView = EmptyView()
    
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
        collectionView.backgroundView = emptyView
        collectionView.delegate = self
        collectionView.dataSource = self
        bindViewModel()
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
    
    private func bindViewModel() {
        viewModel.$favoriteMovies
            .receive(on: RunLoop.main)
            .sink { [weak self] favoriteMovies in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .loading:
                    self.emptyView.isHidden = true
                    
                case .success, .failure, .initial:
                    self.updateEmptyState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func getFavoriteMovies() {
        Task {
            await viewModel.getFavoriteMovies()
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.favoriteMovies.isEmpty
        let isLoading = viewModel.status == .loading
        
        emptyView.isHidden = isLoading || !isEmpty
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
                        collectionView.performBatchUpdates {
                            collectionView.deleteItems(at: [currentIndexPath])
                        } completion: { _ in
                            self.updateEmptyState()
                        }
                    } else {
                        collectionView.reloadData()
                        self.updateEmptyState()
                    }
                }
            }
        }
        
        cell.configure(with: movie)
        
        return cell
    }
}
