import Foundation

enum Stateful<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}
