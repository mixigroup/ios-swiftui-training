## 1.1. 簡単なレイアウトを組む
- `ContentView` を開くと、Previewsが表示されるはずです

![スクリーンショット 2023-04-25 6 39 26](https://user-images.githubusercontent.com/17004375/234122644-83f316e9-59f1-4d99-9c46-8f10d9bb7833.png)

- 今 `ContentView` には地球のようなアイコンとHello, world!というテキストが配置されているだけになっています
- コードを見ると[Image](https://developer.apple.com/documentation/swiftui/image)と[Text](https://developer.apple.com/documentation/swiftui/text)が[VStack](https://developer.apple.com/documentation/swiftui/vstack)で囲われていることがわかります
- ImageのsystemNameに渡されている `global`　は[SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/)の名前を指しています
    - SF Symbolsと呼ばれるアイコン集がAppleによって提供されているため、シンボル名を渡すだけで簡単に様々なアイコンを表示することができます
    - DynamicTypeと連動して大きさが変化したり、フォントのbaselineと揃えて表示できたりと便利なものになっています
- VStackは子要素を縦に並べてくれます (対して [HStack](https://developer.apple.com/documentation/swiftui/hstack) は子要素を横に並べてくれるものです)
- それではGood evening, world!というテキストをVStackに追加して縦に並べてみてください

<img src="https://user-images.githubusercontent.com/8536870/115507512-33667680-a2b7-11eb-803e-51bab6c31ffa.png" width=50%>

- いい感じですね、では最後に「左揃え」にしてみましょう
- 以下のようにVStackを選択してください、右側のペインに `Alignment` という項目があるのがわかります

<img src="https://user-images.githubusercontent.com/8536870/115507549-3f523880-a2b7-11eb-838e-19635a4a66f2.png">

- 左揃えアイコンを選択してVStackを左揃えにしてください

<img src="https://user-images.githubusercontent.com/8536870/115507583-48dba080-a2b7-11eb-9cc5-0c42f8b8055a.png" width=50%>

- 良さそうですね :+1:
- SwiftUIの魅力はなんと言ってもXcode PreviewsによるホットリロードでのViewの開発の生産性の高さにあります、使いこなして効率をあげましょう
- Preview経由で編集した際にコードベースでどういった差分が追加されたかもしっかり見て覚えておきましょう

### チャレンジ
- それぞれのTextのフォントサイズ, ウエイト, 色を変更してみましょう

<details>
 <summary>解説</summary>
 Previewで対象のテキストを選択した状態で、右側に表示されるペインにFontの項目があるので、そこで各種属性を設定しましょう
    
 <img src="https://user-images.githubusercontent.com/8536870/116014840-29a39100-a672-11eb-99e6-ae073c725a8d.png">
     
 左側のコードでどういったmodifierが付与されるかも併せてしっかり見ておきましょう
</details>

### 前セッションとのDiff
[session-1-prepare..session-1.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1-prepare..session-1.1)

## Next
[1.2. 画像を表示](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.2)
