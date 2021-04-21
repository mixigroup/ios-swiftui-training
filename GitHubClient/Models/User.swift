import Foundation

struct User: Codable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
