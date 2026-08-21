import Foundation
import Combine

@MainActor
final class AccountViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var errorMessage: String?
    @Published private(set) var status: Status = .initial
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func getUser() async {
        status = .loading
        errorMessage = nil
        
        do {
            user = try await userService.getUser()
            status = .success
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
