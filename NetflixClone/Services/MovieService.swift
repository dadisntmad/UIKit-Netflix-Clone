import Foundation

protocol MovieServiceProtocol {
    func getMovies(for type: MovieType) async throws -> MovieResponse
    func getUpcomingMovies() async throws -> MovieResponse
}

final class MovieService: MovieServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    
    func getMovies(for type: MovieType) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseUrl)/\(type.endpoint)?api_key=\(AppConfig.shared.apiKey)") else {
            throw CustomError.invalidUrl
        }
        
        let request = URLRequest(url: url)
        
        let (data, res) = try await URLSession.shared.data(for: request)
        
        guard let httpRes = (res as? HTTPURLResponse) else {
            throw CustomError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpRes.statusCode) else {
            throw CustomError.httpError(statusCode: httpRes.statusCode)
        }
        
        return try JSONDecoder().decode(MovieResponse.self, from: data)
    }
    
    func getUpcomingMovies() async throws -> MovieResponse {
        guard var components = URLComponents(string: "\(baseUrl)/upcoming") else {
            throw CustomError.invalidUrl
        }
        
        components.queryItems = [
            URLQueryItem(name: "api_key", value: AppConfig.shared.apiKey)
        ]
        
        guard let url = components.url else {
            throw CustomError.invalidUrl
        }
        
        let (data, res) = try await URLSession.shared.data(from: url)
        
        guard let httpRes = res as? HTTPURLResponse else {
            throw CustomError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpRes.statusCode) else {
            throw CustomError.httpError(statusCode: httpRes.statusCode)
        }
        
        return try JSONDecoder().decode(MovieResponse.self, from: data)
    }
}
