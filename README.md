## 3.3. Xcode Previewsの再活用
- しばらくXcode Previewsでデバッグしてきましたが、エラー表示などを確認するためにコメントアウトしたりコードを書き換えたりしていました
- もっとPreviewをうまく活用してこのような非効率的な確認方法を取らずに済むようにしていきましょう
- そのために `RepoAPIClient` をViewにDependency Injection(DI)できるようにしてRepoAPIClientをモックに置き換えて表示してみましょう
- まずは、テストファイルに定義したモックをPreviewでも再利用するために `Preview Content/Mocks` 以下に移動させましょう
- 次に、 `RepoListView` にRepoAPIClientをDIできるようにイニシャライザ引数から受け取るようにします

```swift
struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel
    init(repoAPIClient: RepoAPIClientProtocol) {
        // 参考: https://developer.apple.com/documentation/swiftui/stateobject#Initialize-state-objects-using-external-data
        _viewModel = StateObject(
            wrappedValue: RepoListViewModel(repoAPIClient: repoAPIClient)
        )
    }
    ...
```

```swift
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            RepoListView(repoAPIClient: RepoAPIClient())
        }
    }
}

```

- これでViewにRepoAPIClientを外部から渡せるようになりました
- Previewにて初期化時にモックされたAPIClientを渡してあげましょう

```swift
static var previews: some View {
    RepoListView(
        repoAPIClient: MockRepoAPIClient(
            repos: [
                .mock1, .mock2, .mock3, .mock4, .mock5
            ],
            error: nil
        )
    )
    .previewDisplayName("Default")
}
```

- Live Previewで期待通り表示されるか確認してみましょう
    
### チャレンジ
- `previews` にエラー状態を表示するPreviewを追加してください
- 各Previewには [previewDisplayName](https://developer.apple.com/documentation/swiftui/link/previewdisplayname(_:)) で名前をつけて表示することが可能です

<details>
    <summary>解説</summary>


RepoListViewを追加して、MockRepoAPIClientのerrorに`DummyError()`を渡してViewModelがエラー状態になるようにします

```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {        
        static var previews: some View {
        RepoListView(
            repoAPIClient: MockRepoAPIClient(
                repos: [
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ],
                error: nil
            )
        )
        .previewDisplayName("Default")

        RepoListView(
            repoAPIClient: MockRepoAPIClient(
                repos: [],
                error: DummyError()
            )
        )
        .previewDisplayName("Error")
    }
}
```

Previewの上部にErrorというタブが表示されました、これをクリックすればエラー状態のPreviewを確認することができます
![GitHubClient_—_RepoListView_swift_—_Edited](https://user-images.githubusercontent.com/17004375/234429326-f8a275c4-3f92-409a-9562-61998df9fb95.png)

</details>

### 前セッションとのDiff
[session-3.2..session-3.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.2..session-3.3)

## Next
To be continued...
