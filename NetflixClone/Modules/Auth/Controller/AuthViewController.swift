import UIKit
import Combine

final class AuthViewController: UIViewController {
    private let viewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private enum Constants {
        static let fieldHeight: CGFloat = 50
        static let logoWidth: CGFloat = 120
        static let logoHeight: CGFloat = 30
    }
    
    private let logoView: UIImageView = {
        let image = UIImage(named: Icon.logo)
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let usernameTextField = TextField(hintText: "Username")
    private let passwordTextField = TextField(hintText: "Password", isSecure: true)
    
    private lazy var signInButton: UIButton = {
        let btn = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in
            self?.signIn()
        })
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .accentRed
        btn.tintColor = .white
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
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Update value in ViewModel during text entering
        usernameTextField.textPublisher
            .sink { [weak viewModel] text in
                viewModel?.username = text
            }
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .sink { [weak viewModel] text in
                viewModel?.password = text
            }
            .store(in: &cancellables)
        
        // Subscribing to ViewModel state changes
        viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .loading {
                    self?.activityIndicator.startAnimating()
                    self?.signInButton.isEnabled = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.signInButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .secondaryBackground
        navigationItem.titleView = logoView
        configureNavigationBar()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
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
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow // Allows expanding when content or keyboard forces it taller
        
        NSLayoutConstraint.activate([
            // ScrollView fills safe area
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            // ContentView pins to contentLayoutGuide (defines scroll content size)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // ContentView matches frameLayoutGuide height (minimum screen height) and width
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentViewHeightConstraint,
            
            // StackView centered inside ContentView
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppConstants.spacing),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppConstants.spacing),
            
            // Top and bottom safety padding so stack content doesn't break out when oversized
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: AppConstants.spacing),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -AppConstants.spacing),
            
            // Heights
            logoView.widthAnchor.constraint(equalToConstant: Constants.logoWidth),
            logoView.heightAnchor.constraint(equalToConstant: Constants.logoHeight),
            usernameTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            passwordTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            signInButton.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
        ])
    }
    
    func signIn() {
        Task {
            await viewModel.signIn()
        }
    }
}

