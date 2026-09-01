import UIKit
import SDWebImage

final class SearchViewCell: UITableViewCell {
    static let identifier = "SearchViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        let image = UIImage(systemName: "play.circle", withConfiguration: imageConfig)
        btn.setImage(image, for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(movieLabel)
        contentView.addSubview(playButton)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for movie: Movie) {
        //        if movie.backdropPath?.isEmpty ?? false {
        //            return
        //        }
        posterImageView.sd_setImage(with: URL(string: movie.backdropPath ?? ""), completed: nil)
        movieLabel.text = movie.title
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Poster image
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            posterImageView.widthAnchor.constraint(equalToConstant: 180),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Movie title
            movieLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            movieLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -12),
            movieLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Play button
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 36),
            playButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}
