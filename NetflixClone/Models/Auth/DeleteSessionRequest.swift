struct DeleteSessionRequest: Codable {
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}
