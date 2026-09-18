import Foundation

enum CustomError: Error, LocalizedError {
    case invalidUrl
    case decodingError
    case httpError(statusCode: Int)
    case networkError(Error)
    case noSessionId
    case noAccountId
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl: return "Invalid server endpoint URL."
        case .decodingError: return "Failed to process response data."
        case .httpError(let code): return "HTTP Server error code: \(code)."
        case .networkError(let err): return err.localizedDescription
        case .noSessionId: return "No session ID available."
        case .noAccountId: return "No account ID available."
        }
    }
}
