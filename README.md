## 1.1. 簡単なレイアウトを組む
- `ContentView` を開くと、Previewsが表示されるはずです

![スクリーンショット 2023-04-25 6 39 26](https://user-images.githubusercontent.com/17004375/234122644-83f316e9-59f1-4d99-9c46-8f10d9bb7833.png)

- 今 `ContentView` には地球のようなアイコンとHello, world!というテキストが配置されているだけになっています
- コードを見ると[Image](https://developer.apple.com/documentation/swiftui/image)と[Text](https://developer.apple.com/documentation/swiftui/text)が[VStack](https://developer.apple.com/documentation/swiftui/vstack)で囲われていることがわかります
- ImageのsystemNameに渡されている`global`は[SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/)の名前を指しています
    - SF Symbolsと呼ばれるアイコン集がAppleによって提供されているため、シンボル名を渡すだけで簡単に様々なアイコンを表示することができます
    - DynamicTypeと連動して大きさが変化したり、フォントのbaselineと揃えて表示できたりと便利なものになっています
- VStackは子要素を縦に並べてくれます
- 対して [HStack](https://developer.apple.com/documentation/swiftui/hstack) は子要素を横に並べてくれます
- 試しにVStackをHStackに変えてみましょう

![スクリーンショット 2023-04-25 10 56 37](https://user-images.githubusercontent.com/17004375/234155549-166b8e65-ee23-4d58-a5a8-1889e79bff6a.png)

- 横並びになりましたね
- 次に`⌘`を押しながらHStackをクリックし、`Embed in VStack` を選択してください

![スクリーンショット_2023-04-25_11_02_08](https://user-images.githubusercontent.com/17004375/234156434-ef413c9b-4a56-4bc0-b201-09fcbf70710f.png)

- これで、HStackがVStackに囲われました
- Good evening, world!というテキストをHStackの下に追加して縦に並べてみましょう

![スクリーンショット 2023-04-25 11 09 00](https://user-images.githubusercontent.com/17004375/234157017-b1719951-2ce1-46aa-90f1-5dc02120f112.png)

- では最後に「左揃え」にしてみましょう
- まず、Previewのモードを `Selectable`　に切り替えます

|モード|説明|
|-|-|
|![スクリーンショット 2023-04-25 12 15 26](https://user-images.githubusercontent.com/17004375/234165716-6e96164c-40d1-4783-92b4-e3d7ba757f6d.png)　Live|Viewのアニメーションや画面遷移などの動きも確認することができる|
|![スクリーンショット 2023-04-25 12 16 41](https://user-images.githubusercontent.com/17004375/234165879-4c0d5e67-6b51-4abb-aead-c271c7f21f56.png)　Selectable|各Viewを選択できる、選択したViewの領域なども確認できる|

- Preview上でHStackを選択します

![スクリーンショット 2023-04-25 12 21 44](https://user-images.githubusercontent.com/17004375/234166484-c9a92dff-d823-4745-be44-a4c6d31ce514.png)

- どうやらHStackには余白があるようです
- これは`.padding()`によるもので、左寄せがわかりにくくなってしまうのでここで`.padding()`を削除しておきます

![スクリーンショット 2023-04-25 12 26 02](https://user-images.githubusercontent.com/17004375/234167415-5a223db6-2f73-46de-9808-6fdc76206a2f.png)

- 次にVStackを選択し、右側のペインの `Alignment` という項目で左寄せのアイコンを選択します

![スクリーンショット_2023-04-25_12_35_16](https://user-images.githubusercontent.com/17004375/234168552-c2121184-293d-4b35-95f9-2ffa7437c0e5.png)

```swift
VStack(alignment: .leading) {
    HStack {
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundColor(.accentColor)
        Text("Hello, world!")
    }

    Text("Good evening, world!")
}
```

- VStackに`(alignment: .leading)`が追加され、左寄せになりました :+1:
- SwiftUIの魅力の一つはXcode PreviewsによるホットリロードでのUI実装の生産性の高さです、使いこなして効率をあげましょう
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
[session-1.0..session-1.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.0..session-1.1)

## Next
[1.2. 画像を表示](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.2)
