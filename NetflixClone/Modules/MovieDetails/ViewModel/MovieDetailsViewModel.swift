import Combine

final class MovieDetailsViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var movie: MovieDetails?
    
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
}
