import Combine

final class MovieDetailsViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var movie: MovieDetails?
    @Published private(set) var credits: Credits?
    @Published private(set) var similarMovies: [Movie] = []
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func getMovieDetails(id: Int) async {
        status = .loading
        
        do {
            let res = try await movieService.getMovieDetails(for: id)
            movie = res
            status = .success
        } catch {
            status = .failure
        }
    }
    
    func getMovieCredits(id: Int) async {
        status = .initial
        
        do {
            let res = try await movieService.getMovieCredits(for: id)
            credits = res
            status = .success
        } catch {
            status = .failure
        }
    }
    
    func getSimilarMovies(id: Int) async {
        status = .loading
        
        do {
            let res = try await movieService.getSimilarMovies(for: id)
            similarMovies = res.results
            status = .success
        } catch {
            status = .failure
        }
    }
}
