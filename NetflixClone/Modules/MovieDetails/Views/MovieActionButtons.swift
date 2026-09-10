import UIKit

final class MovieActionButtonsView: UIStackView {
    
    var onMyListTapped: (() -> Void)?
    var onRateTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    
    private lazy var myListButton: UIButton = makeActionButton(
        title: "My List",
        systemImageName: Icon.systemPlus
    )
    
    private lazy var rateButton: UIButton = makeActionButton(
        title: "Rate",
        systemImageName: Icon.systemThumbsUp
    )
    
    private lazy var shareButton: UIButton = makeActionButton(
        title: "Share",
        systemImageName: Icon.systemShare
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .horizontal
        alignment = .leading
        translatesAutoresizingMaskIntoConstraints = false
        
        addArrangedSubview(myListButton)
        addArrangedSubview(rateButton)
        addArrangedSubview(shareButton)
        
        myListButton.addTarget(self, action: #selector(didTapMyList), for: .touchUpInside)
        rateButton.addTarget(self, action: #selector(didTapRate), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    private func makeActionButton(title: String, systemImageName: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        config.image = UIImage(systemName: systemImageName, withConfiguration: imageConfig)
        config.imagePlacement = .top
        config.imagePadding = 16
        
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ])
        )
        
        config.baseForegroundColor = .label
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func didTapMyList() { onMyListTapped?() }
    @objc private func didTapRate() { onRateTapped?() }
    @objc private func didTapShare() { onShareTapped?() }
}
