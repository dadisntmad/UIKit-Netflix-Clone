import UIKit

final class MovieDetailsViewController: UIViewController {
    var onDismiss: (() -> Void)?
    
    private let movie: Movie
    
    private let castSectionView = ExpandableTextStackView(collapsedNumberOfLines: 1)
    private let directorSectionView = ExpandableTextStackView(collapsedNumberOfLines: 1)
    private let actionButtonsView = MovieActionButtonsView()
    
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
    
    private let videoPlaceholder: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .systemGray
        return uiView
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.text = "Legend"
        return label
    }()
    
    private let movieSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.text = "2015 Crime · Thriller"
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
        label.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian at St Bride Printing Library in London, took a 1914 Cicero translation and scrambled it to make dummy text for Letraset's Body Type sheets. It has survived not only many decades, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised thanks to these sheets and more recently with desktop publishing software like Aldus PageMaker and Microsoft Word including versions of Lorem Ipsum."
        return label
    }()
    
    init(movie: Movie) {
        self.movie = movie
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
        configureData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            onDismiss?()
        }
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            videoPlaceholder,
            movieLabel,
            movieSubtitleLabel,
            playButton,
            downloadButton,
            movieOverview,
            castSectionView,
            directorSectionView,
            actionButtonsView
        ].forEach { contentView.addSubview($0) }
        
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
            videoPlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoPlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoPlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoPlaceholder.heightAnchor.constraint(equalToConstant: 250),
            
            // Movie label
            movieLabel.topAnchor.constraint(equalTo: videoPlaceholder.bottomAnchor, constant: 16),
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
            
            actionButtonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func configureData() {
        castSectionView.configure(
            prefixText: "Cast",
            contentText: "Tom Hardy, Emily Browning, Christopher Eccleston, David Thewlis, Taron Egerton, Chazz Palminteri, Colin Morgan, Paul Bettany..."
        )
        
        directorSectionView.configure(
            prefixText: "Director",
            contentText: "Brian Helgeland, Quentin Tarantino, Martin Scorsese, Christopher Nolan"
        )
    }
}
