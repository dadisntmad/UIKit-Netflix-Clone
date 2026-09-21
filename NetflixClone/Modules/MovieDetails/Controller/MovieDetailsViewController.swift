import UIKit
import Combine
import YouTubePlayerKit

final class MovieDetailsViewController: UIViewController {
    private var playerViewController: YouTubePlayerViewController?
    
    var onDismiss: (() -> Void)?
    
    private let movieId: Int
    private var similarMovies: [Movie] = []
    private var youtubeVideoId: String?
    private let movieDetailsViewModel: MovieDetailsViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let castSectionView = ExpandableTextStackView(collapsedNumberOfLines: 1)
    private let directorSectionView = ExpandableTextStackView(collapsedNumberOfLines: 1)
    private let actionButtonsView = MovieActionButtonsView(frame: .zero)
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let sectionHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "More Like This"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false // Main UIScrollView handles scrolling
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(SimilarMovieTableViewCell.self, forCellReuseIdentifier: SimilarMovieTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let movieSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let playButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: Icon.systemPlayFill)
        configuration.title = "Play"
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.imagePadding = 8
        let btn = UIButton(configuration: configuration)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let downloadButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: Icon.systemArrowDownCircle)
        configuration.title = "Download"
        configuration.baseBackgroundColor = .systemGray4
        configuration.baseForegroundColor = .label
        configuration.imagePadding = 8
        let btn = UIButton(configuration: configuration)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let movieOverview: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    init(movieId: Int, movieDetailsViewModel: MovieDetailsViewModel) {
        self.movieId = movieId
        self.movieDetailsViewModel = movieDetailsViewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        getMovieDetails()
        bindViewModel()
        handleMovieActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            onDismiss?()
        }
    }
    
    private func bindViewModel() {
        movieDetailsViewModel.$movie
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movieDetails in
                guard let self = self else { return }
                self.movieLabel.text = movieDetails.title
                self.movieSubtitleLabel.text = "\(movieDetails.movieYear) \(movieDetails.movieGenre)"
                self.movieOverview.text = movieDetails.overview
                
                if let videoKey = movieDetails.youtubeVideos.first?.key, !videoKey.isEmpty {
                    self.loadYoutubePlayer(videoId: videoKey)
                }
            }
            .store(in: &cancellables)
        
        movieDetailsViewModel.$credits
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] credits in
                guard let self = self else { return }
                
                self.castSectionView.configure(
                    prefixText: "Cast",
                    contentText: credits.cast.map(\.name).joined(separator: ", ")
                )
                
                self.directorSectionView.configure(
                    prefixText: "Director",
                    contentText: credits.crew.first(where: { $0.job == "Director" })?.name ?? ""
                )
            }
            .store(in: &cancellables)
        
        movieDetailsViewModel.$similarMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] similarMovies in
                guard let self = self else { return }
                self.similarMovies = similarMovies
                self.tableView.reloadData()
                
                // Re-evaluate table height constraint and schedule layout for next frame
                self.tableViewHeightConstraint?.constant = self.tableView.contentSize.height
                self.view.setNeedsLayout()
            }
            .store(in: &cancellables)
        
        movieDetailsViewModel.$isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                guard let self = self else { return }
                self.actionButtonsView.isFavorite = isFavorite
            }
            .store(in: &cancellables)
    }
    
    private func getMovieDetails() {
        Task {
            await movieDetailsViewModel.fetchAllData(id: movieId)
        }
    }
    
    private func loadYoutubePlayer(videoId: String) {
        // If player already exists, reload with the new video ID
        guard playerViewController == nil else {
            Task {
                try? await playerViewController?.player.load(source: .video(id: videoId))
            }
            return
        }
        
        let player = YouTubePlayer(
            source: .video(id: videoId),
            parameters: .init(
                autoPlay: false,
                showControls: true,
            ),
            configuration: .init(
                fullscreenMode: .system,
            )
        )
        
        let playerVC = YouTubePlayerViewController(player: player)
        
        addChild(playerVC)
        playerContainerView.addSubview(playerVC.view)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerVC.view.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerVC.view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerVC.view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerVC.view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor)
        ])
        
        playerVC.didMove(toParent: self)
        self.playerViewController = playerVC
    }
    
    private func handleMovieActions() {
        actionButtonsView.onMyListTapped = { [weak self] in
            guard let self = self else { return }
            Task {
                await self.movieDetailsViewModel.markMovieAsFavorite(id: self.movieId)
            }
        }
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            playerContainerView,
            movieLabel,
            movieSubtitleLabel,
            playButton,
            downloadButton,
            movieOverview,
            castSectionView,
            directorSectionView,
            actionButtonsView,
            sectionHeaderLabel,
            tableView
        ].forEach { contentView.addSubview($0) }
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Match ContentView width to FrameLayoutGuide to restrict scrolling to vertical only
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Video player
            playerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playerContainerView.heightAnchor.constraint(equalToConstant: 250),
            
            // Movie label
            movieLabel.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 16),
            movieLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Movie Subtitle label
            movieSubtitleLabel.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 8),
            movieSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Play button
            playButton.topAnchor.constraint(equalTo: movieSubtitleLabel.bottomAnchor, constant: 16),
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Download button
            downloadButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 8),
            downloadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Movie overview label
            movieOverview.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 16),
            movieOverview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieOverview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Cast
            castSectionView.topAnchor.constraint(equalTo: movieOverview.bottomAnchor, constant: 16),
            castSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            castSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Director
            directorSectionView.topAnchor.constraint(equalTo: castSectionView.bottomAnchor, constant: 12),
            directorSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            directorSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Action buttons
            actionButtonsView.topAnchor.constraint(equalTo: directorSectionView.bottomAnchor, constant: 16),
            actionButtonsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 60),
            
            // More like this movies label
            sectionHeaderLabel.topAnchor.constraint(equalTo: actionButtonsView.bottomAnchor, constant: 24),
            sectionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sectionHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: sectionHeaderLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            tableViewHeightConstraint!
        ])
    }
}

extension MovieDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        similarMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimilarMovieTableViewCell.identifier, for: indexPath) as? SimilarMovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = similarMovies[indexPath.row]
        cell.configure(with: movie)
        cell.onDownloadTapped = {}
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        87
    }
}
