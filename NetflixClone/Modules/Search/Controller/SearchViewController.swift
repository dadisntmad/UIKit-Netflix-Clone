import UIKit

final class SearchViewController: UIViewController {
    var onDidDisappear: (() -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
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
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell else {
            return UITableViewCell()
        }
        
        let movie = Movie(
            id: 123,
            title: "Legend",
            voteAverage: 8.5,
            backdropPath: "https://images4.alphacoders.com/806/thumb-1920-806396.jpg",
            genreIds: nil,
            overview: nil,
            posterPath: nil,
            releaseDate: nil
        )
        
        cell.configure(for: movie)
        
        return cell
    }
}
