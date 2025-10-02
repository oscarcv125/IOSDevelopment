import Foundation

struct Song: Identifiable, Decodable {
    var id = UUID()
    var title: String
    var artist: String
    var audioURL: String
    var coverImage: String
    
    enum CodingKeys: String, CodingKey {
        case title, artist, audioURL, coverImage
    }
}
