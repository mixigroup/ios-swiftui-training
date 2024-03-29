import Foundation

struct User: Decodable, Equatable, Hashable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
