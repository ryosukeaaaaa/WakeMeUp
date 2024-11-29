import SwiftUI

// 各アイテムのビュー
struct ItemView: View {
    let item: Item
    let isOwned: Bool
    var onTap: (Item) -> Void // タップ時のアクション

    var body: some View {
        VStack {
            if isOwned {
                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .background(Color.white)
                    .onTapGesture {
                        onTap(item) // タップ時に親ビューへアイテムを渡す
                    }
                Text(item.name)
            } else {
                Color.clear
                    .frame(width: 125, height: 125)
                    .background(Color.gray.opacity(0.3))
                Text("未入手")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

// コレクションビュー
struct Collection: View {
    @ObservedObject var itemState: ItemState
    @State private var showAlert = false
    @State private var selectedItem: Item? // 選択されたアイテムを管理

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
                .frame(maxWidth: .infinity)
//                Button(action: {
//                    showAlert = true
//                }) {
//                    Text("コレクションを全てリセット")
//                        .padding()
//                        .foregroundColor(.red)
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(
//                        title: Text("本当に実行しますか？"),
//                        message: Text("コレクションが全てリセットされます。"),
//                        primaryButton: .destructive(Text("リセット")) {
//                            itemState.UserItems.removeAll()
//                        },
//                        secondaryButton: .cancel(Text("キャンセル"))
//                    )
//                }
            }
        }
        .navigationTitle("コレクション")
        .overlay(
            Group {
                if let selectedItem = selectedItem {
                    LargeItemView(item: selectedItem) {
                        self.selectedItem = nil // ビューを閉じる
                    }
                }
            }
        )
    }

    var isCollectionComplete: Bool {
        return Rarity.allCases.allSatisfy { rarity in
            let itemsOfRarity = itemState.ItemSources.filter { $0.rarity == rarity }
            let ownedItemsCount = itemsOfRarity.filter { itemState.UserItems.contains($0.name) }.count
            return ownedItemsCount == itemsOfRarity.count
        }
    }

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
                    ItemView(item: item, isOwned: itemState.UserItems.contains(item.name)) { tappedItem in
                        self.selectedItem = tappedItem // 選択されたアイテムをセット
                    }
                }
            }
        }
    }
}

// 選択されたアイテムを拡大表示するビュー
struct LargeItemView: View {
    let item: Item
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose() // 背景タップで閉じる
                }
            VStack {
                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2) // 枠線を追加
                    )
                    .shadow(radius: 8)
                Text(item.name)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                Button(action: onClose) {
                    Text("閉じる")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
