import Combine

import Foundation
import Combine

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    @Published private(set) var status: Status = .initial
    @Published private(set) var movie: MovieDetails?
    @Published private(set) var credits: Credits?
    @Published private(set) var similarMovies: [Movie] = []
    @Published private(set) var isFavorite = false
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func fetchAllData(id: Int) async {
        status = .loading
        
        do {
            async let movieFetch = movieService.getMovieDetails(for: id)
            async let creditsFetch = movieService.getMovieCredits(for: id)
            async let similarFetch = movieService.getSimilarMovies(for: id)
            async let favoriteFetch = movieService.checkFavoriteMovie(for: id)
            
            let (movieRes, creditsRes, similarRes, favoriteRes) = try await (
                movieFetch, creditsFetch, similarFetch, favoriteFetch
            )
            
            self.movie = movieRes
            self.credits = creditsRes
            self.similarMovies = similarRes.results
            self.isFavorite = favoriteRes.favorite
            
            status = .success
        } catch {
            status = .failure
        }
    }
    
    func markMovieAsFavorite(id: Int) async {
        let previousState = isFavorite
        isFavorite.toggle()
        
        do {
            try await movieService.markAsFavorite(for: id, isFavorite: isFavorite)
        } catch {
            isFavorite = previousState // Roll back to previous state on failure
            status = .failure
        }
    }
}
