import UIKit
import Combine

final class SearchViewController: UIViewController {
    var onDidDisappear: (() -> Void)?
    
    private let searchViewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let emptyView = EmptyView()
    
    init(searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchController()
        setupViews()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed  {
            onDidDisappear?()
        }
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.backgroundView = emptyView
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        // Observe movies update to reload table view
        searchViewModel.$movies
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        searchViewModel.$status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .loading:
                    self.spinner.startAnimating()
                    self.emptyView.isHidden = true
                    
                case .success, .failure, .initial:
                    self.spinner.stopAnimating()
                    self.updateEmptyState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let query = searchViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = searchViewModel.movies.isEmpty
        let isLoading = searchViewModel.status == .loading
        
        guard !isLoading else {
            emptyView.isHidden = true
            return
        }
        
        if isEmpty {
            emptyView.isHidden = false
            if query.isEmpty {
                // emptyView state before typing
                emptyView.setMessage("Search for movies")
            } else {
                // Search finished with zero results
                emptyView.setMessage("No movies found for \"\(query)\"")
            }
        } else {
            emptyView.isHidden = true
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchViewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell else {
            return UITableViewCell()
        }
        
        let movie = searchViewModel.movies[indexPath.row]
        
        cell.configure(for: movie)
        
        return cell
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchViewModel.searchText = searchController.searchBar.text ?? ""
    }
}
