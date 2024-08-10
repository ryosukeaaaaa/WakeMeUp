import SwiftUI
import SpriteKit
import SwiftyGif
// Arrayの拡張としてweightedRandomElementメソッドを追加
extension Array where Element == Item {
    func weightedRandomElement() -> Item? {
        let totalWeight = self.reduce(0.0) { $0 + $1.rarity.probability }
        let randomValue = Double.random(in: 0..<totalWeight)
        var cumulativeWeight = 0.0
        
        for item in self {
            cumulativeWeight += item.rarity.probability
            if randomValue < cumulativeWeight {
                return item
            }
        }
        return nil
    }
}

// GachaGIF1のインスタンス
struct GachaGIF: View {
    @ObservedObject var itemState: ItemState

    var body: some View {
        GachaGIFView(
            gachaData: NSDataAsset(name: "Gacha")!.data,
            ultraData: NSDataAsset(name: "Ultra")!.data,
            superRareData: NSDataAsset(name: "SuperRare")!.data,
            rareData: NSDataAsset(name: "Rare")!.data,
            normalData: NSDataAsset(name: "Normal")?.data,
            gachaImageName: "GachaIm",
            gachaResultFilter: nil,
            itemState: itemState
        )
    }
}

// GachaGIF2のインスタンス
struct GachaGIF2: View {
    @ObservedObject var itemState: ItemState

    var body: some View {
        GachaGIFView(
            gachaData: NSDataAsset(name: "Gacha2")!.data,
            ultraData: NSDataAsset(name: "Ultra")!.data,
            superRareData: NSDataAsset(name: "SuperRare")!.data,
            rareData: NSDataAsset(name: "Rare")!.data,
            normalData: nil,
            gachaImageName: "Gacha2Im",
            gachaResultFilter: { $0.rarity != .Normal },
            itemState: itemState
        )
    }
}

func shareOnTwitter() {

    //シェアするテキストを作成
    let text = "AppからTwitterでシェアする"
    let hashTag = "#ハッシュタグ"
    let completedText = text + "\n" + hashTag

    //作成したテキストをエンコード
    let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

    //エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
    if let encodedText = encodedText,
        let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
        UIApplication.shared.open(url)
    }
}


private extension GeometryProxy {
    var sizeWithSafeArea: CGSize {
        .init(
            width: self.size.width + self.safeAreaInsets.trailing + self.safeAreaInsets.leading,
            height: self.size.height + self.safeAreaInsets.top + self.safeAreaInsets.bottom
        )
    }
}

struct GachaGIFView: View {
    @State private var playgacha: Bool = false
    @State private var currentGifData: Data? = nil
    @State private var resultItem: Item? = nil
    @State private var showResult = false
    @State private var shakeOffset: CGFloat = 0
    @State private var isShaking: Bool = false
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    @State private var showAlert = false  // アラート表示用の状態変数
    @State private var showShareButton = false  // シェアボタン表示用の状態変数
    @State private var showGachaButton = true  // 「ガチャを引く」ボタンと所持枚数の表示状態
    @State private var skipAnimation = false  // 演出スキップのフラグ
    @State private var hideNavigationBar = false  // NavigationBarを非表示にする状態変数
    @Environment(\.presentationMode) var presentationMode  // 前のビューに戻るための環境変数

    let gachaData: Data
    let ultraData: Data
    let superRareData: Data
    let rareData: Data
    let normalData: Data?
    let gachaImageName: String
    let gachaResultFilter: ((Item) -> Bool)?

