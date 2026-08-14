import UIKit
import Combine

final class TextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // Custom publisher that emits whenever the user types
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
    
    init(hintText: String, isSecure: Bool = false, autocapitalization: UITextAutocapitalizationType = .none) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        placeholder = hintText
        layer.cornerRadius = 8
        backgroundColor = .accentGrey
        isSecureTextEntry = isSecure
        autocapitalizationType = autocapitalization
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
