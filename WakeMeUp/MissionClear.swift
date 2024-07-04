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
                Text("Mission Complete!")
                    .font(.largeTitle)
                    .padding()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Mission Complete!")
                                .font(.largeTitle)
                        )
                    )
                Spacer()
                Text("今日の単語")
                    .font(.title)
                    .padding(.top)
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
