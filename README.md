## 0. Swiftの基本
- このセッションでは以降のセッションを円滑に進められるように最低限必要なSwift周りの知識について説明します
- 時間のある方は [公式のガイド](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) を一読することをお勧めします

### Playgroundの準備
- FinderでXcodeを見つけ、右クリックで出てくるWindowにある`Rosettaを使用して開く`のチェックを外します
    - チェックがついているとPlaygroundがうまく動作しない不具合があるため
    
<img width="396" alt="Notification_Center" src="https://user-images.githubusercontent.com/17004375/234561635-6baafc83-ef12-4719-b4e5-555de545accd.png">

- XcodeのPlaygroundでは、Swiftを簡単に実行することが可能です
- Swiftを学ぶにあたって、まずはPlaygroundを作成しましょう
- Xcodeを開いて `File > New > Playground` を選択します

<img src="https://user-images.githubusercontent.com/8536870/115705723-d696b900-a3a7-11eb-950f-8ad5fb63a71c.png" width=50%>

- Blankを選択した状態でNextを押下し適当な場所へ保存してください

<img src="https://user-images.githubusercontent.com/8536870/115705834-f8903b80-a3a7-11eb-876e-2301dd05af52.png">

- これで準備完了です、以降Swiftを学ぶ上で試したいコードがあればPlaygroundを開いて実行してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115705899-0e9dfc00-a3a8-11eb-933c-319db443afbf.png">

### 変数と定数
- Swiftでは変数を `var` ,定数を `let` で宣言します

```swift
var mutable = "Apple"
mutable = "Lemon"

let immutable = "Apple"
immutable = "Lemon"
// Error - Cannot assign to value: 'immutable' is a 'let' constant
```

