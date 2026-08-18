import UIKit

final class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(
            HomeCollectionViewTableViewCell.self,
            forCellReuseIdentifier: HomeCollectionViewTableViewCell.identifier
        )
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = HomeHeaderUIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 450))
        setupUsername()
        setupActionButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCollectionViewTableViewCell.identifier, for: indexPath) as? HomeCollectionViewTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
}

