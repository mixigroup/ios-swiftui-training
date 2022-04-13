import Foundation

struct User: Decodable, Equatable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
