## 1.1. 簡単なレイアウトを組む
- `ContentView` を開いて、右上の `Resume` ボタンを押してXcode Previewsを起動してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115507337-f26e6200-a2b6-11eb-90a1-bad00fcba348.png" height=500>

- Previewのビルドが完了すると以下のような表示が確認できますね

<img src="https://user-images.githubusercontent.com/8536870/115507424-12058a80-a2b7-11eb-946c-adbc2fa5e79d.png" height=500>

- 今 `ContentView` にはHello, world!という一つの [Text](https://developer.apple.com/documentation/swiftui/text) が配置されているだけになっています
- まずは「テキストを縦に二つ左揃えに並べる」ということをやってみましょう
- Previewのテキストを `⌘ + Click` で選択してみてください、すると以下のようにオプションがいくつか表示されます

<img src="https://user-images.githubusercontent.com/8536870/115507463-2184d380-a2b7-11eb-8b4e-7319f76369a3.png" height=500>

- この内 `Embed in VStack` を選択してください
- すると、以下のようにTextが [VStack](https://developer.apple.com/documentation/swiftui/vstack) で囲われていることがわかります

```swift
VStack {
    Text("Hello, world!")
        .padding()
}
```

- VStackは子要素を縦に並べてくれます (対して [HStack](https://developer.apple.com/documentation/swiftui/hstack) は子要素を横に並べてくれるものです)
- それではGood evening, world!というテキストをVStackに追加して縦に並べてみてください

<img src="https://user-images.githubusercontent.com/8536870/115507512-33667680-a2b7-11eb-803e-51bab6c31ffa.png" height=500>

- いい感じですね、では最後に「左揃え」にしてみましょう
- 以下のようにVStackを選択してください、右側のペインに `Alignment` という項目があるのがわかります

<img src="https://user-images.githubusercontent.com/8536870/115507549-3f523880-a2b7-11eb-838e-19635a4a66f2.png" height=500>

- 左揃えアイコンを選択してVStackを左揃えにしてください

<img src="https://user-images.githubusercontent.com/8536870/115507583-48dba080-a2b7-11eb-9cc5-0c42f8b8055a.png" height=500>

- 良さそうですね :+1:
- SwiftUIの魅力はなんと言ってもXcode PreviewsによるホットリロードでのViewの開発の生産性の高さにあります、使いこなして効率をあげましょう
- Preview経由で編集した際にコードベースでどういった差分が追加されたかもしっかり見て覚えておきましょう

### チャレンジ
- それぞれのTextのフォントサイズ, ウエイト, 色を変更してみましょう

### 前セッションとのDiff
[session-1-prepare...session-1.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1-prepare...session-1.1)

## Next
[1.2. 画像を表示](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.2)
