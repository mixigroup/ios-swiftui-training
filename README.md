## 1.3. リスト表示
- 先のセッションで組み立てたレイアウトをリスト形式で表示してみましょう
- SwiftUIでリスト表示を実装する場合には [List](https://developer.apple.com/documentation/swiftui/list) を使うと良いでしょう
- 一番外側のHStackを `⌘ + Click` で選択して、 `Embed in List` を選択してください

<img src="https://user-images.githubusercontent.com/8536870/115513674-4c265a80-a2be-11eb-8f8b-27ce49fd49fb.png" width=50%>

- HStack が List に置き換わってしまうので、HStack で囲い直します（List で HStack を囲ってところ）

```swift
List(0 ..< 5) { item in
    HStack {
        ....
    }
}
```
- いい感じにリスト表示されていることがわかります

<img src="https://user-images.githubusercontent.com/8536870/115513734-6102ee00-a2be-11eb-897e-5084947cf214.png" width=50%>

- ではこのリストで動的なデータを表示してみましょう
- まずはリポジトリ名やユーザー名を格納するデータモデルを作成しましょう
- `⌘ + N` で `Repo` と `User` の2つのSwiftファイルを新規作成してください

<img src="https://user-images.githubusercontent.com/8536870/115513794-724bfa80-a2be-11eb-9ff5-7680bf1dd0f4.png">

- 2つのファイルを選択して右クリックで `New Group from Selection` を選んで `Models` フォルダにまとめてしまいましょう

<img src="https://user-images.githubusercontent.com/8536870/115513909-8b54ab80-a2be-11eb-8a0c-f8efaac0ad4a.png" width=50%>

```swift
struct Repo {
    var name: String
    var owner: User
}

struct User {
    var name: String
}
```

- Swiftのstructはイニシャライザを明示的に宣言しなくとも、memberwize initializerを勝手に作ってくれます
    - つまり `init(name: String, owner: User) {...}` をわざわざ書かなくてもよくなってます
- 次にListに動的に表示する対象となるモックデータを以下のように作成してみてください

```swift
struct ContentView: View {
    private let mockRepos = [
        Repo(name: "Test Repo1", owner: User(name: "Test User1")),
        Repo(name: "Test Repo2", owner: User(name: "Test User2")),
        Repo(name: "Test Repo3", owner: User(name: "Test User3")),
        Repo(name: "Test Repo4", owner: User(name: "Test User4")),
        Repo(name: "Test Repo5", owner: User(name: "Test User5"))
    ]
    ...
```

- そして、Listの引数に指定された `0 ..< 5` の代わりに `mockRepos` を渡してください
- すると以下のようなエラーが表示されるはずです

> Initializer 'init(_:rowContent:)' requires that 'Repo' conform to 'Identifiable'

- Listが各要素を一意に識別できるようにするために、渡すデータは [Identifiable](https://developer.apple.com/documentation/swift/identifiable) に準拠している必要があります
- よって、 `Repo` に `id` propertyを追加しつつ `Identifiable` を適用します
  - idの型は `Hashable` に準拠していれば良いのでIntでもStringでも大丈夫です、が後にAPIから取得するJSONの型を考慮してIntにしています
 

```swift
struct Repo: Identifiable {
    var id: Int
    var name: String
    var owner: User
}
```

- モックデータもidを初期化するように修正します

```swift
private let mockRepos = [
        Repo(
            id: 1,
            name: "Test Repo1",
            owner: User(name: "Test User1")
        ),
        Repo(
            id: 2,
            name: "Test Repo2",
            owner: User(name: "Test User2")
        ),
        Repo(
            id: 3,
            name: "Test Repo3",
            owner: User(name: "Test User3")
        ),
        Repo(
            id: 4,
            name: "Test Repo4",
            owner: User(name: "Test User4")
        ),
        Repo(
            id: 5,
            name: "Test Repo5",
            owner: User(name: "Test User5")
        )
]
```

- Previewの `Try Again` ボタンを押すとビルドが通ることを確認できます
- あとはリストで表示する各行の内容をモックデータのものにしてあげます
- Listでは与えたデータモデルの配列の各要素が順番に取り出されてcontentに渡されています、以下のようにリポジトリ名とユーザー名を動的にしてみましょう

```swift
List(mockRepos) { repo in
    Image("GitHubMark")
        .resizable()
        .frame(
            width: 44.0,
            height: 44.0
        )
    VStack(alignment: .leading) {
        Text(repo.owner.name)
            .font(.caption)
        Text(repo.name)
            .font(.body)
            .fontWeight(.semibold)
    }
}
```

<img src="https://user-images.githubusercontent.com/8536870/115514049-acb59780-a2be-11eb-9696-eab9a33c459b.png" width=50%>

### チャレンジ
- List内で表示されるViewを `RepoRow` という名前で別なファイルに切り出してみましょう
- ちなみに他のViewにSubviewを切り出す場合は `⌘ + Click` で `Extract Subview` を選択すると便利です

<img src="https://user-images.githubusercontent.com/8536870/115514113-c060fe00-a2be-11eb-9206-58772b5105a8.png" width=50%>

<details>
    <summary>解説</summary>
まずはListの中身であるImageとVStackをHStackで囲み、それに対して <code>⌘ + Click</code> で<code>Extract Subview</code> を選択して <code>RepoRow</code> という名前の新しいViewに切り出してみましょう <br>

<img src="https://user-images.githubusercontent.com/8536870/116015634-f1518200-a674-11eb-8fb5-bd1e3252ffcb.png">


すると、以下のようなエラーが出るはずです
> Cannot find 'repo' in scope

Listから配られるRepoを受け取ってくる必要がありそうですね

切り出した <code>RepoRow</code> がイニシャライザ引数で <code>Repo</code> を受け取れるように、propertyを追加します


```diff
struct ContentView: View {
    ...
    var body: some View {
        List(mockRepos) { repo in
-           RepoRow()
+           RepoRow(repo: repo)
        }
    }
}

struct RepoRow: View {
+   let repo: Repo

    var body: some View {...}
}
```

あとは <code>RepoRow</code> を別ファイルに移してあげれば完了です
</details>

### 前セッションとのDiff
[session-1.2..session-1.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.2..session-1.3)

## Next
[1.4. ナビゲーション](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.4)
