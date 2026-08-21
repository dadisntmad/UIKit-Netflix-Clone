import Foundation

protocol UserServiceProtocol {
    func getUser() async throws -> User
}

final class UserService: UserServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/account"
    private let keychainService: KeychainServiceProtocol
    private let session: URLSession
    
    init(keychainService: KeychainServiceProtocol, session: URLSession = .shared) {
        self.keychainService = keychainService
        self.session = session
    }
    
    func getUser() async throws -> User {
        guard let sessionId = await keychainService.load(forKey: AppConstants.sessionId) else {
            throw CustomError.noSessionId
        }
        
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "session_id", value: sessionId)
        ]
        
        guard let url = components?.url else { throw CustomError.invalidUrl }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(AppConfig.shared.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw CustomError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: data)
            await keychainService.save(String(user.id), forKey: AppConstants.accountId)
            return user
        } catch {
            throw CustomError.networkError(error)
        }
    }
}
