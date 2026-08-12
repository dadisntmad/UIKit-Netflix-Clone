import UIKit

final class AuthViewController: UIViewController {
    private enum Constants {
        static let fieldHeight: CGFloat = 50
        static let logoWidth: CGFloat = 120
        static let logoHeight: CGFloat = 30
    }
    
    private let logoView: UIImageView = {
        let image = UIImage(named: "logo")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let usernameTextField = TextField(hintText: "Username")
    private let passwordTextField = TextField(hintText: "Password", isSecure: true)
    
    private let signInButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .accentRed
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, signInButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = AppConstants.spacing
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .secondaryBackground
        navigationItem.titleView = logoView
        configureNavigationBar()
        view.addSubview(stackView)
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .primaryBackground
        // Removes the bottom border line
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Logo Dimensions
            logoView.widthAnchor.constraint(equalToConstant: Constants.logoWidth),
            logoView.heightAnchor.constraint(equalToConstant: Constants.logoHeight),
            
            // Stack
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: AppConstants.spacing),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -AppConstants.spacing),
            
            // View heights
            usernameTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            passwordTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            signInButton.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
        ])
    }
}

