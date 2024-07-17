import Foundation

struct Item: Codable, Identifiable {
    var id = UUID()
    let name: String
    let rarity: Rarity
}

enum Rarity: String, Codable {
    case Ultra, SuperRare, Rare, Normal
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
        Item(name: "eagle", rarity: .SuperRare),
        Item(name: "mice", rarity: .Normal),
        Item(name: "elephant", rarity: .Ultra),
        Item(name: "rabbit", rarity: .Rare)
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

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationLink(destination: Collection(itemState: itemState)) { // itemStateを渡す
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
                NavigationLink(destination: Gacha(itemState: itemState)) {
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
    }
}

