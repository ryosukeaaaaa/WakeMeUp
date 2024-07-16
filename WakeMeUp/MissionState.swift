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
    @Published var PastWords: [[String: String]] {
        didSet {
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
    
    init() {
//        self.ClearCount = UserDefaults.standard.integer(forKey: "ClearCount")
        let savedClearCount = UserDefaults.standard.integer(forKey: "ClearCount")
        if savedClearCount == 0 && UserDefaults.standard.object(forKey: "ClearCount") == nil {
            self.ClearCount = 5
        } else {
            self.ClearCount = savedClearCount
        }
        self.material = UserDefaults.standard.string(forKey: "material") ?? "TOEIC"
        if let data = UserDefaults.standard.data(forKey: "PastWords"),
           let decoded = try? JSONDecoder().decode([[String: String]].self, from: data) {
            self.PastWords = decoded
        } else {
            self.PastWords = []
        }
        self.basicCount = UserDefaults.standard.integer(forKey: "basicCount")
        self.toeicCount = UserDefaults.standard.integer(forKey: "toeicCount")
        self.businessCount = UserDefaults.standard.integer(forKey: "businessCount")
        self.academicCount = UserDefaults.standard.integer(forKey: "academicCount")
        
        self.correctcircle = UserDefaults.standard.string(forKey: "correctcircle") ?? "あり"
    }
}
