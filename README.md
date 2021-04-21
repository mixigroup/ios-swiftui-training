## 2.3. エラーハンドリング
- 通信は必ず成功するものではありません、そして仮に失敗した場合にはしっかりエラーをハンドリングしてユーザーがそれを理解できるように示してあげる必要があります
- 先のセッションで実装したURLSession周りの処理で必ずErrorをthrowするようにしてみましょう

```swift
            .tryMap() { element -> Data in
//                guard let httpResponse = element.response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
//                }
//                return element.data
            }
```
    
- この状態で `⌘ + R` でSimulatorを起動してみてください
- ずっとloadingのままであることがわかります、これだとユーザーは何が起きたか理解できないどころか、エラーから復帰することもできません
- throwされたErrorをキャッチするにはSinkの `receiveCompletion` にて処理を記述します
- 以下のようにSwitch文で [Subscribers.Completion](https://developer.apple.com/documentation/combine/subscribers/completion) からエラーをハンドリングします

```swift
.sink(receiveCompletion: { completion in
    switch completion {
    case .failure(let error):
        print("Error: \(error)")
    case .finished: print("Finished")
    }
}
```

### チャレンジ
- エラーをキャッチした際には以下のようなエラー画面を表示しましょう
<img src="https://user-images.githubusercontent.com/8536870/115537014-5869e200-a2d5-11eb-976b-ca4612adfba7.png" height=500>

- リトライボタンの表示には [Button](https://developer.apple.com/documentation/swiftui/button) を使用してください
- リトライボタンを押すと再びリポジトリ一覧を取得しつつ、その最中はloadingを表示させてください
- もし取得したリポジトリが空の場合には以下のように空であることを示してください

<img src="https://user-images.githubusercontent.com/8536870/115537090-6e77a280-a2d5-11eb-801a-03e8b99fc87d.png" height=500>

### 前セッションとのDiff
[session-2.2...session-2.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.2...session-2.3)

## Next
[3.1. MVVMアーキテクチャ](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.1)
