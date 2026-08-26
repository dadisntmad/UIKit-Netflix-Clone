import Combine

@MainActor
final class HomeViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var randomMovie: Movie?
    @Published private(set) var nowPlayingMovies: [Movie] = []
    @Published private(set) var popularMovies: [Movie] = []
    @Published private(set) var topRatedMovies: [Movie] = []
    @Published private(set) var username: String?
    
    let movieService: MovieServiceProtocol
    let userService: UserServiceProtocol
    
    init(
        movieService: MovieServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.movieService = movieService
        self.userService = userService
    }
    
    func getData() async {
        status = .loading
        
        do {
            async let pendingNowPlayingMovies = movieService.getMovies(for: .nowPlaying)
            async let pendingPopularMovies = movieService.getMovies(for: .popular)
            async let pendingTopRatedMovies = movieService.getMovies(for: .topRated)
            async let pendingUser = userService.getUser()
            
            let (nowPlaying, popular, topRated, user) = try await (
                pendingNowPlayingMovies,
                pendingPopularMovies,
                pendingTopRatedMovies,
                pendingUser
            )
            
            nowPlayingMovies = nowPlaying.results
            popularMovies = popular.results
            topRatedMovies = topRated.results
            username = user.username
            randomMovie = topRated.results.randomElement()
            
            status = .success
        } catch  {
            status = .failure
        }
    }
}
