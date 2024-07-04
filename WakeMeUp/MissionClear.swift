//
//  MissionClear.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/02.
//

import SwiftUI

struct MissionClear: View {
    @ObservedObject var missionState: MissionState
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
                Spacer()
                Text("今日の単語")
                    .font(.title)
                ScrollView {
                    ForEach(missionState.PastWords, id: \.self) { word in
                        HStack {
                            Text(" \(word["entry"] ?? "N/A")")
                            Spacer()
                            Text(" \(word["meaning"] ?? "N/A")")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                Button(action: {
                    // Clear the navigation stack and navigate to HomeView
                    navigationPath.removeLast(navigationPath.count)
                    navigationPath.append("HomeView")
                }) {
                    HStack {
                        Image(systemName: "house")
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
        }
    }
}
