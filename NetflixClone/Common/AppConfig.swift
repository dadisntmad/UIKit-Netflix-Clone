import Foundation

final class AppConfig {
    static let shared = AppConfig()
    
    private init() {}
    
    var apiKey: String { self.getValue(for: AppConstants.apiKey) }
    var accessToken: String { self.getValue(for: AppConstants.accessToken) }
    
    private func getValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return "Default value for: \(key)"
        }
        return value
    }
}
