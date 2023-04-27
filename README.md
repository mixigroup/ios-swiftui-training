## 3.1. MVVMアーキテクチャ
- SwiftUIが発表されたWWDC19のセッションの一つである [Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226) では以下のような図を用いてSwiftUIにおけるデータのフローについて説明されました

<img src="https://user-images.githubusercontent.com/8536870/115537484-cf9f7600-a2d5-11eb-8b60-0847e186f288.png">

- 手続き的にUIを更新するのではなく、宣言的に定義されたView関数がStateを入力として受け取りレイアウトを構築するSwiftUIでは、「Single source of truth」の概念が謳われており、Viewに反映されるデータは常に一意になることを原則としています
- 先のセッションのように何の規約もなく自由にViewのファイルに通信処理周りを書いたりしていけば、ロジックや画面数が増えるほどに管理される状態は煩雑になり、管理コストが増していくことでしょう
- そうならないためにも、設計の力を借りてコードに規約を課していくのが良いです
- 今回みなさんに導入していただく設計はMVVMです
- Model View ViewModelの略称であるMVVMですが、図にすると以下のようなアーキテクチャになります

<img src="https://user-images.githubusercontent.com/8536870/115537612-f2ca2580-a2d5-11eb-937a-98ea74da920f.png">

- それぞれの責務は以下のようになります

  - Model
    - データの処理
  - View
    - UIのレイアウト
    - ユーザーのアクションをViewModelへInput
    - ViewModelのOutputをUIへバインド
  - ViewModel
    - ViewのInputに応じてModelを呼び出してViewのStateを管理
    - Stateを加工してViewへOutput

- これだとModel部分の実装方針がやや抽象的ですね
- 実務では、Model部分をデータソースを抽象化する`Repository`やアプリケーションロジックを持つ`UseCase`など具体的にレイヤー化されているケースが多いと思います
- 本アプリにおいては、API通信周りの処理がModelに当たります

### チャレンジ

- 以下のような責務になるように、MVVMの設計を適用してみましょう

- RepoListView
    - RepoListViewModelのStateをバインドしてリポジトリ一覧を表示
- RepoListViewModel
    - RepoListViewからonAppearのイベントを受け取り、RepoAPIClientを使ってリポジトリ一覧を取得する
    - 取得したリポジトリ一覧を@PublishedでViewに公開
- RepoAPIClient
    - GitHub APIを叩いてmixi GroupのOrganizationにあるpublicなリポジトリ一覧を取得する

#### ヒント
- 各モジュールのI/Fは以下のようになる想定です

```swift
class RepoListViewModel: ObservableObject {
    func onAppear() async
    func onRetryButtonTapped() async
}

struct RepoAPIClient {
    func getRepos() async throws -> [Repo]
}
```

(今回解説は特に用意していません、 `前セッションとのDiff` を眺めてどのようにコードが整理されたかを俯瞰してみてみてください)

### 前セッションとのDiff
[session-2.3..session-3.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.3..session-3.1)

## Next
[3.2. XCTest](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.2)
