import UIKit
import SDWebImage

final class HomeHeaderUIView: UIView {
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        return label
    }()
    
    private let playButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Play"
        config.image = UIImage(systemName: Icon.systemPlayFill)
        config.imagePadding = 8
        config.background.backgroundColor = .white
        config.baseForegroundColor = .black
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let addToListButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add to List"
        config.image = UIImage(systemName: Icon.systemPlus)
        config.imagePadding = 8
        config.background.backgroundColor = .systemGray3
        config.baseForegroundColor = .white
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, addToListButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addGradient()
        addSubview(movieLabel)
        addSubview(buttonStackView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        layer.addSublayer(gradientLayer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Movie label
            movieLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            movieLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Stack view
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with movie: Movie?) {
        guard let movie else { return }
        movieLabel.text = movie.title
        
        if let url = URL(string: movie.moviePosterPath) {
            imageView.sd_setImage(with: url, completed: nil)
        }
    }
}
