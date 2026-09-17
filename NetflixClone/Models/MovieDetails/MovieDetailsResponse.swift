struct MovieDetails: Codable {
    let adult: Bool
    let backdropPath: String?
    let genres: [Genre]
    let id: Int
    let originalTitle: String?
    let overview: String
    let releaseDate: String
    let title: String
    let videos: Video
    
    var movieGenre: String {
        genres.map(\.name).joined(separator: " · ")
    }
    
    var movieYear: String {
        releaseDate.split(separator: "-").first?.description ?? "Unknown Release Year"
    }
    
    var youtubeVideos: [VideoResult] {
        videos.results.filter({ $0.site == "YouTube" && $0.type == "Trailer" })
    }
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genres
        case id
        case originalTitle = "original_title"
        case overview
        case releaseDate = "release_date"
        case title
        case videos
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct Video: Codable {
    let results: [VideoResult]
}

struct VideoResult: Codable {
    let key: String
    let site: String
    let id: String
    let type: String
}
