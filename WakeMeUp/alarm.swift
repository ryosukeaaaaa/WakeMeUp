import UserNotifications

func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if granted {
            print("Permission granted")
        } else {
            print("Permission denied")
        }
    }
}

func scheduleAlarm(at date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "アラーム"
    content.body = "時間です！"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.caf"))
    
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    
    let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    })
}

import AVFoundation

func setupAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Failed to set up audio session: \(error)")
    }
}

var audioPlayer: AVAudioPlayer?

func playAlarmSound() {
    guard let soundURL = Bundle.main.url(forResource: "alarm_sound", withExtension: "caf") else {
        return
    }
    
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        audioPlayer?.play()
    } catch {
        print("Failed to play sound: \(error)")
    }
}



import UIKit
import UserNotifications
import AVFoundation

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestNotificationAuthorization()
        setupAudioSession()
        return true
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
}

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // ボタンを追加してアラームを設定する
        let button = UIButton(type: .system)
        button.setTitle("Set Alarm", for: .normal)
        button.addTarget(self, action: #selector(scheduleAlarm), for: .touchUpInside)
        button.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        self.view.addSubview(button)
    }

    @objc func scheduleAlarm() {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.caf"))
        
        // 5秒後にアラームを設定
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        })
    }

    func playAlarmSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarm_sound", withExtension: "caf") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}

