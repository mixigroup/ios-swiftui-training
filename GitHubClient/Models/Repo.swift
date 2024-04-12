import Foundation

struct Repo: Identifiable, Hashable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}
