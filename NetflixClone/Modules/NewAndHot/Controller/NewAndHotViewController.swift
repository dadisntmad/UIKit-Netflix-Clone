import UIKit

final class NewAndHotViewController: UIViewController {
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
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitle()
        setupActionButtons(didTapProfileButton: #selector(didTapProfileButton))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @objc private func didTapProfileButton() {}
}

extension NewAndHotViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewAndHotViewCell.identifier, for: indexPath) as? NewAndHotViewCell else {
            return UITableViewCell()
        }
        
        let movie = Movie(
            id: 123,
            title: "Spider-Man: Brand New Day",
            voteAverage: 8.5,
            backdropPath: "https://sm.ign.com/t/ign_br/video/s/spider-man/spider-man-brand-new-day-official-day-one-on-set-featurette_56gk.1280.jpg",
            genreIds: nil,
            overview: nil,
            posterPath: nil,
            releaseDate: nil
        )
        
        cell.configure(for: movie)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        260
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        100
    }
}
