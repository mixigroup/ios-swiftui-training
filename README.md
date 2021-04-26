## 1.2. 画像を表示
- Assetsを追加して画像を表示してみましょう
- https://github.com/logos からGitHub markをダウンロードしてください

<img src="https://user-images.githubusercontent.com/8536870/115510465-bd640e80-a2ba-11eb-8490-bacf4df5c012.png" height=500>

- `GitHub-Mark-120px-plus.png` を `Assets.xcassets` に向けてdrag&dropしてください

<img src="https://user-images.githubusercontent.com/8536870/115510540-d53b9280-a2ba-11eb-97f7-ebd7345aae59.png" height=500>

- 名前を `GitHubMark` に変更しつつ、下図のように `Single Scale` にしてください

<img src="https://user-images.githubusercontent.com/8536870/115510613-eb495300-a2ba-11eb-9bf8-8e96b2b3e07b.png">

- ⚠︎ 本来は `Individual Scales` で解像度ごとに3つのサイズの画像を用意することが望まれますが、今回は研修ということで `Single Scale` にしています
    - さらに言うならば、ロゴのようなベクター形式で吐き出せる画像は `.svg` 形式(iOS13未満サポートの場合は `.pdf` 形式)で追加することで、3枚の画像サイズを用意する必要がなくなるため理想的です

- さて、画像の準備ができたので実際に表示してみましょう
- `ContentView` を開いて [Image](https://developer.apple.com/documentation/swiftui/image) をVStackの先頭に追加してください
- Imageへの引数には先ほど追加した `GitHubMark` を指定します

<img src="https://user-images.githubusercontent.com/8536870/115510706-061bc780-a2bb-11eb-82e6-00404eef74cf.png" height=500>

- PreviewからImageを選択して右側のペインのFrameにてWidth, Heightをそれぞれ44に設定しましょう
- 設定したのに画像のサイズが変わらないことに気づくでしょう
- 画像がリサイズ可能になるように、 `.resizable` のmodifierをImageに追加しましょう

```swift
Image("GitHubMark")
    .resizable()
    .frame(width: 44.0, height: 44.0)
```

<img src="https://user-images.githubusercontent.com/8536870/115510756-16cc3d80-a2bb-11eb-9983-c212dc188003.png" height=500>

### チャレンジ
- 下図のようなレイアウトになるように修正してみてください

<img src="https://user-images.githubusercontent.com/8536870/115510855-319eb200-a2bb-11eb-806e-bb2cc45bd923.png" height=500>

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
[session-1.1...session-1.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.1...session-1.2)

## Next
[1.3. リスト表示](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.3)
