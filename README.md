## 1.3. リスト表示
- 先のセッションで組み立てたレイアウトをリスト形式で表示してみましょう
- SwiftUIでリスト表示を実装する場合には [List](https://developer.apple.com/documentation/swiftui/list) を使うと良いでしょう
- 一番外側のHStackを 右クリックして、 `Embed in List` を選択してください

<img width="376" alt="スクリーンショット 2024-04-21 0 37 50" src="https://github.com/mixigroup/ios-swiftui-training/assets/13087887/477c1a11-0eb7-4109-9c5b-eba772bae44b">

- HStack が List に置き換わってしまうので、HStack で囲い直します（List で HStack を囲ってところ）

```swift
List(0 ..< 5) { item in
    HStack {
        ....
    }
}
```
- いい感じにリスト表示されていそうです

![スクリーンショット 2023-04-25 13 37 59](https://user-images.githubusercontent.com/17004375/234175630-d01e9cce-fe8f-4381-8569-813a79085132.png)

- ではこのリストで動的なデータを表示してみましょう
- まずはリポジトリ名やユーザー名を格納するデータモデルを作成しましょう
- `⌘ + N` で `Repo` と `User` の2つのSwiftファイルを新規作成してください

<img src="https://user-images.githubusercontent.com/8536870/115513794-724bfa80-a2be-11eb-9ff5-7680bf1dd0f4.png">

- 2つのファイルを選択して右クリックで `New Group from Selection` を選んで `Models` フォルダにまとめてしまいましょう

<img width="352" alt="スクリーンショット 2022-04-26 21 18 06" src="https://user-images.githubusercontent.com/17004375/165298260-7e826db1-1d6f-49a8-b617-7a49d05dc5e6.png">


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

- あとはリストで表示する各行の内容をモックデータのものにしてあげます
- Listでは与えたデータモデルの配列の各要素が順番に取り出されてcontentに渡されています、以下のようにリポジトリ名とユーザー名を動的にしてみましょう

```swift
List(mockRepos) { repo in
    HStack {
        Image(.gitHubMark)
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
}
```


![スクリーンショット 2023-04-25 13 42 22](https://user-images.githubusercontent.com/17004375/234176258-c35db5e5-39c7-4060-8f76-aa5635ec56bd.png)


### チャレンジ
- List内で表示されるViewを `RepoRow.swift` という別ファイルに切り出してみましょう
- Subviewを他のViewに切り出す場合は対象のViewを右クリックして `Extract Subview` を選択すると便利です

<img width="399" alt="スクリーンショット 2024-04-21 0 44 50" src="https://github.com/mixigroup/ios-swiftui-training/assets/13087887/8f8f0b9b-44cc-4968-b3fc-f929cd0c2dfd">



<details>
    <summary>解説</summary>

`Extract Subview`　を実行すると以下のようなエラーが出るはずです
> Cannot find 'repo' in scope

Listから配られるrepoを受け取ってくる必要がありそうですね

切り出した <code>RepoRow</code> がイニシャライザ引数で <code>Repo</code> を受け取れるように、propertyを追加します


```diff
struct RepoRow: View {
+   let repo: Repo

    var body: some View {...}
}

struct ContentView: View {
    ...
    var body: some View {
        List(mockRepos) { repo in
-           RepoRow()
+           RepoRow(repo: repo)
        }
    }
}
```

あとは <code>RepoRow</code> を別ファイルに移してあげれば完了です
</details>

### 前セッションとのDiff
[session-1.2..session-1.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.2..session-1.3)

## Next
[1.4. ナビゲーション](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.4)
