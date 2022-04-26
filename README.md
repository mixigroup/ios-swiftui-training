## 前準備
- 前準備として、これから実装を追加していくプロジェクトファイルを作成します
- まずはXcodeを開いてください
- 下図のようなウィンドウが開くので `Create a new Xcode project` から新規にプロジェクトを作成してください

<img width="813" alt="スクリーンショット_2022-04-26_20_18_33" src="https://user-images.githubusercontent.com/17004375/165288676-bcbe0fd2-9839-4d2a-9f14-9a20d1a77f28.png">

- すると以下のようなウィンドウが開くので `App` を選択してください

<img width="1099" alt="スクリーンショット_2022-04-26_20_08_38" src="https://user-images.githubusercontent.com/17004375/165288197-1ce157aa-c483-4e4a-9cca-d8ff88a1adff.png">


- 以下のようにそれぞれ入力した上で `Next` を押して適当なフォルダに保存してください

<img width="1099" alt="スクリーンショット 2022-04-26 20 09 47" src="https://user-images.githubusercontent.com/17004375/165288323-68aba3c5-c330-4cd1-b5d8-82217b03d0b9.png">

- 一応各項目について簡単に説明しておきます
    - Product Name: プロダクトの名前、この名前がデフォルトでアプリ名として表示されるが、もちろん変更可能
    - Team: アプリを管理するチーム
    - Organization Identifier: 組織の識別子、ユニークである必要がある、基本的には所属している組織が保有しているドメインを逆から並べたものを指定
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
