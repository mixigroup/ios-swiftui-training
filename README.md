## 3.3. Xcode Previewsの再活用
- しばらくXcode PreviewsではなくSimulatorでデバッグしてきましたが、 `RepoListViewModel` にRepositoryがDI可能になったので、Previewではモックに置き換えて表示してみましょう
- まずは、テストファイルに定義したモックを `Preview Content/Mocks` 以下に移動させましょう
- 次に、 `RepoListView` にてViewModelをDependency Injection(DI)できるようにイニシャライザ引数から受け取るようにします

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

<img src="https://user-images.githubusercontent.com/8536870/115540895-7e918100-a2d9-11eb-97a0-e264500d9712.png" height=500>

- 各Previewには [previewDisplayName](https://developer.apple.com/documentation/avkit/videoplayer/3580241-previewdisplayname) で名前をつけて表示することが可能です

### 前セッションとのDiff
[session-3.2...session-3.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.2...session-3.3)

## Next
To be continued...
