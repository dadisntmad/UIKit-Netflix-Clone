import Foundation

protocol MovieServiceProtocol {
    func getMovies(for type: MovieType) async throws -> MovieResponse
    func getUpcomingMovies(page: Int) async throws -> MovieResponse
    func searchMovie(with query: String) async throws -> MovieResponse
    func getMovieDetails(for id: Int) async throws -> MovieDetails
    func getMovieCredits(for id: Int) async throws -> Credits
    func getSimilarMovies(for id: Int) async throws -> MovieResponse
    func markAsFavorite(for id: Int, isFavorite: Bool) async throws
    func checkFavoriteMovie(for id: Int) async throws -> AccountStates
}

final class MovieService: MovieServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    private let accountBaseUrl = "https://api.themoviedb.org/3/account"
    
    private let keychainService: KeychainServiceProtocol
    
    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
    }
    
    func getMovies(for type: MovieType) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseUrl)/\(type.endpoint)?api_key=\(AppConfig.shared.apiKey)") else {
            throw CustomError.invalidUrl
        }
        
        let request = URLRequest(url: url)
        
        let (data, res) = try await URLSession.shared.data(for: request)
        
        return try dataResponse(data, res)
    }
    
    func getUpcomingMovies(page: Int) async throws -> MovieResponse {
        guard var components = URLComponents(string: "\(baseUrl)/upcoming") else {
            throw CustomError.invalidUrl
        }
        
        components.queryItems = [
            URLQueryItem(name: "api_key", value: AppConfig.shared.apiKey),
            URLQueryItem(name: "page", value: String(page)),
        ]
        
        guard let url = components.url else {
            throw CustomError.invalidUrl
        }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        
        return try dataResponse(data, res)
    }
    
    func searchMovie(with query: String) async throws -> MovieResponse {
        guard var components = URLComponents(string: "https://api.themoviedb.org/3/search/movie") else {
            throw CustomError.invalidUrl
        }
        
        components.queryItems = [
            URLQueryItem(name: "api_key", value: AppConfig.shared.apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let url = components.url else {
            throw CustomError.invalidUrl
        }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        return try dataResponse(data, res)
    }
    
    func getMovieDetails(for id: Int) async throws -> MovieDetails {
        guard let url = URL(string: "\(baseUrl)/\(id)?append_to_response=videos&language=en-US&api_key=\(AppConfig.shared.apiKey)") else { throw CustomError.invalidUrl }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        
        do {
            return try dataResponse(data, res)
        } catch {
            throw CustomError.networkError(error)
        }
    }
    
    func getMovieCredits(for id: Int) async throws -> Credits {
        guard let url = URL(string: "\(baseUrl)/\(id)/credits?api_key=\(AppConfig.shared.apiKey)") else { throw CustomError.invalidUrl }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        
        do {
            return try dataResponse(data, res)
        } catch {
            throw CustomError.networkError(error)
        }
    }
    
    func getSimilarMovies(for id: Int) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseUrl)/\(id)/similar?api_key=\(AppConfig.shared.apiKey)") else { throw CustomError.invalidUrl }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        
        do {
            return try dataResponse(data, res)
        } catch {
            throw CustomError.networkError(error)
        }
    }
    
    func markAsFavorite(for id: Int, isFavorite: Bool) async throws {
        guard let sessionId = await keychainService.load(forKey: AppConstants.sessionId) else {
            throw CustomError.noSessionId
        }
        
        guard let accountId = await keychainService.load(forKey: AppConstants.accountId) else {
            throw CustomError.noAccountId
        }
        
        let urlString = "\(accountBaseUrl)/\(accountId)/favorite?api_key=\(AppConfig.shared.apiKey)&session_id=\(sessionId)"
        
        guard let url = URL(string: urlString) else {
            throw CustomError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "media_type": "movie",
            "media_id": id,
            "favorite": isFavorite
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            debugPrint("HTTP Status Code: \(httpResponse.statusCode)")
        }
        debugPrint("Response Body: \(String(data: data, encoding: .utf8) ?? "No data")")
    }
    
    func checkFavoriteMovie(for id: Int) async throws -> AccountStates {
        guard let sessionId = await keychainService.load(forKey: AppConstants.sessionId) else {
            throw CustomError.noSessionId
        }
        
        guard let url = URL(string: "\(baseUrl)/\(id)/account_states?session_id=\(sessionId)&api_key=\(AppConfig.shared.apiKey)") else {
            throw CustomError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        do {
            return try dataResponse(data, response)
        } catch {
            throw CustomError.networkError(error)
        }
    }
    
    // MARK: Helpers
    private func dataResponse<T: Decodable>(_ data: Data, _ res: URLResponse) throws -> T {
        guard let httpRes = (res as? HTTPURLResponse) else {
            throw CustomError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpRes.statusCode) else {
            throw CustomError.httpError(statusCode: httpRes.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
