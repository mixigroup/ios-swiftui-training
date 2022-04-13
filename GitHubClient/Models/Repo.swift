import Foundation

struct Repo: Identifiable, Decodable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}
