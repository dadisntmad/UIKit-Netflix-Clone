import Combine

@MainActor
final class HomeViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var randomMovie: Movie?
    @Published private(set) var nowPlayingMovies: [Movie] = []
    @Published private(set) var popularMovies: [Movie] = []
    @Published private(set) var topRatedMovies: [Movie] = []
    
    let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getMovies() async {
        status = .loading
        
        do {
            async let pendingNowPlayingMovies = movieService.getMovies(for: .nowPlaying)
            async let pendingPopularMovies = movieService.getMovies(for: .popular)
            async let pendingTopRatedMovies = movieService.getMovies(for: .topRated)
            
            let (nowPlaying, popular, topRated) = try await (
                pendingNowPlayingMovies,
                pendingPopularMovies,
                pendingTopRatedMovies
            )
            
            nowPlayingMovies = nowPlaying.results
            popularMovies = popular.results
            topRatedMovies = topRated.results
            randomMovie = topRated.results.randomElement()
            
            status = .success
        } catch  {
            status = .failure
        }
    }
}
