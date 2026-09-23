import UIKit
import SDWebImage

final class FavoriteCollectionViewCell: UICollectionViewCell {
    static let identifier = "FavoriteCollectionViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let likeButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .accentRed
        configuration.contentInsets = .zero
        configuration.image = UIImage(systemName: Icon.systemHeartFill)
        let btn = UIButton(configuration: configuration)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentHorizontalAlignment = .leading
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movie: Movie) {
        posterImageView.sd_setImage(with: URL(string: movie.moviePosterPath), completed: nil)
        movieLabel.text = movie.title
    }
    
    private func setupConstraints() {
        [posterImageView, movieLabel, likeButton].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            // Poster Image
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.4),
            
            // Movie Title Label
            movieLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            movieLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            // Like / Dislike Button
            likeButton.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 4),
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
