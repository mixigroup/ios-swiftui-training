extension Task {
    static func never() async throws -> Success where Failure == Never {
        let stream = AsyncStream<Success> { _ in }
        for await element in stream {
            return element
        }
        throw _Concurrency.CancellationError()
    }
}
