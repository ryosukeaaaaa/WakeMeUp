import SwiftUI
import SpriteKit


struct Gacha: View {
    @ObservedObject var itemState: ItemState
    
    @State private var normal = false
    @State private var special = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationStack {
                    VStack{
                        Button(action: {
                            normal = true
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("ノーマルガチャ")
                                    .font(.headline)
                                Spacer()  // ここにSpacerを追加
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)  // 横幅を最大に設定
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $normal) {
                            GachaGIF(itemState: itemState)
//                                .navigationBarBackButtonHidden(true)
                        }
                        Text("所持枚数: \(itemState.NormalCoin)")
                    }
                    VStack{
                        Button(action: {
                            special = true
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("スペシャルガチャ")
                                    .font(.headline)
                                Spacer()  // ここにSpacerを追加
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)  // 横幅を最大に設定
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $special) {
                            GachaGIF2(itemState: itemState)
//                                .navigationBarBackButtonHidden(true)
                        }
                        Text("所持枚数: \(itemState.SpecialCoin)")
                    }
                    VStack {
                        VStack {
                            HStack {
                                Text("レアリティ")
                                    .font(.headline)
                                Spacer()
                                Text("排出確率")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            HStack {
                                Text("Normal")
                                Spacer()
                                Text("64 %")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Rare")
                                Spacer()
                                Text("28 %")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("SuperRare")
                                Spacer()
                                Text("7 %")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("UltraRare")
                                Spacer()
                                Text("1 %")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                }
            }
            .padding()
            .navigationTitle("ガチャ")
            .onAppear {
                normal = false
                special = false
            }
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
