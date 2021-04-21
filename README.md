## 2.2. URLSessionによる通信
- iOSアプリ開発で通信周りを実装する場合、ライブラリ等を使わない限りは基本 [URLSession](https://developer.apple.com/documentation/foundation/urlsession) を使うことになります
- URLSessionはもちろん非同期な通信を扱いますが、それらをCombineでハンドリングしやすくするための便利なoperatorが用意されています
- 例えば、特定のURLに対してリクエストを投げてレスポンスであるJSONをdecodeして返す場合には以下のような実装になります (https://developer.apple.com/documentation/foundation/urlsession/processing_url_session_data_task_results_with_combine より引用)

```swift
struct User: Codable {
    let name: String
    let userID: String
}
let url = URL(string: "https://example.com/endpoint")!
cancellable = urlSession
    .dataTaskPublisher(for: url)
    .tryMap() { element -> Data in
        guard let httpResponse = element.response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        return element.data
        }
    .decode(type: User.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { print ("Received completion: \($0).") },
          receiveValue: { user in print ("Received user: \(user).")})
```

- まず [URLSession.dataTaskPublisher](https://developer.apple.com/documentation/foundation/urlsession/3329708-datataskpublisher) は与えられたURLに対してURLSessionのタスクを実行してレスポンスをストリームに流すPublisherを返してくれます、このPublisherをsubscribeすることで、通信が完了したタイミングでSubscriber内でイベントをハンドリングできます
- [tryMap](https://developer.apple.com/documentation/combine/fail/trymap(_:)) はCombineに用意されたoperatorです、Publisherから流れてくる要素を他の型にmappingしたり、エラーをthrowすることができます
- ここではhttpのstatus codeが200以外の場合は異常とみなしてエラーを返し、それ以外の場合はresponseのdataのみを返しています
- [decode](https://developer.apple.com/documentation/combine/publishers/decode) はPublisherから流れてきた要素をdecodeして返します
- SwiftでJSONをdecodeする際には [Codable](https://developer.apple.com/documentation/swift/codable) を使用します
- 上記の例では `User` の構造体にCodableを準拠させることで、decodeされたJSONオブジェクトの各フィールドがmappingされるようになります
- JSONのフィールドとCodableのproperty名は同じにする必要があります、もし異なる命名をしたければ [CodingKey](https://developer.apple.com/documentation/swift/codingkey) を使用します
- 例えば、以下のような使い方になります
    
```json
{
    user: {
        "name": "octocat",
        "image_url": "https://example.com/image.png",
    }
}
```
    
```swift
struct User: Codable {
    var name: String
    var imageURL: URL

    private enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
    }
}
```

### チャレンジ
- `ReposLoader.call` メソッドに手を加えて [mixi GROUPのOrganization](https://github.com/mixigroup) にあるpublicなリポジトリを取得して一覧表示できるようにしてください
- 特定のOrganizationのリポジトリを取得するGitHubのREST APIの仕様はこちらです: https://docs.github.com/en/rest/reference/repos#list-organization-repositories

### 前セッションとのDiff
[session-2.1...session-2.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.1...session-2.2)

## Next
[2.3. エラーハンドリング](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.3)
