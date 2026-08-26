import Combine

@MainActor
final class AuthViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var isAuthenticated = false
    
    var username = ""
    var password = ""
    
    private let authService: AuthServiceProtocol
    private let keychainService: KeychainServiceProtocol
    
    init(
        authService: AuthServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.authService = authService
        self.keychainService = keychainService
    }
    
    func signIn() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        
        status = .loading
        
        do {
            let sessionId = try await authService.signIn(
                username: username,
                password: password
            )
            
            await keychainService.save(sessionId, forKey: AppConstants.sessionId)
            
            status = .success
            isAuthenticated = true
        } catch {
            status = .failure
            isAuthenticated = false
        }
    }
}
