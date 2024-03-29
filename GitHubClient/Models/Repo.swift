import Foundation

struct Repo: Identifiable, Decodable, Equatable, Hashable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}
