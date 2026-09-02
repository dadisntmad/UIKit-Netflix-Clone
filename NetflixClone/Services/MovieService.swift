import Foundation

protocol MovieServiceProtocol {
    func getMovies(for type: MovieType) async throws -> MovieResponse
    func getUpcomingMovies(page: Int) async throws -> MovieResponse
    func searchMovie(with query: String) async throws -> MovieResponse
}

final class MovieService: MovieServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    
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
    
    private func dataResponse(_ data: Data, _ res: URLResponse) throws -> MovieResponse {
        guard let httpRes = (res as? HTTPURLResponse) else {
            throw CustomError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpRes.statusCode) else {
            throw CustomError.httpError(statusCode: httpRes.statusCode)
        }
        
        return try JSONDecoder().decode(MovieResponse.self, from: data)
    }
}
