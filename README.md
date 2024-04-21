## 1.4. ナビゲーション
- リスト表示から詳細画面へ遷移できるようにしてみましょう
- まずは `⌘ + N`で詳細画面を `RepoDetailView` という名前で作りましょう

<img src="https://user-images.githubusercontent.com/8536870/115515750-65c8a180-a2c0-11eb-894a-0e67e6c2d119.png">

- `ContentView` も `RepoListView` にrenameしておきましょう、範囲選択して右クリックで `Refactor > Rename` を選択して実行してください

<img src="https://user-images.githubusercontent.com/8536870/115515897-8abd1480-a2c0-11eb-9681-90ba9903412b.png">

- View周りのファイルも `Views` フォルダにまとめましょう

<img src="https://user-images.githubusercontent.com/8536870/115515967-9e687b00-a2c0-11eb-9ace-d1cf74035b20.png">

- 詳細画面は以下のようなレイアウトを目指していきます

![スクリーンショット 2023-04-25 16 09 01](https://user-images.githubusercontent.com/17004375/234200747-552da349-a8d9-45e2-85c6-7abdb90eb40e.png)

- 新しく以下の要素を表示する必要が出てきました
    - リポジトリの説明文
    - スター数

- `Repo` に以下のpropertyを追加しましょう

```diff
struct Repo: Identifiable {
    var id: Int
    var name: String
    var owner: User
+   var description: String?
+   var stargazersCount: Int
}
```
- `description`がオプショナルな理由は、GitHubAPIのレスポンスの仕様に合わせているためです
- 詳細画面で表示する `Repo` を初期化時に受け取れるようにします

```swift
struct RepoDetailView: View {
    let repo: Repo
    ...
```

- `RepoDetailView` のPreviewで初期化する際にモックデータの `Repo` を渡してあげましょう
- さて、モックデータを一覧画面や詳細画面で使い回すことになってきました、わざわざ定義し直すのも面倒です
- このようなPreviewでしか使わないようなデータは `Preview Content` にまとめて定義して使いまわしましょう
- `Preview Content` はデフォルトで `Development Assets` として設定されているため、プロダクションのバイナリに含まれることはありません

![image](https://user-images.githubusercontent.com/8536870/115516250-e4254380-a2c0-11eb-87e5-ca657711a1d9.png)

- `Preview Content/Mocks` 以下に `Repo+mock.swift` と `User+mock.swift`を追加します

```swift:User.swift
extension User {
    static let mock1 = User(name: "Test User1")
    static let mock2 = User(name: "Test User2")
    static let mock3 = User(name: "Test User3")
    static let mock4 = User(name: "Test User4")
    static let mock5 = User(name: "Test User5")
}
```

```swift:Repo.swift
extension Repo {
    static let mock1 = Repo(
        id: 1,
        name: "Test Repo1",
        owner: .mock1,
        description: "This is a good code sample",
        stargazersCount: 10
    )
    static let mock2 = Repo(
        id: 2,
        name: "Test Repo2",
        owner: .mock2,
        description: "This is a good code sample",
        stargazersCount: 10
    )
    static let mock3 = Repo(
        id: 3,
        name: "Test Repo3",
        owner: .mock3,
        description: "This is a good code sample",
        stargazersCount: 10
    )
    static let mock4 = Repo(
        id: 4,
        name: "Test Repo4",
        owner: .mock4,
        description: "This is a good code sample",
        stargazersCount: 10
    )
    static let mock5 = Repo(
        id: 5,
        name: "Test Repo5",
        owner: .mock5,
        description: "This is a good code sample",
        stargazersCount: 10
    )
}
```

- `Hoge+fuga.swift` の命名規則はこのようにextensionメソッドを生やす際によく用いられます
- モックデータを別ファイルに定義できたので、一覧画面のモックデータを置き換えましょう

```swift
struct RepoListView: View {
    private let mockRepos: [Repo] = [
        .mock1, .mock2, .mock3, .mock4, .mock5
    ]
    ...
```

- 詳細画面のPreviewに渡すモックデータも以下のように書けます

```swift
#Preview {
    RepoDetailView(repo: .mock1)
}
```

- これでようやく詳細画面のレイアウトを組んでいく準備が整いました、まずは試しに実装してみてください
- これまでのSwiftUIの知識でレイアウトを組んでいくと、以下のような表示になるかと思います

```swift
HStack {
    VStack(alignment: .leading) {
        HStack {
            Image(.gitHubMark")
                .resizable()
                .frame(width: 16, height: 16)
            Text(repo.owner.name)
                .font(.caption)
        }

        Text(repo.name)
            .font(.body)
            .fontWeight(.bold)
            
        　// Optional Binding を使って、descriptionがnilじゃない場合のみUIを表示する
        if description = repo.description {
            Text(repo.description)
                .padding(.top, 4) // .top などの方向と余白の長さを指定することができます
        }
        
        HStack {
            Image(systemName: "star")
            Text("\(repo.stargazersCount) stars")
        }
        .padding(.top, 8)
    }
}
.padding(8)

```

![スクリーンショット 2023-04-25 16 15 05](https://user-images.githubusercontent.com/17004375/234202028-1516124b-3c1f-405c-bcaf-c79dcc7da47d.png)

- 左上に詰めて表示させるにはどうすれば良いでしょうか、答えは [Spacer](https://developer.apple.com/documentation/swiftui/spacer) を使います
- SpacerをVStack, HStackの中で宣言すれば、Stackが画面いっぱいに広がり、Spacerを宣言した部分に余白ができるレイアウトになります
- 左上にコンテンツを表示させたい場合には以下のような使い方になるでしょう

```swift
HStack {
  VStack {
    // 左上に表示したいコンテンツ
    Spacer()
  }
  Spacer()
}
```

- 詳細画面も実装できたところで、一覧画面から遷移できるようにしてみましょう
- ナビゲーションを実装するためには、まずは一覧画面のViewを [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) のなかに組み込みます
- さらに、ナビゲーションのタイトルバーに表示される文字列を `.navigationTitle("Repositories")` のように指定します
    - NavigationStackに対してではなく、その内部のViewに対して `navigationTitle` のmodifierを宣言することに違和感を感じるかもしれませんが、NavigationViewの中のViewは画面遷移をするごとに変わるため、その中身に応じてタイトルを決めると考えるならばむしろ自然な定義といえます

```swift
NavigationStack {
    List(mockRepos) { ... }
      .navigationTitle("Repositories")
}
```

- 各Rowをタップすると詳細画面へ遷移するように実装するためには、 `RepoRow` を [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink) で囲ってあげます、その際NavigationLinkの初期化時の引数として `RepoDetailView` を渡してあげます

```swift
NavigationLink(value: repo) {
    RepoRow(repo: repo)
}
```

- そして、`[navigationDestination(for:destination:]()`を使用して、遷移先の画面を設定します。

```swift
.navigationDestination(for: Repo.self) { repo in
    RepoDetailView(repo: repo)
}
```

- 最後にRepoDetailViewにも `.navigationTitle("Repository Detail")` とタイトルを指定します
- PreviewをLiveモードにして画面遷移できるか確認してみましょう

### チャレンジ

(本セクションではチャレンジはありません)

### 前セッションとのDiff
[session-1.3..session-1.4](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.3..session-1.4)

## Next
[1.5. ライフサイクルと状態管理](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.5)
