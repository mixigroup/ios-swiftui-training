## 3.3. Xcode Previewsの再活用
- しばらくXcode Previewsでデバッグしてきましたが、エラー表示や空表示を確認するためにコメントアウトしたりコードを書き換えたりしていました
- もっとPreviewをうまく活用してこのような非効率的な確認方法を取らずに済むようにしていきましょう
- そのために `RepoRepository` をViewにDependency Injection(DI)できるようにしてRepositoryをモックに置き換えて表示してみましょう
- まずは、テストファイルに定義したモックをPreviewでも再利用するために `Preview Content/Mocks` 以下に移動させましょう
- 次に、 `RepoListView` にてRepositoryをDIできるようにイニシャライザ引数から受け取るようにします

```swift
struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel

    init(repoRepository: RepoRepository) {
        // 参考: https://developer.apple.com/documentation/swiftui/stateobject#Initialize-state-objects-using-external-data
        _viewModel = StateObject(wrappedValue: RepoListViewModel(repoRepository: repoRepository))
    }
    ...
```

```swift
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            RepoListView(repoRepository: RepoDataRepository())
        }
    }
}

```

- これでViewにRepositoryを外部から渡せるようになりました
- Previewにて初期化時にモックされたRepositoryを渡してあげましょう

```swift
static var previews: some View {
    RepoListView(
        repoRepository: MockRepoRepository(
            repos: [
                .mock1, .mock2, .mock3, .mock4, .mock5
            ]
        )
    )
    .previewDisplayName("Default")
}
```

- Live Previewで期待通り表示されるか確認してみましょう
    
### チャレンジ
- Previewを複製して、空状態, エラー状態を表示するPreviewを作成してください
- Previewは右上のDuplicateボタンから簡単に複製できます

<img width="264" alt="スクリーンショット_2022-04-26_22_26_22" src="https://user-images.githubusercontent.com/17004375/165310583-9a9588ab-9bb8-4376-942c-0b64f2c74818.png">


- 各Previewには [previewDisplayName](https://developer.apple.com/documentation/swiftui/link/previewdisplayname(_:)) で名前をつけて表示することが可能です

<details>
    <summary>解説</summary>

まずはXcode Previews右上のDuplicateボタンからPreviewを複製します <br>
コードが以下のようになるはずです

```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: [
                        .mock1, .mock2, .mock3, .mock4, .mock5
                    ]
                )
            )
            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: [
                        .mock1, .mock2, .mock3, .mock4, .mock5
                    ]
                )
            )
        }
    }
}
```

下の<code>RepoListView</code>で空状態の表示をPreviewしてみましょう <br>
そのために、 <code>MockRepoRepository</code> のイニシャライザ引数には空配列を渡してあげます

```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoListView(...)
            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: []
                )
            )
        }
    }
}
```

Live Previewで空表示を確認してみましょう

次にエラー表示のPreviewを作成します <br>
またDuplicateボタンからPreviewを複製して、今度は <code>MockRepoRepository</code> のイニシャライザ引数でDummyErrorを渡してあげます


```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoListView(...)
            RepoListView(...)
            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: [],
                    error: DummyError()
                )
            )
        }
    }
}
```

Live Previewでエラー表示を確認してみましょう

これで3つの状態をPreviewで確認できるようになりました <br>
最後にそれぞれを識別できるようにpreviewDisplayNameで名前をつけてあげましょう

```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoListView(...)
                .previewDisplayName("Default")
            RepoListView(...)
                .previewDisplayName("Empty")
            RepoListView(...)
                .previewDisplayName("Error")
        }
    }
}
```

Preview上部に以下のように名前が表示されます

<img width="303" alt="スクリーンショット 2022-04-26 22 31 04" src="https://user-images.githubusercontent.com/17004375/165311265-63ab9ba9-fddf-463d-8bcb-166ee27b4e3a.png">

</details>

### 前セッションとのDiff
[session-3.2..session-3.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.2..session-3.3)

## Next
To be continued...
