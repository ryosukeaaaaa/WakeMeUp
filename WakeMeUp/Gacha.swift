import SwiftUI
import SpriteKit


struct Gacha: View {
    @ObservedObject var itemState: ItemState
    @State private var resultItem: String? = nil
    @State private var showResult = false
    @State private var currentGif: String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: GachaGIF(itemState: itemState)) {
                    VStack{
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("ノーマルガチャ")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Text("所持枚数: \(itemState.NormalCoin)")
                    }
                }
                NavigationLink(destination: GachaGIF(itemState: itemState)) {
                    VStack{
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("スペシャルガチャ")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Text("所持枚数: \(itemState.SpecialCoin)")
                    }
                }
            }
            if let resultItem = resultItem {
                Text("結果: \(resultItem)")
                    .font(.title)
                    .padding()
            }
        }
        .alert(isPresented: $showResult) {
            Alert(title: Text("ガチャ結果"), message: Text(resultItem ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

//struct GIFView: View {
//    @State private var images: [Image] = []
//    @State private var gifCount: Int = 0
//    @State private var currentIndex: Int = 0
//    
//    var gifName: String
//    var minimumInterval: Double
//    var shouldEmitRain: Bool = true
//    @Binding var isGifPlaying: Bool
//    
//    var body: some View {
//        TimelineView(.animation(minimumInterval: minimumInterval)) { context in
//            Group {
//                if images.isEmpty {
//                    Text("エラー")
//                } else {
//                    ZStack {
//                        if shouldEmitRain {
//                            GeometryReader { geometry in
//                                SpriteView(
//                                    scene: self.createRainParticleScene(size: geometry.sizeWithSafeArea),
//                                    options: [.allowsTransparency]
//                                ).edgesIgnoringSafeArea(.all)
//                            }
//                        }
//                        images[currentIndex]
//                            .resizable()
//                            .scaledToFit()
//                    }
//                }
//            }
//            .onChange(of: context.date) { _ in
//                if isGifPlaying {
//                    if currentIndex == (gifCount - 1) {
//                        currentIndex = 0
//                    } else {
//                        currentIndex += 1
//                    }
//                }
//            }
//        }
//        .onAppear {
//            guard let bundleURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
//                  let gifData = try? Data(contentsOf: bundleURL),
//                  let source = CGImageSourceCreateWithData(gifData as CFData, nil)
//            else {
//                return
//            }
//            gifCount = CGImageSourceGetCount(source)
//            var cgImages: [CGImage?] = []
//            for i in 0..<gifCount {
//                cgImages.append(CGImageSourceCreateImageAtIndex(source, i, nil))
//            }
//            let uiImages = cgImages.compactMap({ $0 }).map({ UIImage(cgImage: $0) })
//            images = uiImages.map({ Image(uiImage: $0) })
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
//}
//
//struct ContentViewgif: View {
//    @State private var shouldEmitRain = true
//    @State private var isGifPlaying = false
//    @State private var isButtonHidden = false
//    @State private var currentGif = "Gacha1"
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
//                
//                Image("Gacha1")
//                    .resizable()
//                    .scaledToFit()
//                    .opacity(isGifPlaying ? 0 : 1)
//
//                if isGifPlaying {
//                    GIFView(gifName: currentGif, minimumInterval: 0.03, isGifPlaying: $isGifPlaying)
//                        .frame(width: 300, height: 300)
//                }
//            }
//
//            if !isButtonHidden {
//                Button(action: {
//                    isButtonHidden = true
//                    isGifPlaying = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                        currentGif = "Ultra"
//                    }
//                }) {
//                    Text("ガチャを引く")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.top, 20)
//            }
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
//
