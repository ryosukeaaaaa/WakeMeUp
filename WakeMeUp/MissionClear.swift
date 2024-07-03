//
//  MissionClear.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/02.
//

import SwiftUI

struct MissionClear: View {
    @State private var HomeView = false
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Text("ミッション完了")
                    .font(.largeTitle)
                    .padding()
                Text("おめでとうございます！")
                    .font(.title)
                Button(action: {
                    // Clear the navigation stack and navigate to HomeView
                    navigationPath.removeLast(navigationPath.count)
                    navigationPath.append("HomeView")
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("ホームへ")
                            .font(.headline)
                    }
                    .padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationDestination(for: String.self) { viewName in
                if viewName == "HomeView" {
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                }
            }
//            .navigationBarItems(
//                trailing: HStack {
//                    Button(action: {
//                        // ここにHomeへの操作を。具体的にはpathを消去することでコントロール
//                    }) {
//                        Text("Homeへ")
//                    }
//                }
//            )
        }
    }
}

#Preview {
    MissionClear()
}
