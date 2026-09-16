import UIKit
import SDWebImage

final class SimilarMovieTableViewCell: UITableViewCell {
    static let identifier = "SimilarMovieTableViewCell"
    
    var onDownloadTapped: (() -> Void)?
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var downloadButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        config.image = UIImage(systemName: Icon.systemDownSquare, withConfiguration: imageConfig)
        config.baseForegroundColor = .label
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapDownload), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            posterImageView.widthAnchor.constraint(equalToConstant: 130),
            posterImageView.heightAnchor.constraint(equalToConstant: 75),
            
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 44),
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        posterImageView.sd_setImage(with: URL(string: movie.movieBackdropPath))
    }
    
    @objc private func didTapDownload() {
        onDownloadTapped?()
    }
}
