import Foundation
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
            movies = res.results.sorted { first, second in
                guard let date1 = first.releaseDate, let date2 = second.releaseDate else {
                    return first.releaseDate != nil
                }
                return date1 > date2
            }
            status = .success
        } catch {
            status = .failure
            movies = []
        }
    }
}
