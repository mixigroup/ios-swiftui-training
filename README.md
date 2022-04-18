## 2.2. URLSessionによる通信
- iOSアプリ開発で通信周りを実装する場合、ライブラリ等を使わない限りは基本 [URLSession](https://developer.apple.com/documentation/foundation/urlsession) を使うことになります
- URLSessionはもちろん非同期な通信を扱いますが、それらをCombineでハンドリングしやすくするための便利なoperatorが用意されています
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
- 作成したURLをもとに [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) を作成し、http methodやhttp headerを設定します
- [URLSession.data(for:)](https://developer.apple.com/documentation/foundation/urlsession/3767352-data) は与えられたURLに対してURLSessionのタスクを実行してレスポンスをを返してくれます、これは async 関数なので await で結果を待つようにします
- SwiftでJSONをdecodeする際には [Deodable](https://developer.apple.com/documentation/swift/decodable) を使用します
- 上記の例では `User` の構造体にDecodableを準拠させることで、decodeされたJSONオブジェクトの各フィールドがmappingされるようになります
- JSONのフィールドとDecodableのproperty名は同じにする必要があります、もし異なる命名をしたければ [CodingKey](https://developer.apple.com/documentation/swift/codingkey) を使用します
- 例えば、以下のような使い方になります
    
```
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

### チャレンジ
- `ReposStore.loadRepos` メソッドに手を加えて [mixi GROUPのOrganization](https://github.com/mixigroup) にあるpublicなリポジトリを取得して一覧表示できるようにしてください
- 特定のOrganizationのリポジトリを取得するGitHubのREST APIの仕様はこちらです: https://docs.github.com/en/rest/reference/repos#list-organization-repositories

#### ヒント
- APIドキュメントを読む限り
  - 対象となるURLは `https://api.github.com/orgs/mixigroup/repos` になりそうです
  - URLRequestを作って、http methodには `GET` を、http headerには `"Accept": "application/vnd.github.v3+json"` を設定する必要がありそうです
  - Repo, Userそれぞれに対応するJSONは以下のようなフォーマットになっていそうなので、CodingKeyを使用して命名の異なるpropertyを揃える必要がありそうです
  - `JSONDecoder.keyDecodingStrategy` を使うことでRepoはCodingKeyを使用せずともmappingできるかもしれません

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

まずは、レスポンスのJSONをdecodeできるように、対応するRepoおよびUserをDecodableに準拠させます

```swift
struct Repo: Identifiable, Codable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}

struct User: Codable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
```
    
descriptionをOptionalに変更したため、RepoDetailViewも少し手を加える必要があるので注意してください ( <code>if let description = repo.description</code> でOptional Bindingをしてから説明文を表示するようにしてみてください)<br>
Repo の場合 `stargazers_count` → `stargazersCount` の変換は命名を変えているわけではなく、スネークケースをキャメルケースに変えているだけなので、デコーダー側の設定で `JSONDecoder.keyDecodingStrategy` に `.convertFromSnakeCase` を指定することができます
    
次に、URLRequest を初期化し、http method, http headerを設定します
そして、用意したURLRequestを引数にURLSession.shared.dataを呼び出してレスポンスを取得します

```swift
let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "GET"
urlRequest.allHTTPHeaderFields = [
    "Accept": "application/vnd.github.v3+json"
]

let (data, _) = try! await URLSession.shared.data(for: urlRequest)    
```

次に、デコードです。前述の通りデコーダーの `keyDecodingStrategy` に `.convertFromSnakeCase` を指定します<br>
decodeの引数typeには、受け取るJSONに対応するDecodableの型情報 <code>[Repo].self</code> を渡してあげます 

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let value = try! decoder.decode([Repo].self, from: data)
repos = value
```

さて、これでXcode PreviewsをLive Previewで実行してみて、ちゃんとAPIからデータを取得して表示できているかを確認してみましょう
</details>

### 前セッションとのDiff
[session-2.1..session-2.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.1..session-2.2)

## Next
[2.3. エラーハンドリング](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.3)
