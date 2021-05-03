## 2.2. URLSessionによる通信
- iOSアプリ開発で通信周りを実装する場合、ライブラリ等を使わない限りは基本 [URLSession](https://developer.apple.com/documentation/foundation/urlsession) を使うことになります
- URLSessionはもちろん非同期な通信を扱いますが、それらをCombineでハンドリングしやすくするための便利なoperatorが用意されています
- 例えば、特定のURLに対してリクエストを投げてレスポンスであるJSONをdecodeして返す場合には以下のような実装になります 

```swift
struct User: Codable {
    let name: String
    let userID: String
}

let url = URL(string: "https://example.com/endpoint")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "GET"
urlRequest.allHTTPHeaderFields = [
    "Accept": "application/json"
]

cancellable = URLSession.shared
    .dataTaskPublisher(for: urlRequest)
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

- まずはリクエストを投げる先のURLを [URL.init(string:)](https://developer.apple.com/documentation/foundation/nsurl/1413146-init) で初期化します
- 作成したURLをもとに [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) を作成し、http methodやhttp headerを設定します
- [URLSession.dataTaskPublisher](https://developer.apple.com/documentation/foundation/urlsession/3329708-datataskpublisher) は与えられたURLに対してURLSessionのタスクを実行してレスポンスをストリームに流すPublisherを返してくれます、このPublisherをsubscribeすることで、通信が完了したタイミングでSubscriber内でイベントをハンドリングできます
- [tryMap](https://developer.apple.com/documentation/combine/fail/trymap(_:)) はCombineに用意されたoperatorです、Publisherから流れてくる要素を他の型にmappingしたり、エラーをthrowすることができます
- ここではhttpのstatus codeが200以外の場合は異常とみなしてエラーを返し、それ以外の場合はresponseのdataのみを返しています
- [decode](https://developer.apple.com/documentation/combine/publishers/decode) はPublisherから流れてきた要素をdecodeして返します
- SwiftでJSONをdecodeする際には [Codable](https://developer.apple.com/documentation/swift/codable) を使用します
- 上記の例では `User` の構造体にCodableを準拠させることで、decodeされたJSONオブジェクトの各フィールドがmappingされるようになります
- JSONのフィールドとCodableのproperty名は同じにする必要があります、もし異なる命名をしたければ [CodingKey](https://developer.apple.com/documentation/swift/codingkey) を使用します
- 例えば、以下のような使い方になります
    
```
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

#### ヒント
- APIドキュメントを読む限り
  - 対象となるURLは `https://api.github.com/orgs/mixigroup/repos` になりそうです
  - URLRequestを作って、http methodには `GET` を、http headerには `"Accept": "application/vnd.github.v3+json"` を設定する必要がありそうです
  - Repo, Userそれぞれに対応するJSONは以下のようなフォーマットになっていそうなので、CodingKeyを使用して命名の異なるpropertyを揃える必要がありそうです

  ```
  [
    {
      id: Int,
      name: String,
      description: String?,
      stargazers_count: Int,
      owner: {
        login: String // ユーザー名を表す
      }
    },
    ...
  ]
  ```

<details>
    <summary>解説</summary>

まずは、対象となるURLを初期化し、http method, http headerを設定していきます

```swift
let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "GET"
urlRequest.allHTTPHeaderFields = [
    "Accept": "application/vnd.github.v3+json"
]
```

次に、用意したURLRequestを引数にURLSession.shared.dataTaskPublisherを呼び出してPublisherを作成します

```swift
let reposPublisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
```

そして、tryMapでPublisherに流れてくるレスポンスを加工してあげます

```swift
    .dataTaskPublisher(for: urlRequest)
    .tryMap() { element -> Data in
        guard let httpResponse = element.response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return element.data
    }
```

JSONをdecodeできるように、対応するRepoおよびUserをCodableに準拠させます <br>
descriptionをOptionalに変更したため、RepoDetailViewも少し手を加える必要があるので注意してください ( <code>if let description = repo.description</code> でOptional Bindingをしてから説明文を表示するようにしてみてください)

```swift
struct Repo: Identifiable, Codable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case description
        case stargazersCount = "stargazers_count"
    }
}

struct User: Codable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
```

最後にPublisherに流れてくるレスポンスのJSONデータに対してdecodeを呼び出してあげれば完成です

decodeの引数typeには、受け取るJSONに対応するCodableの型情報を渡してあげます <br>
この場合はRepoの配列なので <code>[Repo].self</code> が正しいです

```swift
    .dataTaskPublisher(for: urlRequest)
    .tryMap() {...}
    .decode(type: [Repo].self, decoder: JSONDecoder())
```

さて、これでXcode PreviewsをLive Previewで実行してみて、ちゃんとAPIからデータを取得して表示できているかを確認してみましょう
</details>

### 前セッションとのDiff
[session-2.1...session-2.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.1...session-2.2)

## Next
[2.3. エラーハンドリング](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.3)
