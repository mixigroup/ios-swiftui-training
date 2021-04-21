## 前準備
- 前準備として、これから実装を追加していくプロジェクトファイルを作成します
- まずはXcodeを開いてください
- 下図のようなウィンドウが開くので `Create a new Xcode project` から新規にプロジェクトを作成してください

![image](https://user-images.githubusercontent.com/8536870/115506402-c6061600-a2b5-11eb-87af-ee70138481d5.png)

- すると以下のようなウィンドウが開くので `App` を選択してください

![image](https://user-images.githubusercontent.com/8536870/115506461-d61df580-a2b5-11eb-9e74-f93792f8604c.png)

- 以下のようにそれぞれ入力した上で `Next` を押して適当なフォルダに保存してください

![image](https://user-images.githubusercontent.com/8536870/115506518-e635d500-a2b5-11eb-844c-fdc54bd090de.png)

- 一応各項目について簡単に説明しておきます
    - Product Name: プロダクトの名前、この名前がデフォルトでアプリ名として表示されるが、もちろん変更可能
    - Team: アプリを管理するチーム
    - Organization Identifier: 組織の識別子、ユニークである必要がある、基本的には所属している組織が保有しているドメインを逆から並べたものを指定
    - Bundle Identifier: アプリを一意に識別する文字列、Organization IdentifierにProduct Nameをくっつけたものになる
    - Interface: SwiftUI, Storyboardから選択できる
    - Life Cycle: SwiftUI App, UIKit App Delegateから選択できる
    - Language: SwiftUIを選択しなかった場合にはSwift以外にObjective-Cを選択可能
    - Use Core Data: Local DBにCore Dataを採用する場合、チェックを入れておくとCore Data周りのファイルをいくつか用意してくれる
    - Include Tests: チェックを入れておくとテスト用のターゲットも追加してくれる


- `GitHubClientApp` はアプリを起動したときのエントリーポイントになります
- この場合 `WindowGroup` で囲われている `ContentView()` が一番最初に表示されるViewとなります
```swift:GitHubClientApp.swift
@main
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Next
[1.1. 簡単なレイアウトを組む](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.1)
