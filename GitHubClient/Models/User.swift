import Foundation

struct User: Decodable, Hashable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
