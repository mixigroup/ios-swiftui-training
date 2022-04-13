import Foundation

struct User: Decodable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
