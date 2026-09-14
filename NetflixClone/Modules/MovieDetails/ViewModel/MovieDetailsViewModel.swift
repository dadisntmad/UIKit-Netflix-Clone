import Combine

final class MovieDetailsViewModel {
    @Published private(set) var status: Status = .initial
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getMovieDetails(id: Int) async {
        status = .loading
        
        do {
            try await movieService.getMovieDetails(for: id)
            status = .success
        } catch {
            status = .failure
        }
    }
}
