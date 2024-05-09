## 3.1. Single Source of Truth
- SwiftUIが発表されたWWDC19のセッションの一つである [Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226) では以下のような図を用いてSwiftUIにおけるデータのフローについて説明されました

<img src="https://user-images.githubusercontent.com/8536870/115537484-cf9f7600-a2d5-11eb-8b60-0847e186f288.png">

- 手続き的にUIを更新するのではなく、宣言的に定義されたView関数がStateを入力として受け取りレイアウトを構築するSwiftUIでは、「Single Source of Truth」の概念が謳われており、Viewに反映されるデータは常に一意になることを原則としています
- これまで書いてきたコードを見てみると、リポジトリ一覧画面とリポジトリ詳細画面のどちらも`ReposStore`にある(`state`に含まれている)リポジトリ情報を参照しており、実はSingle Source of Truthに則っていることがわかります。
  - 何が嬉しいかというと、将来リポジトリ詳細画面にリポジトリ情報を更新する機能をもたせたとしても、リポジトリ一覧画面にもその変更が反映&viewが更新されることが保障されます。リポジトリ一覧画面とリポジトリ詳細画面とでデータの不整合が生じることはありません。
  - 本研修では時間の都合上深掘りしませんが、プロパティとViewとを双方向に連携する[@Binding](https://developer.apple.com/documentation/swiftui/binding)という機能を使用します。興味がある方はドキュメントにあるサンプルコードを読んでみてください。

![image](https://github.com/mixigroup/ios-swiftui-training/assets/13087887/69be15b9-c834-44f1-9794-a79abaf04fd3)

- また、大規模アプリケーションの開発現場では、UIロジックを担うPresentation Layer、業務ロジックを担うDomain Layer、永続化やAPIとのやりとり等を担うData Layerの3つに処理を分類し、必要に応じて更に責務の分離とクラスの作成を行うことが多いです。
- この研修で開発するアプリの要件は極めてシンプルであるため、上記のレイヤー分けを適用せずに必要最小限の責務の分離を行うことにしましょう。

|名称|責務|
|---|---|
|View|・ユーザーのアクションや画面描画アクションをStoreに通知<br/>・Storeがもっているstateを画面に表示|
|Store|Viewからアクションを受け取ってstateを更新し、viewに更新が必要な旨を通知|
|APIClient|WebAPIへのリクエスト、レスポンスとHTTP関連のエラーハンドリング|

### チャレンジ

- 以下のように責務の分離を行いリファクタリングしてみましょう。

|名称|責務|
|---|---|
|RepoListView|・UIイベントReposStoreに通知<br/>・ReposStoreのStateをバインドしてリポジトリ一覧を表示|
|ReposStore|・RepoListViewからonAppearのイベントを受け取り、RepoAPIClientを使ってリポジトリ一覧を取得する<br/>・取得したリポジトリ一覧をもとにstateを計算し、Viewに公開|
|RepoAPIClient|GitHub APIを叩いてmixi GroupのOrganizationにあるpublicなリポジトリ一覧を取得する|

#### ヒント
- 各モジュールのI/Fは以下のようになる想定です

```swift
@Observable
class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    ...

    func send(_ action: Action) async {...}
}

struct RepoAPIClient {
    func getRepos() async throws -> [Repo]
}
```

(今回解説は特に用意していません、 `前セッションとのDiff` を眺めてどのようにコードが整理されたかを俯瞰してみてみてください)

### 前セッションとのDiff
[session-2.3..session-3.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.3..session-3.1)

## Next
[3.2. XCTest](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.2/README.md)
