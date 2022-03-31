## 3.3. Xcode Previewsの再活用
- しばらくXcode Previewsでデバッグしてきましたが、エラー表示や空表示を確認するためにコメントアウトしたりコードを書き換えたりしていました
- もっとPreviewをうまく活用してこのような非効率的な確認方法を取らずに済むようにしていきましょう
- そのために `RepoListViewModel` をViewにDependency Injection(DI)できるようにしてRepositoryをモックに置き換えて表示してみましょう
- まずは、テストファイルに定義したモックをPreviewでも再利用するために `Preview Content/Mocks` 以下に移動させましょう
- 次に、 `RepoListView` にてViewModelをDIできるようにイニシャライザ引数から受け取るようにします

```swift
struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel

    init(viewModel: RepoListViewModel = RepoListViewModel()) {
        self.viewModel = viewModel
    }
    ...
```
    
- しかし、これだと以下のようなエラーが出てしまいます

> Cannot assign to property: 'viewModel' is a get-only property

- @StateObjectでannotateされたpropertyはget-onlyの制約が課されてしまうため、イニシャライザ引数によるDIができません
- 少しハックっぽいやり方にはなりますが、@StateObjectの内部実装にアクセスして解決を図ります

```swift
init(viewModel: RepoListViewModel = RepoListViewModel()) {
    _viewModel = StateObject(wrappedValue: viewModel)
}
```

- (正直あまり直感的な方法ではないのでこれが絶対に良い方法だという自信はありません、もしもっと良い方法を知っている方がいらしたら教えてください) 
- ひとまずこれでViewにViewModelを外部から渡せるようになりました
- Previewにて初期化時にモックされたRepositoryを持つViewModelを渡してあげましょう

```swift
static var previews: some View {
    RepoListView(
        viewModel: RepoListViewModel(
            repoRepository: MockRepoRepository(
                repos: [
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ]
            )
        )
    )
}
```

- Live Previewで期待通り表示されるか確認してみましょう
    
### チャレンジ
- Previewを複製して、空状態, エラー状態を表示するPreviewを作成してください
- Previewは右上のDuplicateボタンから簡単に複製できます

<img src="https://user-images.githubusercontent.com/8536870/115540895-7e918100-a2d9-11eb-97a0-e264500d9712.png">

- 各Previewには [previewDisplayName](https://developer.apple.com/documentation/avkit/videoplayer/3580241-previewdisplayname) で名前をつけて表示することが可能です

<details>
    <summary>解説</summary>

まずはXcode Previews右上のDuplicateボタンからPreviewを複製します <br>
コードが以下のようになるはずです

```swift
struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoListView(
                viewModel: RepoListViewModel(
                    repoRepository: MockRepoRepository(
                        repos: [
                            .mock1, .mock2, .mock3, .mock4, .mock5
                        ]
                    )
                )
            )
            RepoListView(
                viewModel: RepoListViewModel(
                    repoRepository: MockRepoRepository(
                        repos: [
                            .mock1, .mock2, .mock3, .mock4, .mock5
                        ]
                    )
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
                viewModel: RepoListViewModel(
                    repoRepository: MockRepoRepository(
                        repos: []
                    )
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
                viewModel: RepoListViewModel(
                    repoRepository: MockRepoRepository(
                        repos: [],
                        error: DummyError()
                    )
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

![スクリーンショット 2021-05-03 19 00 48](https://user-images.githubusercontent.com/8536870/116863884-eaf97200-ac41-11eb-8839-60437253d5e3.png)


</details>

### 前セッションとのDiff
[session-3.2...session-3.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.2...session-3.3)

## Next
To be continued...
