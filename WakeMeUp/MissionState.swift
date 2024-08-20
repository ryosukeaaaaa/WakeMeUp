import Foundation
import SwiftCSV

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
    @Published var section: Int {
        didSet {
            UserDefaults.standard.set(section, forKey: "section")
        }
    }
    
    @Published var PastWords: [[[String: String]]] {
        didSet {
            // FIFO方式で10回分を保持
            if PastWords.count > 10 {
                PastWords.removeFirst(PastWords.count - 10)
            }

            // データをUserDefaultsに保存
            if let data = try? JSONEncoder().encode(PastWords) {
                UserDefaults.standard.set(data, forKey: "PastWords")
            }
        }
    }
    
    @Published var basicCount: Int {
        didSet {
            UserDefaults.standard.set(basicCount, forKey: "basicCount")
        }
    }
    @Published var toeicCount: Int {
        didSet {
            UserDefaults.standard.set(toeicCount, forKey: "toeicCount")
        }
    }
    @Published var businessCount: Int {
        didSet {
            UserDefaults.standard.set(businessCount, forKey: "businessCount")
        }
    }
    @Published var academicCount: Int {
        didSet {
            UserDefaults.standard.set(academicCount, forKey: "academicCount")
        }
    }
    
    @Published var correctcircle: String {
        didSet {
            UserDefaults.standard.set(correctcircle, forKey: "correctcircle")
        }
    }
    @Published var correctvolume: Float {
        didSet {
            UserDefaults.standard.set(correctvolume, forKey: "correctvolume")
        }
    }
    @Published var Question: String {
        didSet {
            UserDefaults.standard.set(Question, forKey: "Question")
        }
    }
    
    init() {
        // アプリ初回起動チェック
        let isFirstMission = UserDefaults.standard.bool(forKey: "isFirstMission")
        if !isFirstMission {
            self.ClearCount = 5
            self.correctvolume = 50
            // 初回起動済みフラグを設定
            UserDefaults.standard.set(true, forKey: "isFirstMission")
        } else {
            self.ClearCount = UserDefaults.standard.integer(forKey: "ClearCount")
            self.correctvolume = UserDefaults.standard.float(forKey: "correctvolume")
        }
        
        self.material = UserDefaults.standard.string(forKey: "material") ?? "TOEIC英単語"
        self.section = UserDefaults.standard.integer(forKey: "section")
        
        // 初期化時にUserDefaultsからデータを読み込む
        if let data = UserDefaults.standard.data(forKey: "PastWords"),
           let decoded = try? JSONDecoder().decode([[[String: String]]].self, from: data) {
            self.PastWords = decoded
        } else {
            self.PastWords = Array(repeating: [], count: 10) // 10回分の空の配列を用意
        }
        
        self.basicCount = UserDefaults.standard.integer(forKey: "basicCount")
        self.toeicCount = UserDefaults.standard.integer(forKey: "toeicCount")
        self.businessCount = UserDefaults.standard.integer(forKey: "businessCount")
        self.academicCount = UserDefaults.standard.integer(forKey: "academicCount")
        
        self.correctcircle = UserDefaults.standard.string(forKey: "correctcircle") ?? "あり"
        
        self.Question = UserDefaults.standard.string(forKey: "Question") ?? "未習得のみ"
    }
}

