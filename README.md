## 2.2. URLSessionによる通信
- iOSアプリ開発で通信周りを実装する場合、ライブラリ等を使わない限りは基本 [URLSession](https://developer.apple.com/documentation/foundation/urlsession) を使うことになります
- 例えば、特定のURLに対してリクエストを投げてレスポンスであるJSONをdecodeして返す場合には以下のような実装になります 

```swift
struct User: Decodable {
    let name: String
    let userID: String
}

let url = URL(string: "https://example.com/endpoint")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "GET"
urlRequest.allHTTPHeaderFields = [
    "Accept": "application/json"
]

let (data, _) = try! await URLSession.shared.data(for: urlRequest)
let user = try! JSONDecoder().decode(User.self, from: data)
print("user: \(user)")
```

- まずはリクエストを投げる先のURLを [URL.init(string:)](https://developer.apple.com/documentation/foundation/nsurl/1413146-init) で初期化します
- 作成したURLをもとに [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) を作成し、HTTP MethodやHTTP Headerを設定します
- [URLSession.data(for:)](https://developer.apple.com/documentation/foundation/urlsession/3767352-data) は与えられたURLに対してURLSessionのタスクを実行してレスポンスを返してくれます、これは async 関数なので await で結果を待つようにします
- SwiftでJSONをdecodeする際には [Decodable](https://developer.apple.com/documentation/swift/decodable) を使用します
- 上記の例では `User` の構造体にDecodableを準拠させることで、decodeされたJSONオブジェクトの各フィールドがmappingされるようになります
- JSONのフィールドとDecodableのproperty名は同じにする必要があります、もし異なる命名をしたければ [CodingKey](https://developer.apple.com/documentation/swift/codingkey) を使用します
- 例えば、以下のような使い方になります
    
```ruby
{
    user: {
        "name": "octocat",
        "icon": "https://example.com/image.png",
    }
}
```
    
```swift
struct User: Decodable {
    var name: String
    var imageURL: URL

    private enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "icon"
    }
}
```

- では、`ReposStore.loadRepos` メソッドに手を加えて [MIXI GROUPのOrganization](https://github.com/mixigroup) にあるpublicなリポジトリを取得して一覧表示できるようにしてみましょう
- [特定のOrganizationのリポジトリを取得するGitHubのAPIの仕様](https://docs.github.com/en/rest/reference/repos#list-organization-repositories)を参考にリクエスト処理を実装すると次のようになります

```swift
let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "GET"
urlRequest.allHTTPHeaderFields = [
    "Accept": "application/vnd.github+json"
]
// GitHub API のリクエスト数制限(60回/h)回避のためのキャッシュ設定 ※研修内容とは直接関係ありません
urlRequest.cachePolicy = .returnCacheDataElseLoad

let (data, _) = try! await URLSession.shared.data(for: urlRequest)
// デコード処理
```

### チャレンジ
- 続きのデコード処理を実装し、APIレスポンスの結果をリストに表示できるようにしてください

#### ヒント

- APIドキュメントのレスポンスの仕様から、本アプリで利用するフィールドを抽出すると下記になります

 ```ruby
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
    {
      id: Int,
      ...
    },
    ...
  ]
```

- レスポンスはスネークケースで返ってくるようです
- スネークケースをキャメルケースに変換するだけであれば、CodingKeyを実装せずとも、[JSONDecoder.keyDecodingStrategy](https://developer.apple.com/documentation/foundation/jsondecoder/2949119-keydecodingstrategy)を使えそうです
- Userの `login` → `name` の変換はCodingKeyを使用して命名の異なるpropertyをmappingする必要がありそうです

<details>
    <summary>解説</summary>

まずは、レスポンスのJSONをdecodeできるように、対応するRepoおよびUserをDecodableに準拠させます

```swift
struct Repo: Identifiable, Decodable, Hashable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}

struct User: Decodable, Hashable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
```
    
RepoにはCodingKeysを定義していません。Repo の場合 `stargazers_count` → `stargazersCount` の変換は命名を変えているわけではなく、スネークケースをキャメルケースに変えているだけなので、デコーダー側の設定で `JSONDecoder.keyDecodingStrategy` に `.convertFromSnakeCase` を指定することができます。
decodeの引数typeには、受け取るJSONに対応するDecodableの型情報 `[Repo].self` を渡してあげます 

```swift
...
let (data, _) = try! await URLSession.shared.data(for: urlRequest)

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
repos = try! decoder.decode([Repo].self, from: data)
```

さて、これでLive PreviewでAPIからデータを取得して表示できているかを確認してみましょう
</details>

### 前セッションとのDiff
[session-2.1..session-2.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.1..session-2.2)

## Next
[2.3. エラーハンドリング](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.3)
