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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondaryBackground
        navigationItem.titleView = logoView
        setupLogoConstraints()
        configureNavigationBar()
        setupTextFieldsContraints()
        setupButtonConstraints()
    }
    
    private func setupLogoConstraints() {
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: Constants.logoWidth),
            logoView.heightAnchor.constraint(equalToConstant: Constants.logoHeight)
        ])
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
    
    private func setupTextFieldsContraints() {
        [usernameTextField, passwordTextField].forEach { item in
            view.addSubview(item)
        }
        
        NSLayoutConstraint.activate([
            // Username text field
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.spacing),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.spacing),
            usernameTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            // Password text field
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: AppConstants.spacing),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.spacing),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.spacing),
            passwordTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
        ])
    }
    
    private func setupButtonConstraints() {
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: AppConstants.spacing),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.spacing),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.spacing),
            signInButton.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
        ])
    }
}

