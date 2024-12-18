import Foundation

struct Station: Codable, Identifiable {
    let id: String
    let name: String
    let latitude: String
    let longitude: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct StationsResponse: Decodable {
    let status: Int
    let stations: [Station]
} 
