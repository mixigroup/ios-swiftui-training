import Foundation

enum Stateful<Value> {
    case loading
    case failed(Error)
    case loaded(Value)
}
