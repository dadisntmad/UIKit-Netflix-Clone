import UIKit
import Combine

final class NewAndHotViewController: UIViewController {
    private let newAndHotViewModel: NewAndHotViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.text = "New & Hot"
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(NewAndHotViewCell.self, forCellReuseIdentifier: NewAndHotViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    init(newAndHotViewModel: NewAndHotViewModel) {
        self.newAndHotViewModel = newAndHotViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitle()
        setupActionButtons(didTapProfileButton: #selector(didTapProfileButton))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        getUpcomingMovies()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupTitle() {
        let btn = UIBarButtonItem(customView: titleLabel)
        btn.hidesSharedBackground = true
        navigationItem.leftBarButtonItem = btn
    }
    
    private func getUpcomingMovies() {
        Task {
            await newAndHotViewModel.getUpcomingMovies()
        }
    }
    
    private func bindViewModel() {
        newAndHotViewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapProfileButton() {}
}

extension NewAndHotViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        newAndHotViewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewAndHotViewCell.identifier, for: indexPath) as? NewAndHotViewCell else {
            return UITableViewCell()
        }
        
        let movie = newAndHotViewModel.movies[indexPath.section]
        
        cell.configure(for: movie)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        260
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let needsFetch = indexPaths.contains { $0.section >= newAndHotViewModel.movies.count - 3 }
        if needsFetch {
            getUpcomingMovies()
        }
    }
}
