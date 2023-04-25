## 1.2. 画像を表示
- Assetsを追加して画像を表示してみましょう
- https://github.com/logos からGitHub markをダウンロードしてください

<img width="964" alt="GitHub_Logos_and_Usage" src="https://user-images.githubusercontent.com/17004375/234170917-342ee0fb-bfe6-48ab-bc26-90432dea3dab.png">

- `github-mark.svg` を `Assets` に向けてdrag&dropしてください

![github-mark_と_GitHubClient_—_Assets_xcassets](https://user-images.githubusercontent.com/17004375/234171283-26d86057-6caf-40b2-a4cc-b64e18e3d4aa.png)

- 名前を `GitHubMark` に変更しつつ、下図のように `Single Scale` にしてください
    - 今回はsvg形式の画像を追加しているので、3枚の画像サイズを用意する必要がないためです

![スクリーンショット_2023-04-25_13_03_10](https://user-images.githubusercontent.com/17004375/234171708-1b7898b7-0b8b-4a90-9083-4dfb5218f0ce.png)

- さて、画像の準備ができたので実際に表示してみましょう
- `ContentView` を開いて [Image](https://developer.apple.com/documentation/swiftui/image) に`GitHubMark`を指定し、modifierは一旦全て消します

```swift
...
HStack {
    Image("GitHubMark")
    Text("Hello, world!")
}
...
```

![スクリーンショット 2023-04-25 13 14 42](https://user-images.githubusercontent.com/17004375/234172933-2bad056a-0b4c-45c7-8fe0-81b7d9ade1c2.png)

- 画像が大きいので、サイズを指定しましょう
- PreviewからImageを選択して右側のペインのFrameにてWidth, Heightをそれぞれ44に設定しましょう
- 設定したのに画像のサイズが変わらないことに気づくでしょう
- 画像がリサイズ可能になるように、 `.resizable` のmodifierをImageに追加しましょう

```swift
Image("GitHubMark")
    .resizable()
    .frame(width: 44.0, height: 44.0)
```

![スクリーンショット 2023-04-25 13 17 20](https://user-images.githubusercontent.com/17004375/234173284-f39e0018-2503-4651-9716-477dd0165c01.png)

- 意図したサイズに調整できました👍

### チャレンジ
- 下図のようなレイアウトになるように修正してみてください

![スクリーンショット 2023-04-25 13 23 25](https://user-images.githubusercontent.com/17004375/234174095-de50bdff-3157-4f3a-9f8a-b843a9118891.png)

- Textのフォントとウエイトはそれぞれ以下のような設定にしています
  - Owner Name:
    - font: caption
  - Repository Name:
    - font: body
    - weight: semibold

<details>
    <summary>解説</summary>
画像とテキストを横に並べる必要があるので、以下のようにHStackを使う必要があります

```swift
HStack {
    Image("GitHubMark")
        .resizable()
        .frame(
            width: 44.0,
            height: 44.0
        )
    VStack(alignment: .leading) {
        Text("Owner Name")
            .font(.caption)
        Text("Repository Name")
            .font(.body)
            .fontWeight(.semibold)
    }
} 
```
</details>

### 前セッションとのDiff
[session-1.1..session-1.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.1..session-1.2)

## Next
[1.3. リスト表示](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.3)
