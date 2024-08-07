import SwiftUI
import UserNotifications

//@main
struct WakeMeUpApp2: App {
    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
    }
}

struct ContentView2: View {
    var body: some View {
        VStack {
            Button(action: {
                listAllPendingNotifications()
            }) {
                Text("Show Pending Notifications")
            }
            .padding()
            
            Button(action: {
                removeAllPendingNotifications()
            }) {
                Text("Remove All Pending Notifications")
            }
            .padding()
        }
    }

    func listAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("Identifier: \(request.identifier)")
                print("Content: \(request.content)")
                print("Trigger: \(String(describing: request.trigger))")
                print("-----")
            }
        }
    }

    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications have been removed.")
    }
}


//// GachaGIF構造体の定義
//struct GachaGIF: View {
//    @State private var playgacha: Bool = false
//    @State private var currentGifData: Data? = nil
//    @State private var resultItem: Item? = nil
//    @State private var showResult = false
//    @State private var shakeOffset: CGFloat = 0
//    @State private var isShaking: Bool = false
//    @State private var displayedText: String = ""
//    @State private var timer: Timer?
//
//    let Gacha = NSDataAsset(name: "Gacha")?.data
//    let Ultra = NSDataAsset(name: "Ultra")?.data
//    let SuperRare = NSDataAsset(name: "SuperRare")?.data
//    let Rare = NSDataAsset(name: "Rare")?.data
//    let Normal = NSDataAsset(name: "Normal")?.data
//    
//    @ObservedObject var itemState: ItemState
//
//    var body: some View {
//        VStack {
//            ZStack {
//                GeometryReader { geometry in
//                    SpriteView(
//                        scene: self.createRainParticleScene(size: geometry.sizeWithSafeArea),
//                        options: [.allowsTransparency]
//                    ).edgesIgnoringSafeArea(.all)
//                }
//                if playgacha {
//                    gachaAnimation()
//                } else if let resultItem = resultItem {
//                    VStack {
//                        Text("\(resultItem.rarity.rawValue)")
//                            .font(.title)
//                            .padding()
//                            .onAppear {
//                                startTextAnimation("Rarity: \(resultItem.rarity.rawValue)")
//                            }
//                        Image(resultItem.name)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 400)
//                            .offset(x: shakeOffset)
//                            .onAppear {
//                                startShaking()
//                            }
//                        Text(resultItem.name)
//                            .font(.title)
//                            .padding()
//                    }
//                } else {
//                    Image("GachaIm")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 400)
//                }
//            }
//            Button(action: {
//                startGacha()
//            }) {
//                Text("ガチャを引く")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            Text("所持枚数: \(itemState.SpecialCoin)")
//                .foregroundColor(.blue)
//            Spacer()
//        }
//    }
//
//    private func createRainParticleScene(size: CGSize) -> SKScene {
//        let emitterNode = SKEmitterNode(fileNamed: "RainParticle")!
//        let scene = SKScene(size: size)
//        scene.addChild(emitterNode)
//        scene.backgroundColor = .clear
//        scene.anchorPoint = .init(x: 0.7, y: 1)
//        return scene
//    }
//
//    @ViewBuilder
//    func gachaAnimation() -> some View {
//        if let gifData = currentGifData {
//            GIFImage(data: gifData)
//                .frame(height: 400)
//                .onAppear {
//                    if currentGifData == Gacha {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                            currentGifData = Ultra
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                self.finishGacha()
//                            }
//                        }
//                    }
//                }
//        } else {
//            Text("Failed to load GIF")
//                .frame(height: 400)
//        }
//    }
//
//    private func startGacha() {
//        playgacha = true
//        currentGifData = Gacha
//        resultItem = nil
//    }
//
//    private func finishGacha() {
//        playgacha = false
//        spinGacha()
//    }
//
//    private func spinGacha() {
//        let items = itemState.ItemSources
//        if let item = items.weightedRandomElement() {
//            resultItem = item
//            itemState.addItem(item)
//        }
//        showResult = true
//    }
//
//    private func startShaking() {
//        withAnimation(Animation.easeInOut(duration: 0.05).repeatCount(20, autoreverses: true)) {
//            shakeOffset = 10
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            shakeOffset = 0
//        }
//    }
//    
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
//}
//
//private extension GeometryProxy {
//    var sizeWithSafeArea: CGSize {
//        .init(
//            width: self.size.width + self.safeAreaInsets.trailing + self.safeAreaInsets.leading,
//            height: self.size.height + self.safeAreaInsets.top + self.safeAreaInsets.bottom
//        )
//    }
//}
