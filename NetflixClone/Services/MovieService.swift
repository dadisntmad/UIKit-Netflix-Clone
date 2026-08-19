import Foundation

protocol MovieServiceProtocol {
    func getMovies() async throws -> MovieResponse
}

final class MovieService: MovieServiceProtocol {
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    
    func getMovies() async throws -> MovieResponse {
        guard let url = URL(string: "\(baseUrl)/top_rated?api_key=\(AppConfig.shared.apiKey)") else {
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
}
