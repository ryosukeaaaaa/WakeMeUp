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


// GachaGIF構造体の定義
struct GachaGIF: View {
    @State private var playgacha: Bool = false
    @State private var currentGifData: Data? = nil
    @State private var resultItem: Item? = nil
    @State private var showResult = false
    @State private var shakeOffset: CGFloat = 0
    @State private var isShaking: Bool = false
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    @State private var showAlert = false  // アラート表示用の状態変数

    let Gacha = NSDataAsset(name: "Gacha")?.data
    let Ultra = NSDataAsset(name: "Ultra")?.data
    let SuperRare = NSDataAsset(name: "SuperRare")?.data
    let Rare = NSDataAsset(name: "Rare")?.data
    let Normal = NSDataAsset(name: "Normal")?.data
    
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
                    }
                } else {
                    Image("GachaIm")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                }
            }
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
                        startGacha()
                    }),
                    secondaryButton: .cancel(Text("いいえ"))
                )
            }
            Text("所持枚数: \(itemState.SpecialCoin)")
                .foregroundColor(.blue)
            Spacer()
        }
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
                    if currentGifData == Gacha {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            switch resultItem?.rarity {
                            case .Ultra:
                                currentGifData = Ultra
                            case .SuperRare:
                                currentGifData = SuperRare
                            case .Rare:
                                currentGifData = Rare
                            default:
                                currentGifData = Normal
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                                self.finishGacha()
                            }
                        }
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
        currentGifData = Gacha
    }

    private func finishGacha() {
        playgacha = false
        showResult = true
    }

    private func spinGacha() {
        let items = itemState.ItemSources
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
}

private extension GeometryProxy {
    var sizeWithSafeArea: CGSize {
        .init(
            width: self.size.width + self.safeAreaInsets.trailing + self.safeAreaInsets.leading,
            height: self.size.height + self.safeAreaInsets.top + self.safeAreaInsets.bottom
        )
    }
}

// GachaGIF2構造体の定義
struct GachaGIF2: View {
    @State private var playgacha: Bool = false
    @State private var currentGifData: Data? = nil
    @State private var resultItem: Item? = nil
    @State private var showResult = false
    @State private var shakeOffset: CGFloat = 0
    @State private var isShaking: Bool = false
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    @State private var showAlert = false  // アラート表示用の状態変数

    let Gacha2 = NSDataAsset(name: "Gacha2")?.data
    let Ultra = NSDataAsset(name: "Ultra")?.data
    let SuperRare = NSDataAsset(name: "SuperRare")?.data
    let Rare = NSDataAsset(name: "Rare")?.data
    
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
                    }
                } else {
                    Image("Gacha2Im")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                }
            }
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
                        startGacha()
                    }),
                    secondaryButton: .cancel(Text("いいえ"))
                )
            }
            Text("所持枚数: \(itemState.SpecialCoin)")
                .foregroundColor(.blue)
            Spacer()
        }
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
                    if currentGifData == Gacha2 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            switch resultItem?.rarity {
                            case .Ultra:
                                currentGifData = Ultra
                            case .SuperRare:
                                currentGifData = SuperRare
                            case .Rare:
                                currentGifData = Rare
                            default:
                                currentGifData = Gacha2 // 結果がない場合のデフォルト
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                                self.finishGacha()
                            }
                        }
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
        currentGifData = Gacha2
    }

    private func finishGacha() {
        playgacha = false
        showResult = true
    }

    private func spinGacha() {
        let items = itemState.ItemSources.filter { $0.rarity != .Normal }
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
}
