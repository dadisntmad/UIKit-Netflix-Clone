struct SessionRequest: Codable {
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}