### Optional
- `nil` (null)を安全に扱うための型として [Optional](https://developer.apple.com/documentation/swift/optional) が提供されています
```swift
@frozen enum Optional<Wrapped>
```

- この型は「値があるかもしれないしnilかもしれない」という状態を表現してくれます
- シンタックスシュガーとして `?` が用意されていて、直感的に宣言していくことが可能です

```swift
let longForm: Optional<Int> = Int("42")
let shortForm: Int? = Int("42")
```

- 「もし `nil` ではなければ...」という分岐を書く機会は多いでしょう、Swiftでは `Optional Binding` と呼ばれる書き方でスマートに処理を書くことができます

```swift
var optionalValue: Int? = 1
if let value = optionalValue {
    print("Value: '\(value)'")
} else {
    print("Couldn't bind an optional value")
}

// 変数名を変えない場合、このように書くこともできます
if let optionalValue {
    print("Value: '\(optionalValue)'")
} else {
    print("Couldn't bind an optional value")
}
```

- 「わざわざ値をOptionalから取り出さずに値を参照したい...」という機会も多いでしょう、その場合は `Optional Chaining` を使います

```swift
if optionalImagePath?.hasSuffix(".png") == true {
  print("The image is in PNG format")
}
```

- また、nilだった場合にはデフォルト値を返したい場合、 `??` を使うことで簡潔に書けます
```swift
// Optional Bindingを使った書き方
var result: Int
if let value = optionalValue {
  result = value
} else {
  result = 0
}

// ??を使った書き方
result = optionalValue ?? 0
```

- 必ずOptionalの中に値が入っているとわかる場合、 `!` を使って強制アンラップをすることが可能です

```swift
optionalValue = 1
let value = optionalValue!
```

- しかし、万が一nilに対して強制アンラップをしてしまうとexceptionを吐いてアプリがランタイムにクラッシュしてしまうので注意が必要です

```swift
optionalValue = nil
let value = optionalValue!
// error: Execution was interrupted, reason: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0).
```

### 関数
- 関数は以下のように定義します

```swift
func greet(person: String) -> String {
    let greeting = "Hello, " + person + "!"
    return greeting
}
```

- 一行のみの場合はreturnを省略することもできます

```swift
func greet(person: String) -> String {
    "Hello, " + person + "!"
}
```

- 関数の引数に呼び出し用の名前をつけて可読性をあげることも可能です

```swift
func greet(person: String, from hometown: String) -> String {
    "Hello \(person)!  Glad you could visit from \(hometown)."
}
print(greet(person: "Bill", from: "Cupertino"))
// Prints "Hello Bill!  Glad you could visit from Cupertino."
```

### クロージャ
- クロージャとは簡単にいうと受け渡しが可能な関数です
- 以下のような定義になります

```swift
{ (parameters) -> return type in
    statements
}
```

- Swiftではクロージャを受け取る関数が数多く用意されています、その一つの例が [sorted(by:)](https://developer.apple.com/documentation/swift/array/2296815-sorted) です
- 例えば、名前の配列を逆アルファベット順に並び替える処理は以下のようになります

```swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
var sortedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})

// 型推論
sortedNames = names.sorted(by: { s1, s2 in s1 > s2 })

// $による引数参照
sortedNames = names.sorted(by: { $0 > $1 } )

// 引数の最後がクロージャの場合、省略可能
sortedNames = names.sorted { $0 > $1 }
```

### enum
- Swiftのenumは以下のような定義になります

```swift
enum CompassPoint {
    case north
    case south
    case east
    case west
}

var point = CompassPoint.north
// 型推論で省略可
point = .south
```

- よくSwitch文と一緒に使います

```swift
let directionToHead: CompassPoint = .south
switch directionToHead {
case .north:
    print("Lots of planets have a north")
case .south:
    print("Watch out for penguins")
case .east:
    print("Where the sun rises")
case .west:
    print("Where the skies are blue")
}
// Prints "Watch out for penguins"

// defaultを指定可能
switch directionToHead {
case .north:
    print("Lots of planets have a north")
default: break
}
```

- SwiftのSwitch文にenumが渡された場合、すべてのcaseが網羅されていなければコンパイル時にエラーが出ます
- この性質はかなり優秀で、例えばenumに新しくcaseが追加された場合、いろんな箇所で定義されたSwitch文のエラーが出て修正箇所を明示してくれます
- default caseを用意してしまうとこの恩恵は失われてしまうので、極力使わずにすべてのcaseを丁寧に書いていくことが理想です

#### Associated Values
- 例えば、成功か失敗の状態を表すStateというenumを考え、失敗時のエラーを値として関連付けたいと考えます
- その場合のenumの定義は以下のようになります

```swift
enum State {
  case success
  case failure(Error)
}
```

- Switch文を用いてパターンマッチでエラーの値を取得します

```swift
struct DummyError: Error {}
let state: State = .failure(DummyError())
switch state {
case .success: print("Success")
case let .failure(error): print("Failure: \(error)")
}
```

### 構造体とクラス
- 構造体(struct)とクラス(class)はデータをモデリングする上で必ず必要となってくる機能です
- どちらもpropertyを定義して値を保持したり、メソッドを定義して処理を実行したりできます

```swift
struct SomeStructure {
    // structure definition goes here
}
class SomeClass {
    // class definition goes here
}
```

- Swiftでは基本的にはstructを使用することが推奨されています
- classは、保持するデータの一意性を担保する必要がある場合、あるいはObjective-Cとの互換性が必要な場合に使用するようにしてください
  - 参考: https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes

### 値型と参照型
- クラスとクロージャ以外で定義された型はすべて **値型** です、値の受け渡しはすべてコピーした上で行われます

```swift
struct SomeStructure {
  var value: Int
}

var a = SomeStructure(value: 1)
var b = a

b.value = 2

print("a: \(a.value)")
// a: 1
print("b: \(b.value)")
// b: 2
```

- クラスとクロージャは **参照型** です、値の受け渡しは参照で行われるため、例え異なる変数に格納されていても参照されるインスタンスは同じになります

```swift
class SomeClass {
  var value: Int
  
  init(value: Int) {
    self.value = value
  }
}

var a = SomeClass(value: 1)
var b = a

b.value = 2

print("a: \(a.value)")
// a: 2
print("b: \(b.value)")
// b: 2
```

- Swiftは値型中心の言語です、値がどこからともなく変更される可能性のある参照型よりも値型を使って安全にコーディングしていくことが良いとされています

#### ARC（本研修ではこれをあまり意識せずにできるので、スキップでもOK）
- Swiftのメモリは `ARC(Automatic Reference Counting)` によって管理されています
- 新しいインスタンスを初期化する際に、ARCはそのインスタンスの型や保有するプロパティに応じたメモリを確保します
- ARCはそれぞれのインスタンスがいくつのプロパティや変数, 定数から参照されているかをカウントし、その参照カウントがゼロにならない限りメモリは解放しないようになっています
- 例えば以下のコードをみてください

```swift
class Person {
    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 1
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 0
// Prints "Apartment is being deinitialized"
// Personの参照カウント: 0
// Prints "Person Tom is being deinitialized"
```

- `deinit` 時にprintすることでメモリが解放されるタイミングがわかるようになっています、コメントに書いた通りに参照カウントが推移し、0になるタイミングでそれぞれメモリが解放されてprintされていることが確認できます
- では、以下のように `Person` のpropertyに `Apartment` を持たせてみるとどうなるでしょうか

```swift
class Person {
    let name: String
    var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
        person.apartment = self
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 2
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 1
```

- `Person` と `Apartment` がお互いに参照して循環参照が完成してしまいました、これでは永遠にメモリが解放されることはありません
- これを解決するには **弱参照 (weak参照)** を用います

```diff
class Person {
    let name: String
+   weak var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}
```

- 弱参照は参照カウントに加算されません、よって循環参照を防ぎメモリリークを解消してくれます

### Protocols
- protocolは、特定の機能に適したメソッドやproperty等のI/Fを定義し、それをクラスや構造体, enumに適用することができます

```swift
protocol SomeProtocol {
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
    func someMethod()
}

// extensionによるprotocolのデフォルト実装
extension SomeProtocol {
    func someMethod() {
        print("someMethod called")
    }
}

// structへのprotocolの適用
struct SomeStructure: SomeProtocol {
    var mustBeSettable: Int
    let doesNotNeedToBeSettable: Int
}

protocol AnotherProtocol {
    func anotherMethod()
}

// extensionによるprotocolの適用
extension SomeStructure: AnotherProtocol {
    func anotherMethod() {
        print("anotherMethod called")
    }
}
```

- 例えば、同じような機能を複数箇所に持たせたい場合、間違ってもclassの継承を使って実現せずに、Swiftではprotocolによる共通化を心がけてください

### Generics
- Genericsを扱うことで、任意の型を扱うI/Fを定義できます
- 例えば、データの読み込み状態を表現するデータ構造を作りたいとします
- 状態にはすべてで4つあり、それぞれが以下のようなステータスとなります
  - idle: まだデータを取得しにいっていない
  - loading: 読み込み中
  - loaded: 読み込み完了、読み込まれたデータを保持
  - failed: 読み込み失敗、遭遇したエラーを保持

- これをGenericsで実装するならば以下のようになります

```swift
enum Stateful<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

var data: Stateful<[String]> = .idle
// データ取得中
data = .loading
// データ取得失敗
data = .failed(DummyError())
// データ取得完了
data = .loaded(["data1", "data2", "data3"])

// 他の型でも利用可能
var anotherData: Stateful<[Int]> = .loaded([1, 2, 3])
```

## Next
[1. SwiftUIの基本 -前準備-](https://github.com/mixigroup/ios-swiftui-training/tree/session-1-prepare)
