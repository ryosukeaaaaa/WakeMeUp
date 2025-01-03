import Foundation

struct Item: Codable, Identifiable {
    var id = UUID()
    let name: String
    let rarity: Rarity
}


enum Rarity: String, Codable, CaseIterable, Identifiable {
    case Ultra, SuperRare, Rare, Normal
    
    var id: String { self.rawValue }
    
    var probability: Double {
        switch self {
        case .Ultra:
            return 0.005
        case .SuperRare:
            return 0.01
        case .Rare:
            return 0.02
        case .Normal:
            return 0.04
        }
    }
}

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
    
    @Published var Pre_Count: Int {
        didSet {
            UserDefaults.standard.set(Pre_Count, forKey: "Pre_Count")
        }
    }
    
    @Published var Pre_Count2: Int {
        didSet {
            UserDefaults.standard.set(Pre_Count2, forKey: "Pre_Count2")
        }
    }
    
    @Published var Ticket: Int {
        didSet {
            UserDefaults.standard.set(Ticket, forKey: "Ticket")
        }
    }
    
    @Published var ItemSources: [Item] = [
        //　全42種
        Item(name: "Tyrannosaurus", rarity: .Ultra),
        Item(name: "Triceratops", rarity: .Ultra),
        Item(name: "Spinosaurus", rarity: .Ultra),
        Item(name: "Pteranodon", rarity: .Ultra),
        Item(name: "Elephant", rarity: .SuperRare),
        Item(name: "Lion", rarity: .SuperRare),
        Item(name: "Tiger", rarity: .SuperRare),
        Item(name: "Giraffe", rarity: .SuperRare),
        Item(name: "Eagle", rarity: .SuperRare),
        Item(name: "Crocodile", rarity: .SuperRare),
        Item(name: "Rhinoceros", rarity: .SuperRare),
        Item(name: "Wolf", rarity: .SuperRare),
        Item(name: "Cheetah", rarity: .Rare),
        Item(name: "Hippo", rarity: .Rare),
        Item(name: "Tapir", rarity: .Rare),
        Item(name: "Fox", rarity: .Rare),
        Item(name: "Gorilla", rarity: .Rare),
        Item(name: "Bear", rarity: .Rare),
        Item(name: "Panda", rarity: .Rare),
        Item(name: "Kangaroo", rarity: .Rare),
        Item(name: "Zebra", rarity: .Rare),
        Item(name: "Deer", rarity: .Rare),
        Item(name: "Penguin", rarity: .Rare),
        Item(name: "Camel", rarity: .Rare),
        Item(name: "Ostrich", rarity: .Rare),
        Item(name: "Goat", rarity: .Rare),
        Item(name: "Meerkat", rarity: .Rare),
        Item(name: "Dog", rarity: .Normal),
        Item(name: "Cat", rarity: .Normal),
        Item(name: "Koala", rarity: .Normal),
        Item(name: "Turtle", rarity: .Normal),
        Item(name: "Squirrel", rarity: .Normal),
        Item(name: "Monkey", rarity: .Normal),
        Item(name: "Raccoon", rarity: .Normal),
        Item(name: "Pig", rarity: .Normal),
        Item(name: "Sheep", rarity: .Normal),
        Item(name: "Duck", rarity: .Normal),
        Item(name: "Chick", rarity: .Normal),
        Item(name: "Owl", rarity: .Normal),
        Item(name: "Capybara", rarity: .Normal),
        Item(name: "Mice", rarity: .Normal),
        Item(name: "Rabbit", rarity: .Normal)
    ]
    
    @Published var UserItems: [String] {
        didSet {
            UserDefaults.standard.set(UserItems, forKey: "UserItems")
        }
    }
    
    @Published var Xshare: Int {
        didSet {
            UserDefaults.standard.set(Xshare, forKey: "Xshare")
        }
    }
    
    @Published var Review: Int {
        didSet {
            UserDefaults.standard.set(Review, forKey: "Review")
        }
    }
    
    init() {
        if UserDefaults.standard.object(forKey: "Pre_Count") == nil {
            // 最初は1枚配布
            self.Pre_Count = -1
            self.Pre_Count2 = -1
        } else {
            self.Pre_Count = UserDefaults.standard.integer(forKey: "Pre_Count")
            self.Pre_Count2 = UserDefaults.standard.integer(forKey: "Pre_Count2")
        }
        self.NormalCoin = UserDefaults.standard.integer(forKey: "NormalCoin")
        self.SpecialCoin = UserDefaults.standard.integer(forKey: "SpecialCoin")
        self.UserItems = UserDefaults.standard.stringArray(forKey: "UserItems") ?? []
        self.Ticket = UserDefaults.standard.integer(forKey: "Ticket")
        self.Xshare = UserDefaults.standard.integer(forKey: "Xshare")
        self.Review = UserDefaults.standard.integer(forKey: "Review")
    }
}

import SwiftUI
import SpriteKit

struct GachaView: View {
//    @ObservedObject var itemState = ItemState() // ItemStateのインスタンスを作成
//    @ObservedObject var missionState = MissionState() // MissionStateのインスタンスを作成
    @EnvironmentObject var  missionState: MissionState
    @EnvironmentObject var  itemState: ItemState
    
    @State private var collection = false
    @State private var gacha = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var exchange = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Spacer()
                NavigationStack {
                    VStack{
                        Button(action: {
                            collection = true
                        }) {
                            HStack {
                                Image(systemName: "book")
                                Text("コレクション")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0, green: 0.7, blue: 0.4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $collection) {
                            Collection(itemState: itemState)
                        }
                    }
                    VStack{
                        Button(action: {
                            gacha = true
                        }) {
                            HStack {
                                Image(systemName: "die.face.5")
                                Text("ガチャ")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0, green: 0.7, blue: 0.4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $gacha) {
                            Gacha(itemState: itemState)
                        }
                    }
                    VStack{
                        Button(action: {
                            exchange = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.2.circlepath")
                                Text("チケット交換")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0, green: 0.8, blue: 0))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $exchange) {
                            Exchange(itemState: itemState)
                        }
                    }
                }
                CollectionImage(itemState: itemState)
                
                AdMobView()
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height * 1/6
                    )
            }
            .padding()
            .navigationTitle("ガチャ")
            .onAppear {
                collection = false
                gacha = false
                exchange = false
                
                // コインの計算ロジック
                let totalCount = missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount
                let normalCoinIncrement = (totalCount - 25 * itemState.Pre_Count) / 25
                let specialCoinIncrement = (totalCount - 100 * itemState.Pre_Count2) / 100
                
                var coinMessage = ""

                if normalCoinIncrement > 0 {
                    itemState.NormalCoin += normalCoinIncrement
                    coinMessage += "ノーマルコインを \(normalCoinIncrement) 枚入手しました。\n"
                }
                
                if specialCoinIncrement > 0 {
                    itemState.SpecialCoin += specialCoinIncrement
                    coinMessage += "スペシャルコインを \(specialCoinIncrement) 枚入手しました。"
                }
                
                if !coinMessage.isEmpty {
                    itemState.Pre_Count = totalCount / 25
                    itemState.Pre_Count2 = totalCount / 100
                    alertMessage = coinMessage
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("コインを入手しました"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

