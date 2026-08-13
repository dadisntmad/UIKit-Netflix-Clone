import Foundation

enum AuthError: Error, LocalizedError {
    case invalidUrl
    case decodingError
    case httpError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl: return "Invalid server endpoint URL."
        case .decodingError: return "Failed to process response data."
        case .httpError(let code): return "HTTP Server error code: \(code)."
        case .networkError(let err): return err.localizedDescription
        }
    }
}

protocol AuthServiceProtocol {
    func signIn(username: String, password: String) async throws -> String
    func signOut(sessionId: String) async throws -> DeleteSessionResponse
}

final class AuthService: AuthServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/authentication"
    private let apiKey: String
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init(
        apiKey: String = AppConfig.shared.apiKey,
        session: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.apiKey = apiKey
        self.session = session
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    func signIn(username: String, password: String) async throws -> String {
        let tokenRes = try await createToken()
        let validatedToken = try await validateUser(
            username: username,
            password: password,
            requestToken: tokenRes.requestToken
        )
        let sessionRes = try await createSession(requestToken: validatedToken.requestToken)
        return sessionRes.sessionId
    }
    
    func signOut(sessionId: String) async throws -> DeleteSessionResponse {
        guard let url = URL(string: "\(baseUrl)/session?api_key=\(apiKey)") else {
            throw AuthError.invalidUrl
        }
        
        let body = DeleteSessionRequest(sessionId: sessionId)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(body)
        
        return try await performRequest(for: request)
    }
    
    // MARK: Helper functions
    private func createToken() async throws -> RequestTokenResponse {
        guard let url = URL(string: "\(baseUrl)/token/new?api_key=\(apiKey)") else {
            throw AuthError.invalidUrl
        }
        return try await performRequest(for: URLRequest(url: url))
    }
    
    private func validateUser(
        username: String,
        password: String,
        requestToken: String
    ) async throws -> RequestTokenResponse {
        guard let url = URL(string: "\(baseUrl)/token/validate_with_login?api_key=\(apiKey)") else {
            throw AuthError.invalidUrl
        }
        
        let body = SignInRequest(
            username: username,
            password: password,
            requestToken: requestToken
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(body)
        
        return try await performRequest(for: request)
    }
    
    private func createSession(requestToken: String) async throws -> SessionResponse {
        guard let url = URL(string: "\(baseUrl)/session/new?api_key=\(apiKey)") else {
            throw AuthError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(SessionRequest(requestToken: requestToken))
        
        return try await performRequest(for: request)
    }
    
    // MARK: - Generic Request Handler
    private func performRequest<T: Decodable>(for request: URLRequest) async throws -> T {
        let data: Data
        let res: URLResponse
        
        do {
            (data, res) = try await session.data(for: request)
        } catch {
            throw AuthError.networkError(error)
        }
        
        guard let httpRes = res as? HTTPURLResponse else {
            throw AuthError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpRes.statusCode) else {
            throw AuthError.httpError(statusCode: httpRes.statusCode)
        }
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw AuthError.decodingError
        }
    }
}
