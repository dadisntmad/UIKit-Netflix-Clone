import Combine

@MainActor
final class FavoritesViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var favoriteMovies: [Movie] = []
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getFavoriteMovies() async {
        status = .loading
        
        do {
            let res = try await movieService.getFavoriteMovies()
            favoriteMovies = res.results
            status = .success
        } catch {
            status = .failure
        }
    }
    
    func unmarkMovieAsFavorite(for id: Int) async {
        status = .loading
        
        do {
            try await movieService.markAsFavorite(for: id, isFavorite: false)
            favoriteMovies.removeAll { $0.id == id }
            status = .success
        } catch {
            status = .failure
        }
    }
}
