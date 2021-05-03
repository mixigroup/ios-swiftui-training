## 1.5. ライフサイクルと状態管理

- SwiftUIにおけるViewは状態を入力として受け取ってレイアウトを返す関数です
- UIを更新するためには直接Viewを追加したり編集したりするのではなく、入力である状態を変更してView関数の出力が変わるようにします
- 具体的なViewのライフサイクルについては https://www.vadimbulavin.com/swiftui-view-lifecycle/ より下図を引用します

<img src="https://user-images.githubusercontent.com/8536870/115531403-b4316c80-a2cf-11eb-962f-8d81b9aedda5.png">


- Appearing
  - 画面が表示されるタイミングで、まずはStateの監視を開始します
  - `View.body` メソッドの出力を元にレンダリングが走ります
  - その後、 [onAppear](https://developer.apple.com/documentation/swiftui/text/onappear(perform:)) メソッドが呼び出されます
- Updating
  - Stateに更新が走ると現在のViewGraphに差分が生じるかの確認が入り、変更がなければ再レンダリングは走りません
  - ViewGraphに変更がある場合には `View.body` の出力をもとにレンダリングが走ります
- Disappearing
  - 画面が消えるタイミングで [onDisappear](https://developer.apple.com/documentation/swiftui/text/ondisappear(perform:)) が呼ばれます

- あまりピンとこないかもしれないので、実際にコードを書いて学んでみましょう
- 今 `RepoListView` には `mockRepos` が最初から定義されていてリポジトリ一覧が表示されています
- しかし本来ならば、Viewが表示されるタイミングでAPIにリポジトリ一覧取得のリクエストを投げて、正常にレスポンスを受け取ることができて初めてリポジトリ一覧が表示可能になります
- APIリクエスト周りは次のセッションで説明するとして、まずは擬似的にリポジトリを読み込む処理を書いてみましょう
- その前に、まずは `mockRepos` の状態を監視してViewに変更が反映されるようにしてみます
- [@State](https://developer.apple.com/documentation/swiftui/state) で `mockRepos` をannotateしてください
    - Stateは変更されることが前提なので、letではなくvarで変数として宣言する必要があります

```swift
@State private var mockRepos: [Repo] = [
    .mock1, .mock2, .mock3, .mock4, .mock5
]
```

- `mockRepos` は最初は空っぽにしつつ、 `loadRepos()` メソッドを宣言してモックデータを代入するようにします

```swift
struct RepoListView: View {
    @State private var mockRepos: [Repo] = []

    var body: some View { ... }

    private func loadRepos() {
        // 1秒後にモックデータを読み込む
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            mockRepos = [
                .mock1, .mock2, .mock3, .mock4, .mock5
            ]
        }
    }
}
```

- これでリポジトリ一覧が読み込まれたらbodyが描画されて一覧が表示されるようになりました
- リポジトリ一覧をViewが表示されたタイミングで読み込むように、 `onAppear` イベントを受け取って、そこで `loadRepos()` を呼んでみましょう

```swift
var body: some View {
    NavigationView {
        ...
    }
    .onAppear {
        loadRepos()
    }
}
```

- Live Previewにて空のViewが表示された一秒後にリポジトリ一覧が表示されたら成功です

### チャレンジ
- `mockRepos` を読み込み中(== 空のとき)には以下のように [ProgressView](https://developer.apple.com/documentation/swiftui/progressview) が表示されるようにしてみましょう

<img src="https://user-images.githubusercontent.com/8536870/115532071-6832f780-a2d0-11eb-93d6-5e3fa44200d2.png" height=500>

<details>
    <summary>解説</summary>
<code>mockRepos</code> が空の時は読み込み中の状態であると判断するために、 <code>var body</code> の中で分岐を作ってあげましょう
  
```swift
if mockRepos.isEmpty {

} else {
    List(mockRepos) {...}
}
```

あとは空状態の場合にはProgressViewを表示させれば良いわけです <br>
ここでProgressViewのイニシャライザ引数として文字列を渡すと、その文字列がプログレスの下側にその文字が表示されるようになります

```diff
if mockRepos.isEmpty {
+   ProgressView("loading...")
} else {
    List(mockRepos) {...}
}
```
</details>

### 前セッションとのDiff
[session-1.4...session-1.5](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.4...session-1.5)

## Next
[2.1. Combineによる非同期処理](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.1)
