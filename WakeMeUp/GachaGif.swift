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
            gachaTypeNormal: true, //ノーマルガチャかどうか
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
            gachaTypeNormal: false,
            itemState: itemState
        )
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
    
    let gachaTypeNormal: Bool

    @ObservedObject var itemState: ItemState

    @State private var showGachaButton: Bool = true
    @State private var isInitialized: Bool = false //初回設定
    
    @State private var addticket: Int = 0
    
    @State private var showTicketAlert = false  // チケット変換アラート用の状態変数
    
    @State private var new = false
    
    @State private var animationState: AnimationState = .notStarted
    
    enum AnimationState {
        case notStarted, inProgress, finished
    }
    @State private var animationTask: Task<Void, Never>?
    
    @State private var shared = false

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
//                            .onAppear {
//                                startTextAnimation("Rarity: \(resultItem.rarity.rawValue)")
//                            }
                        Image(resultItem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 400)
                            .offset(x: shakeOffset)
                            .onAppear {
                                startShaking()
                                
                                // 2秒後にaddticketの値を確認してアラートを表示
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    if addticket > 0 {
                                        showTicketAlert = true
                                    }
                                }
                            }
                        if new {
                            Text("New!")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        Text(resultItem.name)
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    .alert(isPresented: $showTicketAlert) {
                        Alert(
                            title: Text("入手済み"),
                            message: Text("チケット \(addticket) 枚に変換されました"),
                            dismissButton: .default(Text("OK")) {
                                addticket = 0  // OKボタンを押したときにaddticketを0にリセット
                            }
                        )
                    }
                } else {
                    Image(gachaImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                }
                
                VStack{
                    Spacer()
                    
                    if showGachaButton {
                        Button(action: {
                            showAlert = true  // アラートを表示する
                        }) {
                            HStack {
                                if gachaTypeNormal{
                                    Image("NormalCoin")
                                        .resizable()
                                        .frame(width: 40, height: 40)  // 画像のサイズを調整
                                }else{
                                    Image("SpecialCoin")
                                        .resizable()
                                        .frame(width: 40, height: 40)  // 画像のサイズを調整
                                }
                                Text("ガチャを引く")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .alert(isPresented: $showAlert) {
                            if gachaTypeNormal && itemState.NormalCoin == 0{
                                Alert(
                                    title: Text("確認"),
                                    message: Text("ノーマルコインが足りません"),
                                    dismissButton: .cancel(Text("閉じる"))
                                )
                            }else if !gachaTypeNormal && itemState.SpecialCoin == 0{
                                Alert(
                                    title: Text("確認"),
                                    message: Text("スペシャルコインが足りません"),
                                    dismissButton: .cancel(Text("閉じる"))
                                )
                            }else{
                                Alert(
                                    title: Text("確認"),
                                    message: Text("本当にガチャを引きますか？"),
                                    primaryButton: .default(Text("はい"), action: {
                                        showGachaButton = false // ボタンと所持枚数を非表示にする
                                        hideNavigationBar = true // バックボタンを非表示にする
                                        if gachaTypeNormal{
                                            itemState.NormalCoin -= 1
                                        }else{
                                            itemState.SpecialCoin -= 1
                                        }
                                        startGacha()
                                    }),
                                    secondaryButton: .cancel(Text("いいえ"))
                                )
                            }
                        }
                    }else if playgacha {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                skipAnimation = true
                                finishGacha()
                            }) {
                                Text("演出をスキップ")
                                    .padding()
//                                    .background(Color.white)
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.leading)
                        }
                    }else if (itemState.Xshare == 1 && gachaTypeNormal) || (itemState.Xshare == 2 && !gachaTypeNormal) {
                        Button(action: {
                            showGachaButton = false // ボタンと所持枚数を非表示にする
                            hideNavigationBar = true // バックボタンを非表示にする
                            skipAnimation = false  // スキップフラグをリセット
                            showShareButton = false
                            itemState.Xshare = 0
                            startGacha()
                        }) {
                            Text("もう一度引く")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .fontWeight(.bold)
                        }
                    }else{
                        VStack{
                            if showShareButton {
                                Button(action: {
                                    if let item = resultItem {
                                        if gachaTypeNormal{
                                            itemState.Xshare = 1
                                        }else{
                                            itemState.Xshare = 2
                                        }
                                        shareOnTwitter(with: item)
                                        print("シェアしました")
                                        shared = true
                                    }
                                }) {
                                    Text("Xでシェアしてもう一回")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .fontWeight(.bold)
                                }
                            }
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("戻る")
                                    .padding()
                                    .background(Color.gray.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
            Spacer()
            
            AdMobView()
                .frame(width: 450, height: 70)
        }
        .onAppear {
            if !isInitialized {
                if gachaTypeNormal{
                    showGachaButton = !(itemState.Xshare == 1)
                    shared = itemState.Xshare == 1
                }else{
                    showGachaButton = !(itemState.Xshare == 2)
                    shared = itemState.Xshare == 2
                }
                isInitialized = true
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                if gachaTypeNormal{
                    HStack{
                        Image("NormalCoin")
                            .resizable()
                            .frame(width: 40, height: 40)  // 画像のサイズを調整
                        Text("× \(itemState.NormalCoin)")
                            .foregroundColor(.blue)
                    }
                }else{
                    HStack{
                        Image("SpecialCoin")
                            .resizable()
                            .frame(width: 40, height: 40)  // 画像のサイズを調整
                        Text("× \(itemState.SpecialCoin)")
                            .foregroundColor(.blue)
                    }
                }
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


    private func startGacha() {
        resetGachaState()
        spinGacha()
        currentGifData = gachaData
        playgacha = true
        startGachaAnimation()
    }

    private func resetGachaState() {
        animationTask?.cancel()
        animationTask = nil
        skipAnimation = false
        showShareButton = false
        currentGifData = nil
        resultItem = nil
        playgacha = false
        showResult = false
    }

    @ViewBuilder
    func gachaAnimation() -> some View {
        if let gifData = currentGifData {
            GIFImage(data: gifData)
                .frame(height: 400)
        } else {
            Text("Failed to load GIF")
                .frame(height: 400)
        }
    }

    private func startGachaAnimation() {
        animationTask = Task { @MainActor in
            guard !skipAnimation else {
                finishGacha()
                return
            }

            // 初期アニメーション
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }

            // レアリティに応じたアニメーション
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

            try? await Task.sleep(for: .seconds(5.5))
            guard !Task.isCancelled else { return }

            finishGacha()
        }
    }

    @MainActor
    private func finishGacha() {
        playgacha = false
        showResult = true
        if !shared {
            showShareButton = true // Int.random(in: 1...3) == 1
        } else {
            showShareButton = false
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
            if !itemState.UserItems.contains(item.name) {
                itemState.UserItems.append(item.name)
                new = true
            }else{
                new = false
                // itemが既にUserItemsに含まれている場合、rarityによってaddticketの値を設定
                switch item.rarity {
                case .Normal:
                    addticket = 1
                case .Rare:
                    addticket = 3
                case .SuperRare:
                    addticket = 8
                case .Ultra:
                    addticket = 16
                }
                itemState.Ticket += addticket
            }
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
    
//    private func startTextAnimation(_ text: String) {
//        var currentIndex = 0
//        displayedText = ""
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//            if currentIndex < text.count {
//                displayedText.append(text[text.index(text.startIndex, offsetBy: currentIndex)])
//                currentIndex += 1
//            } else {
//                timer.invalidate()
//            }
//        }
//    }
    
    private func shareOnTwitter(with item: Item) {
        let text = "英語を発音しないと止まらないアラーム!?\n朝単-英単語アラーム\n当たったのは: \(item.name)\nレアリティ: \(item.rarity.rawValue)"
        let hashTag = "#朝単\n#アラーム\n#アプリ"
        let completedText = text + "\n" + hashTag
        
        let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}
