//
//  MissionState.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/01.
//

import Foundation

class MissionState: ObservableObject {
    @Published var randomEntry: (String, String, String, String, String) = ("", "", "", "", "")
    @Published var clear_mission = false
    @Published var missionCount: Int = 0
    @Published var shouldLoadInitialEntry: Bool = true

    @Published var ClearCount: Int {
        didSet {
            UserDefaults.standard.set(ClearCount, forKey: "ClearCount")
        }
    }
    @Published var material: String {
        didSet {
            UserDefaults.standard.set(material, forKey: "material")
        }
    }
    @Published var EnglishLevel: String {
        didSet {
            UserDefaults.standard.set(EnglishLevel, forKey: "EnglishLevel")
        }
    }
    @Published var PastWords: [[String: String]] {
        didSet {
            if let data = try? JSONEncoder().encode(PastWords) {
                UserDefaults.standard.set(data, forKey: "PastWords")
            }
        }
    }
    
    init() {
//        self.ClearCount = UserDefaults.standard.integer(forKey: "ClearCount")
        let savedClearCount = UserDefaults.standard.integer(forKey: "ClearCount")
        if savedClearCount == 0 && UserDefaults.standard.object(forKey: "ClearCount") == nil {
            self.ClearCount = 5
        } else {
            self.ClearCount = savedClearCount
        }
        self.material = UserDefaults.standard.string(forKey: "material") ?? "TOEIC英単語"
        self.EnglishLevel = UserDefaults.standard.string(forKey: "EnglishLevel") ?? "中級者"
        if let data = UserDefaults.standard.data(forKey: "PastWords"),
           let decoded = try? JSONDecoder().decode([[String: String]].self, from: data) {
            self.PastWords = decoded
        } else {
            self.PastWords = []
        }
    }
}