    @ObservedObject var itemState: ItemState

    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    SpriteView(
                        scene: self.createRainParticleScene(size: geometry.sizeWithSafeArea),
                        options: [.allowsTransparency]
                    ).edgesIgnoringSafeArea(.all)
                }
                if playgacha {
                    gachaAnimation()
                } else if let resultItem = resultItem {
                    VStack {
                        Text("\(resultItem.rarity.rawValue)")
                            .font(.title)
                            .padding()
                            .onAppear {
                                startTextAnimation("Rarity: \(resultItem.rarity.rawValue)")
                            }
                        Image(resultItem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 400)
                            .offset(x: shakeOffset)
                            .onAppear {
                                startShaking()
                            }
                        Text(resultItem.name)
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                } else {
                    Image(gachaImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                }
                
                VStack{
                    Spacer()
                    if showShareButton {
                        Button(action: {
                            if let item = resultItem {
                                shareOnTwitter(with: item)
                            }
                        }) {
                            Text("Xでシェアしてもう一回")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("前のビューに戻る")
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if showGachaButton {
                        Button(action: {
                            showAlert = true  // アラートを表示する
                        }) {
                            Text("ガチャを引く")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("確認"),
                                message: Text("本当にガチャを引きますか？"),
                                primaryButton: .default(Text("はい"), action: {
                                    showGachaButton = false // ボタンと所持枚数を非表示にする
                                    hideNavigationBar = true // バックボタンを非表示にする
                                    startGacha()
                                }),
                                secondaryButton: .cancel(Text("いいえ"))
                            )
                        }
                    }
                    
//                    if showGachaButton {
//                        Text("所持枚数: \(itemState.SpecialCoin)")
//                            .foregroundColor(.blue)
//                    }
                    // 演出スキップボタンを追加
                    if playgacha {
                        Spacer()
                        HStack {
                            Button(action: {
                                skipAnimation = true
                                finishGacha()
                            }) {
                                Text("スキップ")
                                    .padding()
                                    .background(Color.gray.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("所持コイン: \(itemState.SpecialCoin)")
                    .foregroundColor(.blue)
            }
        }
        .navigationBarBackButtonHidden(hideNavigationBar)  // バックボタンの表示/非表示を制御
    }

    private func createRainParticleScene(size: CGSize) -> SKScene {
        let emitterNode = SKEmitterNode(fileNamed: "RainParticle")!
        let scene = SKScene(size: size)
        scene.addChild(emitterNode)
        scene.backgroundColor = .clear
        scene.anchorPoint = .init(x: 0.7, y: 1)
        return scene
    }

    @ViewBuilder
    func gachaAnimation() -> some View {
        if let gifData = currentGifData {
            GIFImage(data: gifData)
                .frame(height: 400)
                .onAppear {
                    if currentGifData == gachaData && !skipAnimation {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            switch resultItem?.rarity {
                            case .Ultra:
                                currentGifData = ultraData
                            case .SuperRare:
                                currentGifData = superRareData
                            case .Rare:
                                currentGifData = rareData
                            default:
                                currentGifData = normalData
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                                self.finishGacha()
                            }
                        }
                    } else if skipAnimation {
                        self.finishGacha()
                    }
                }
        } else {
            Text("Failed to load GIF")
                .frame(height: 400)
        }
    }

    private func startGacha() {
        spinGacha()  // ボタンを押した瞬間にアイテムを決定
        playgacha = true
        currentGifData = gachaData
        showShareButton = false
        showAlert = false
    }

    private func finishGacha() {
        playgacha = false
        showResult = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { // 11.5秒後にシェアボタンを表示
            showShareButton = true
        }
    }

    private func spinGacha() {
        let items: [Item]
        if let filter = gachaResultFilter {
            items = itemState.ItemSources.filter(filter)
        } else {
            items = itemState.ItemSources
        }
        if let item = items.weightedRandomElement() {
            resultItem = item
            itemState.addItem(item)
        }
    }

    private func startShaking() {
        withAnimation(Animation.easeInOut(duration: 0.05).repeatCount(20, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            shakeOffset = 0
        }
    }
    
    private func startTextAnimation(_ text: String) {
        var currentIndex = 0
        displayedText = ""
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentIndex < text.count {
                displayedText.append(text[text.index(text.startIndex, offsetBy: currentIndex)])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func shareOnTwitter(with item: Item) {
        // シェアするテキストを作成
        let text = "英語を発音しないと止まらないアラーム!?\n当たったのは: \(item.name)\nレアリティ: \(item.rarity.rawValue)"
        let hashTag = "#朝単"
        let completedText = text + "\n" + hashTag
        
        // 作成したテキストをエンコード
        let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        // エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}
