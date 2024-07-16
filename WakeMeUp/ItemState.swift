import Foundation

class ItemState: ObservableObject {
    @Published var NormalCoin: Int {
        didSet {
            UserDefaults.standard.set(NormalCoin, forKey: "NormalCoin")
        }
    }
    @Published var SpecialCoin: Int {
        didSet {
            UserDefaults.standard.set(SpecialCoin, forKey: "SpecialCoin")
        }
    }
    
    @Published var ItemSources: [String] = ["banana", "apple", "orange"]
    
    init() {
        self.NormalCoin = UserDefaults.standard.integer(forKey: "NormalCoin")
        self.SpecialCoin = UserDefaults.standard.integer(forKey: "SpecialCoin")
    }
}

import SwiftUI
import SpriteKit

struct GachaView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: ItemView()) {
                HStack {
                    Image(systemName: "lock.shield")
                    Text("コレクション")
                        .font(.headline)
                    Spacer()
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            NavigationLink(destination: Gacha()) {
                HStack {
                    Image(systemName: "capsule.fill")
                    Text("ガチャ")
                        .font(.headline)
                    Spacer()
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}


//import SwiftUI
//
//struct GachaView: View {
//    @State private var items = ["🍎", "🍊", "🍌", "🍉", "🍇", "🍓"]
//    @State private var selectedItem = ""
//    @State private var isShaking = false
//    @State private var isItemVisible = false
//
//    var body: some View {
//        VStack {
//            Spacer()
//
//            Text(selectedItem)
//                .font(.system(size: 100))
//                .opacity(isItemVisible ? 1.0 : 0.0)
//                .animation(.easeIn(duration: 0.5), value: isItemVisible)
//
//            Spacer()
//
//            Image(systemName: "g.circle.fill")
//                .resizable()
//                .frame(width: 100, height: 100)
//                .rotationEffect(.degrees(isShaking ? 10 : 0))
//                .animation(isShaking ? Animation.linear(duration: 0.1).repeatCount(15, autoreverses: true) : .default, value: isShaking)
//
//            Spacer()
//
//            Button(action: {
//                startGacha()
//            }) {
//                Text("コインを投入してガチャを回す")
//                    .font(.largeTitle)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//    }
//
//    func startGacha() {
//        isShaking = true
//        isItemVisible = false
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            isShaking = false
//            selectedItem = items.randomElement() ?? ""
//            isItemVisible = true
//        }
//    }
//}

