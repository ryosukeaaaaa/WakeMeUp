import SwiftUI

// 各アイテムのビューを定義
struct ItemView: View {
    let item: Item
    let isOwned: Bool

    var body: some View {
        VStack {
            if isOwned {
                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                Text(item.name)
            } else {
                Color.clear
                    .frame(width: 125, height: 125)
                    .background(Color.gray.opacity(0.3)) // 未入手アイテムの背景色
                Text("未入手")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}


struct Collection: View {
    @ObservedObject var itemState: ItemState
    @State private var showAlert = false

    var body: some View {
        VStack {
            if isCollectionComplete {
                Text("Congratulation!")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.green)
                    .padding()
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(Rarity.allCases) { rarity in
                        sectionView(for: rarity)
                    }
                }
                .frame(maxWidth: .infinity) // スクロールビューの横幅を最大にする
                Button(action: {
                    showAlert = true
                }) {
                    Text("コレクションをリセット")
                        .padding()
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("本当に実行しますか？"),
                        message: Text("コレクションが全てリセットされます。"),
                        primaryButton: .destructive(Text("リセット")) {
                            itemState.UserItems.removeAll()
                        },
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
            }
        }
        .navigationTitle("My Collection")
    }

    // コレクションが完全に揃ったかどうかを確認するプロパティ
    var isCollectionComplete: Bool {
        return Rarity.allCases.allSatisfy { rarity in
            let itemsOfRarity = itemState.ItemSources.filter { $0.rarity == rarity }
            let ownedItemsCount = itemsOfRarity.filter { itemState.UserItems.contains($0.name) }.count
            return ownedItemsCount == itemsOfRarity.count
        }
    }

    // セクションビューを生成するヘルパー関数
    func sectionView(for rarity: Rarity) -> some View {
        let itemsOfRarity = itemState.ItemSources.filter { $0.rarity == rarity }
        let ownedItemsCount = itemsOfRarity.filter { itemState.UserItems.contains($0.name) }.count
        let isComplete = ownedItemsCount == itemsOfRarity.count

        return Section(header: VStack {
            if isComplete {
                Text("complete!")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Text("\(rarity.rawValue) (\(ownedItemsCount)/\(itemsOfRarity.count))")
                .font(.headline)
        }
        .padding()) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(itemsOfRarity) { item in
                    ItemView(item: item, isOwned: itemState.UserItems.contains(item.name))
                }
            }
        }
    }
}

