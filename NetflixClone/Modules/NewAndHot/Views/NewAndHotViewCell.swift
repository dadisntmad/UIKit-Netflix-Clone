import UIKit
import SDWebImage

final class NewAndHotViewCell: UITableViewCell {
    static let identifier = "NewAndHotViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = "Oct"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "01"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationsBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: Icon.systemBell), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    private let infoBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: Icon.systemInfo), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    private lazy var movieDateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthLabel, dayLabel])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4
        return stack
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [notificationsBtn, infoBtn])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var movieInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [movieLabel, buttonsStack])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .top
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(movieDateStack)
        contentView.addSubview(movieInfoStack)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for movie: Movie) {
        guard let backdropPath = movie.backdropPath,
              let url = URL(string: backdropPath) else { return }
        posterImageView.sd_setImage(with: url, completed: nil)
        movieLabel.text = movie.title
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Poster image view
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Movie date stack
            movieDateStack.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            movieDateStack.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            
            // Movie info stack
            movieInfoStack.topAnchor.constraint(equalTo: movieDateStack.bottomAnchor, constant: 8),
            movieInfoStack.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            movieInfoStack.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -16),
            movieInfoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // Specific button constraints
            notificationsBtn.widthAnchor.constraint(equalToConstant: 24),
            notificationsBtn.heightAnchor.constraint(equalToConstant: 24),
            infoBtn.widthAnchor.constraint(equalToConstant: 24),
            infoBtn.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
