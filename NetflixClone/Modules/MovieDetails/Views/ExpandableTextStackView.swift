import UIKit

final class ExpandableTextStackView: UIStackView {
    private var isExpanded = false
    private let collapsedNumberOfLines: Int
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        return button
    }()
    
    init(collapsedNumberOfLines: Int = 3) {
        self.collapsedNumberOfLines = collapsedNumberOfLines
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .vertical
        spacing = 4
        alignment = .leading
        translatesAutoresizingMaskIntoConstraints = false
        
        addArrangedSubview(textLabel)
        addArrangedSubview(toggleButton)
    }
    
    func configure(prefixText: String, contentText: String) {
        let fullString = NSMutableAttributedString(
            string: "\(prefixText): ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        let bodyString = NSAttributedString(
            string: contentText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        fullString.append(bodyString)
        
        textLabel.attributedText = fullString
        
        // Explicitly collapse text to starting state
        isExpanded = false
        textLabel.numberOfLines = collapsedNumberOfLines
        updateButtonState()
        
        // Calculate whether truncation occurs to decide if button is needed
        let targetWidth = bounds.width > 0 ? bounds.width : (UIScreen.main.bounds.width - 32)
        let maxSize = CGSize(width: targetWidth, height: .greatestFiniteMagnitude)
        let textSize = fullString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil)
        let estimatedLines = Int(ceil(textSize.height / textLabel.font.lineHeight))
        
        toggleButton.isHidden = estimatedLines <= collapsedNumberOfLines
    }
    
    @objc private func didTapToggle() {
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.25) {
            self.textLabel.numberOfLines = self.isExpanded ? 0 : self.collapsedNumberOfLines
            self.updateButtonState()
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func updateButtonState() {
        let title = isExpanded ? "less" : "more"
        toggleButton.setTitle(title, for: .normal)
    }
}

// Helper extension to determine whether text truncates
private extension UILabel {
    var isTruncated: Bool {
        guard let text = text else { return false }
        let labelSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(
            with: labelSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font as Any],
            context: nil
        )
        return boundingRect.height > bounds.height
    }
}
