import Foundation

struct Item: Codable, Identifiable {
    var id = UUID()
    let name: String
    let rarity: Rarity
}


enum Rarity: String, Codable, CaseIterable, Identifiable {
    case Secret, Ultra, SuperRare, Rare, Normal
    
    var id: String { self.rawValue }
    
    var probability: Double {
        switch self {
        case .Secret:
            return 0.005
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
    
    @Published var ItemSources: [Item] = [
        //　全44種
        Item(name: "Dragon", rarity: .Secret),
        Item(name: "Unicorn", rarity: .Secret),
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
        Item(name: "Cheetah", rarity: .SuperRare),
        Item(name: "Hippo", rarity: .Rare),
        Item(name: "Snake", rarity: .Rare),
        Item(name: "Fox", rarity: .Rare),
        Item(name: "Gorilla", rarity: .Rare),
        Item(name: "Bear", rarity: .Rare),
        Item(name: "Panda", rarity: .Rare),
        Item(name: "Kangal", rarity: .Rare),
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
    
    init() {
        self.NormalCoin = UserDefaults.standard.integer(forKey: "NormalCoin")
        self.SpecialCoin = UserDefaults.standard.integer(forKey: "SpecialCoin")
        self.Pre_Count = UserDefaults.standard.integer(forKey: "Pre_Count")
        self.UserItems = UserDefaults.standard.stringArray(forKey: "UserItems") ?? []
    }
    
    func addItem(_ item: Item) {
        if !UserItems.contains(item.name) {
            UserItems.append(item.name)
            UserDefaults.standard.set(UserItems, forKey: "UserItems") // ここでも保存
        }
    }
}

import SwiftUI
import SpriteKit

struct GachaView: View {
    @ObservedObject var itemState = ItemState() // ItemStateのインスタンスを作成
    @ObservedObject var missionState = MissionState() // MissionStateのインスタンスを作成
    
    @State private var collection = false
    @State private var gacha = false
    @State private var showAlert = false
    @State private var alertMessage = ""

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
                        .navigationDestination(isPresented: $collection) {
                            Collection(itemState: itemState)
                        }
                    }
                    VStack{
                        Button(action: {
                            gacha = true
                        }) {
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
                        .navigationDestination(isPresented: $gacha) {
                            Gacha(itemState: itemState)
                        }
                    }
                }
                
                // デバイスに残っている通知チェック
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
                
                Spacer()
                
                AdMobView()
                    .frame(width: 450, height: 300)
            }
            .padding()
            .navigationTitle("ガチャ")
            .onAppear {
                collection = false
                gacha = false
                
                // コインの計算ロジック
                let totalCount = missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount
                let normalCoinIncrement = (totalCount - 50 * itemState.Pre_Count) / 50
                let specialCoinIncrement = (totalCount - 50 * itemState.Pre_Count) / 250
                
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
                    itemState.Pre_Count = totalCount / 50
                    alertMessage = coinMessage
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("コインを入手しました"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
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

