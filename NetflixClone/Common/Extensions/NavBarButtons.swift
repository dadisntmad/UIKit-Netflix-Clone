import UIKit

extension UIViewController {
    func setupActionButtons(didTapProfileButton: Selector, didTapSearchButton: Selector) {
        let tvBtn = UIButton(type: .system)
        tvBtn.setImage(UIImage(systemName: Icon.systemTVFill), for: .normal)
        
        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(UIImage(named: Icon.search), for: .normal)
        searchBtn.addTarget(self, action: didTapSearchButton, for: .touchUpInside)
        
        let profileBtn = UIButton(type: .custom)
        profileBtn.addTarget(self, action: didTapProfileButton, for: .touchUpInside)
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
