import Foundation
import Combine

@MainActor
final class NewAndHotViewModel {
    @Published private(set) var status: Status = .initial
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var page = 1
    @Published private(set) var hasMorePages = true
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    private var isLoading: Bool { status == .loading }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func getUpcomingMovies() async {
        guard !isLoading && hasMorePages else { return }
        
        status = .loading
        
        do {
            let res = try await movieService.getUpcomingMovies(page: page)
            let fetchedMovies = res.results
            
            if fetchedMovies.isEmpty {
                hasMorePages = false
            } else {
                movies.append(contentsOf: fetchedMovies)
                
                movies.sort { first, second in
                    guard
                        let str1 = first.releaseDate,
                        let str2 = second.releaseDate,
                        let date1 = dateFormatter.date(from: str1),
                        let date2 = dateFormatter.date(from: str2)
                    else { return false }
                    
                    return date1 > date2
                }
                
                hasMorePages = res.page < res.totalPages
                page += 1
            }
            
            status = .success
        } catch {
            status = .failure
        }
    }
}
