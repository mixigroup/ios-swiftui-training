## 1.0 前準備
- 前準備として、これから実装を追加していくプロジェクトファイルを作成します
- まずはXcodeを開いてください
- 下図のようなウィンドウが開くので `Create a new Xcode project` から新規にプロジェクトを作成してください

<img width="811" alt="スクリーンショット_2022-04-26_21_09_42" src="https://user-images.githubusercontent.com/17004375/165296956-a0542cf4-d4bc-45e0-83c0-9437b4536f32.png">

- すると以下のようなウィンドウが開くので `iOS` の `App` を選択してください


<img width="1217" alt="スクリーンショット_2022-04-26_21_11_14" src="https://user-images.githubusercontent.com/17004375/165297357-d2bd9918-b532-40d8-a21b-0123d06a8007.png">


- 以下のようにそれぞれ入力した上で `Next` を押して適当なフォルダに保存してください

<img width="1217" alt="スクリーンショット_2022-04-26_21_14_04" src="https://user-images.githubusercontent.com/17004375/165297566-9df93555-2351-4832-9561-5a2a7467b600.png">


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
