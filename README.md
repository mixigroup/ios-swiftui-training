## 3.1. MVVMアーキテクチャ
- SwiftUIが発表されたWWDC19のセッションの一つである [Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226) では以下のような図を用いてSwiftUIにおけるデータのフローについて説明されました

<img src="https://user-images.githubusercontent.com/8536870/115537484-cf9f7600-a2d5-11eb-8b60-0847e186f288.png" height=500>

- 手続き的にUIを更新するのではなく、宣言的に定義されたView関数がStateを入力として受け取りレイアウトを構築するSwiftUIでは、「Single source of truth」の概念が謳われており、Viewに反映されるデータは常に一意になることを原則としています
- 先のセッションのように何の規約もなく自由にViewのファイルに通信処理周りを書いたりしていけば、ロジックや画面数が増えるほどに管理される状態は煩雑になり、管理コストが増していくことでしょう
- そうならないためにも、設計の力を借りてコードに規約を課していくのが良いです
- 今回みなさんに導入していただく設計はMVVMです
- Model View ViewModelの略称であるMVVMですが、図にすると以下のようなアーキテクチャになります

<img src="https://user-images.githubusercontent.com/8536870/115537612-f2ca2580-a2d5-11eb-937a-98ea74da920f.png" height=500>

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
- MVVMはAndroidアプリを開発する上でも推奨されているアーキテクチャであるため、そちらで説明する際に用いられている図も引用します (https://developer.android.com/jetpack/guide#recommended-app-arch より)

<img src="https://user-images.githubusercontent.com/8536870/115537744-18572f00-a2d6-11eb-8d24-1e4f22d2701b.png" height=500>

- Repositoryは、Webやlocal DBで処理した結果をViewModelへ返す役割をしています
- これにより、ViewModelは与えられたデータがWeb or DBからの値かを意識せずに、Viewの状態管理に専念できます

### チャレンジ

- 以下のような構成になるように、MVVMの設計を適用してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115538875-4ab55c00-a2d7-11eb-8904-b240f36ce06b.png" height=500>

- RepoListView
    - RepoListViewModelのStateをバインドしてリポジトリ一覧を表示
- RepoListViewModel
    - RepoListViewからonAppearのイベントを受け取って、RepoRepositoryにリポジトリ一覧を取得させる
    - 取得したリポジトリ一覧を@PublishedでViewに公開
- RepoRepository
    - RepoAPIClientを呼び出して、リポジトリ一覧を取得する
- RepoAPIClient
    - GitHub APIを叩いてmixi GroupのOrganizationにあるpublicなリポジトリ一覧を取得する

#### ヒント
- 各モジュールのI/Fは以下のようになる想定です

```swift
class RepoListViewModel: ObservableObject {
    func onAppear()
    func onRetryButtonTapped()
}
    
struct RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error>
}

struct RepoAPIClient {
    func getRepos() -> AnyPublisher<[Repo], Error>
}
```
    
- [AnyPublisher](https://developer.apple.com/documentation/combine/anypublisher) とは、上流のPublisherを型消去のためにwrapしたもので、APIをまたいでPublisherを受け渡ししたい際に用いられます
- 例えば、「URLSession.dataTaskPublisher → tryMap → decode」によって最終的に返される型は `Publishers.Decode<Publishers.TryMap<URLSession.DataTaskPublisher, JSONDecoder.Input>, [Repo], JSONDecoder>` になります
- この型情報をAPIClient層からRepository層へ公開してしまうと、例えば新しくAPIClient側でpublisherの実装を変更した時に型が変わってしまいRepository層まで影響してしまいます、AnyPubliserに変換して型情報を隠蔽してあげるのが良いでしょう
- AnyPubliserに変換したい場合には [eraseToAnyPublisher](https://developer.apple.com/documentation/combine/just/erasetoanypublisher()) メソッドを使ってみてください

### 前セッションとのDiff
[session-2.3...session-3.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.3...session-3.1)

## Next
[3.2. XCTest](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.2)
