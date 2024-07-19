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
    
    @Published var ItemSources: [Item] = [
        //　全39種
        Item(name: "Tyrannosaurus", rarity: .Ultra),
        Item(name: "Triceratops", rarity: .Ultra),
        Item(name: "Elephant", rarity: .SuperRare),
        Item(name: "Lion", rarity: .SuperRare),
        Item(name: "Tiger", rarity: .SuperRare),
        Item(name: "Giraffe", rarity: .SuperRare),
        Item(name: "Eagle", rarity: .SuperRare),
        Item(name: "Crocodile", rarity: .SuperRare),
        Item(name: "Rhinoceros", rarity: .SuperRare),
        Item(name: "Wolf", rarity: .Rare),
        Item(name: "Cheetah", rarity: .Rare),
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
        Item(name: "Dog", rarity: .Normal),
        Item(name: "Cat", rarity: .Normal),
        Item(name: "Koala", rarity: .Normal),
        Item(name: "Turtle", rarity: .Normal),
        Item(name: "Squirrel", rarity: .Normal),
        Item(name: "Monkey", rarity: .Normal),
        Item(name: "Raccoon", rarity: .Normal),
        Item(name: "Goat", rarity: .Normal),
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
    
    @State private var collection = false
    @State private var gacha = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationStack {
                    VStack{
                        Button(action: {
                            collection = true
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("コレクション")
                                    .font(.headline)
                                Spacer()  // ここにSpacerを追加
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)  // 横幅を最大に設定
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
                                Spacer()  // ここにSpacerを追加
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)  // 横幅を最大に設定
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $gacha) {
                            Gacha(itemState: itemState)
                        }
                    }
                }
                //デバイスに残っている通知チェック
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
            .padding()
            .navigationTitle("ガチャ")
            .onAppear {
                collection = false
                gacha = false
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

