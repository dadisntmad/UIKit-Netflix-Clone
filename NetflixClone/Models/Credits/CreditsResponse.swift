struct Credits: Codable {
    let id: Int
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Codable {
    let id: Int
    let knownForDepartment: String
    let name: String
    let character: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case knownForDepartment = "known_for_department"
        case name
        case character
    }
}

struct Crew: Codable {
    let id: Int
    let knownForDepartment: String
    let name: String
    let department: String
    let job: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case knownForDepartment = "known_for_department"
        case name
        case department
        case job
    }
}
