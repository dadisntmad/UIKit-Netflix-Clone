enum MovieType {
    case nowPlaying
    case popular
    case topRated
    
    var endpoint: String {
        switch self {
        case .nowPlaying: return "now_playing"
        case .popular: return "popular"
        case .topRated: return "top_rated"
        }
    }
}
