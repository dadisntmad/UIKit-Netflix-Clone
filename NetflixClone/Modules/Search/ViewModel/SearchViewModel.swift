import Foundation
import Combine

@MainActor
final class SearchViewModel {
    @Published var searchText = ""
    @Published private(set) var status: Status = .initial
    @Published private(set) var movies = [Movie]()
    
    private let movieService: MovieServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
        setupDebounce()
    }
    
    private func searchMovie(with query: String) async {
        status = .loading
        
        do {
            let res = try await movieService.searchMovie(with: query)
            movies = res.results
            status = .success
        } catch {
            movies = []
            status = .failure
        }
    }
    
    private func setupDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmed.isEmpty {
                    self.movies = []
                    self.status = .initial
                } else {
                    Task {
                        await self.searchMovie(with: query)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
