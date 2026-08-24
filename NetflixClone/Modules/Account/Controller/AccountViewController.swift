import UIKit

final class AccountViewController: UIViewController {
    var onDismiss: (() -> Void)?
    
    private var profileBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: Icon.profileImage)?.withRenderingMode(.alwaysOriginal)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    private var addProfileBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = Palette.accentGrey?.cgColor
        btn.setImage(UIImage(systemName: Icon.systemPlus), for: .normal)
        btn.tintColor = Palette.accentGrey
        return btn
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileBtn, addProfileBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 24
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let addProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Profile"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let manageProfilesBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: Icon.systemEdit)
        config.title = "Manage Profiles"
        config.imagePadding = 8
        config.baseForegroundColor = .secondaryLabel
        
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return btn
    }()
    
    // MARK: - Stacks
    private lazy var profileContainerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileBtn, profileLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var addProfileContainerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [addProfileBtn, addProfileLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var mainButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileContainerStack, addProfileContainerStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.alignment = .top
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "username"
        setupConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            onDismiss?()
        }
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        [mainButtonsStack, manageProfilesBtn].forEach({ view.addSubview($0) })
        
        NSLayoutConstraint.activate([
            // Set explicit sizes for the buttons
            profileBtn.widthAnchor.constraint(equalToConstant: 70),
            profileBtn.heightAnchor.constraint(equalToConstant: 70),
            
            addProfileBtn.widthAnchor.constraint(equalToConstant: 70),
            addProfileBtn.heightAnchor.constraint(equalToConstant: 70),
            
            // Position the outer main stack
            mainButtonsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Manage profiles button
            manageProfilesBtn.topAnchor.constraint(equalTo: mainButtonsStack.bottomAnchor, constant: 20),
            manageProfilesBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
