import Combine

@MainActor
final class NewAndHotViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var movies: [Movie] = []
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getUpcomingMovies() async {
        status = .loading
        
        do {
            let res = try await movieService.getUpcomingMovies()
            movies = res.results
            status = .success
        } catch {
            status = .failure
            movies = []
        }
    }
}
