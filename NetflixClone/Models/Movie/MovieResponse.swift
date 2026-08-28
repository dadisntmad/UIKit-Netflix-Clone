struct MovieResponse: Codable {
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    let page: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case page
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let voteAverage: Double
    let backdropPath: String?
    let genreIds: [Int]?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    
    var moviePosterPath: String {
        "https://image.tmdb.org/t/p/w500\(posterPath ?? "")"
    }
    
    var movieBackdropPath: String {
        "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case voteAverage = "vote_average"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}
