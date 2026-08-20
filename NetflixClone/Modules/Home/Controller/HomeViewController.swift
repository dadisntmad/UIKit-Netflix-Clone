import UIKit
import Combine

final class HomeViewController: UIViewController {
    enum Sections: Int, CaseIterable {
        case nowPlaying = 0
        case popular = 1
        case topRated = 2
        
        var title: String {
            switch self {
            case .nowPlaying: return "Now Playing"
            case .popular: return "Popular"
            case .topRated: return "Top Rated"
            }
        }
    }
    
    private let homeViewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(
            HomeCollectionViewTableViewCell.self,
            forCellReuseIdentifier: HomeCollectionViewTableViewCell.identifier
        )
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private var headerView: HomeHeaderUIView?
    
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        headerView = HomeHeaderUIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 450))
        tableView.tableHeaderView = headerView
        setupUsername()
        setupActionButtons()
        bindViewModel()
        fetchMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func bindViewModel() {
        homeViewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .initial:
                    break
                case .loading:
                    break
                case .success:
                    self.headerView?.configure(with: self.homeViewModel.randomMovie)
                    self.tableView.reloadData()
                case .failure:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchMovies() {
        Task {
            await homeViewModel.getMovies()
        }
    }
    
    private func setupUsername() {
        let titleLabel = UILabel()
        titleLabel.text = "For username"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let btn = UIBarButtonItem(customView: titleLabel)
        btn.hidesSharedBackground = true
        navigationItem.leftBarButtonItem = btn
    }
    
    private func setupActionButtons() {
        let tvBtn = UIButton(type: .system)
        tvBtn.setImage(UIImage(systemName: Icon.systemTVFill), for: .normal)
        
        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(UIImage(named: Icon.search), for: .normal)
        
        let profileBtn = UIButton(type: .custom)
        if let profileImage = UIImage(named: Icon.profileImage)?.withRenderingMode(.alwaysOriginal) {
            profileBtn.setImage(profileImage, for: .normal)
        }
        
        [tvBtn, searchBtn, profileBtn].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .white
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 28),
                button.heightAnchor.constraint(equalToConstant: 28)
            ])
        }
        
        let stack = UIStackView(arrangedSubviews: [tvBtn, searchBtn, profileBtn])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.alignment = .center
        
        let btn = UIBarButtonItem(customView: stack)
        btn.hidesSharedBackground = true
        navigationItem.rightBarButtonItem = btn
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCollectionViewTableViewCell.identifier, for: indexPath) as? HomeCollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        guard let sectionType = Sections(rawValue: indexPath.section) else { return cell }
        
        switch sectionType {
        case .nowPlaying:
            cell.configure(with: homeViewModel.nowPlayingMovies)
        case .popular:
            cell.configure(with: homeViewModel.popularMovies)
        case .topRated:
            cell.configure(with: homeViewModel.topRatedMovies)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        let textLabel = header.textLabel
        textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Sections(rawValue: section)?.title
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

