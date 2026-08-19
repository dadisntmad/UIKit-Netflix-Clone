import Combine

@MainActor
final class HomeViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var nowPlayingMovies: [Movie] = []
    
    let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getMovies() async {
        status = .loading
        
        do {
            let res = try await movieService.getMovies()
            nowPlayingMovies = res.results
            status = .success
        } catch  {
            status = .failure
        }
    }
}
