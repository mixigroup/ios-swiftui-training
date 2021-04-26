## 1.4. ナビゲーション
- リスト表示から詳細画面へ遷移できるようにしてみましょう
- まずは `⌘ + N`で詳細画面を `RepoDetailView` という名前で作りましょう

<img src="https://user-images.githubusercontent.com/8536870/115515750-65c8a180-a2c0-11eb-894a-0e67e6c2d119.png" height=500>

- `ContentView` も `RepoListView` にrenameしておきましょう、範囲選択して右クリックで `Refactor > Rename` を選択して実行してください

<img src="https://user-images.githubusercontent.com/8536870/115515897-8abd1480-a2c0-11eb-9681-90ba9903412b.png" height=500>

- View周りのファイルも `Views` フォルダにまとめましょう

<img src="https://user-images.githubusercontent.com/8536870/115515967-9e687b00-a2c0-11eb-9ace-d1cf74035b20.png" height=500>

- 詳細画面は以下のようなレイアウトにしましょう

<img src="https://user-images.githubusercontent.com/8536870/115516019-ac1e0080-a2c0-11eb-8577-1d656de4522f.png" height=500>

- 新しく以下の要素を表示する必要が出てきました
    - リポジトリの説明文
    - スター数

- `Repo` に以下のpropertyを追加しましょう

```diff
struct Repo: Identifiable {
    var id: Int
    var name: String
    var owner: User
+   var description: String
+   var stargazersCount: Int
}
```

- モックデータの初期化時にも `description` と `stargazersCount` を追加しましょう
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
struct RepoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RepoDetailView(repo: .mock1)
    }
}
```

- これでようやく詳細画面のレイアウトを組んでいく準備が整いました、まずは試しに実装してみてください
- ちなみに星マークは以下のコードで表示可能です

```swift
Image(systemName: "star")
```

- [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/) と呼ばれるアイコン集がAppleによって提供されているため、ここで定義されているSymbolは上記のように使用可能となっています
    - DynamicTypeと連動して大きさが変化したり、フォントのbaselineと揃えて表示できたりと便利なものになっています
- さて、これまでのSwiftUIの知識でレイアウトを組んでいくと、以下のような表示になるかと思います

<img src="https://user-images.githubusercontent.com/8536870/115516361-00c17b80-a2c1-11eb-9a28-77dd85c46b37.png" height=500>

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
- ナビゲーションを実装するためには、まずは一覧画面のViewを [NavigationView](https://developer.apple.com/documentation/swiftui/navigationview) のなかに組み込みます
- さらに、ナビゲーションのタイトルバーに表示される文字列を `.navigationTitle("Repositories")` のように指定します
    - NavigationViewに対してではなく、その内部のViewに対して `navigationTitle` のmodifierを宣言することに違和感を感じるかもしれませんが、NavigationViewの中のViewは画面遷移をするごとに変わるため、その中身に応じてタイトルを決めると考えるならばむしろ自然な定義といえます

```swift
NavigationView {
    List(mockRepos) { ... }
      .navigationTitle("Repositories")
}
```

- 各Rowをタップすると詳細画面へ遷移するように実装するためには、 `RepoRow` を [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink) で囲ってあげます、その際NavigationLinkの初期化時の引数として `RepoDetailView` を渡してあげます

```swift
NavigationLink(
    destination: RepoDetailView(repo: repo)) {
    RepoRow(repo: repo)
}
```

- 最後にRepoDetailViewにて `.navigationBarTitleDisplayMode(.inline)` のmodifierを追加することで表示されるNavigationBarのスタイルをインラインにしておきましょう
- 一覧画面のPreviewで左上の再生ボタンをタップしてLive Previewにして遷移できるか確認してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115516573-35cdce00-a2c1-11eb-9a94-250060d7dff0.png" height=500>

### チャレンジ
- 詳細画面は今後もコンテンツが増えていきそうですね、小さい端末でも内容が全て表示されるように、コンテンツをスクロールできるようにしてください

<details>
    <summary>解説</summary>
やることは単純で、 <a href="https://developer.apple.com/documentation/swiftui/scrollview" rel="nofollow">ScrollView</a> でコンテンツを囲ってあげるだけです
    
```swift
ScrollView {
    HStack {
        VStack(alignment: .leading) {
            ...
            Spacer()
        }
        Spacer()
    }
    .padding(8)
}
.navigationBarTitleDisplayMode(.inline)
```

動的なコンテンツを表示するViewでは、必ず小さい端末でも切れずに表示されるかを気にかけておきましょう<br>
デザインの段階では短い文章だったため収まったが、実際のデータだと長い文章が入力されて下の方が見切れてしまう、というようなことは実務でもよくあります

そういった場合を考慮して、ScrollViewでスクロール可能なコンテンツにしておけると良いでしょう

</details>

### 前セッションとのDiff
[session-1.3...session-1.4](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.3...session-1.4)

## Next
[1.5. ライフサイクルと状態管理](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.5)
