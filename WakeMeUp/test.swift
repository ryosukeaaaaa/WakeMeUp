import SwiftUI
import UserNotifications

//@main
struct WakeMeUpApp2: App {
    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
    }
}

struct ContentView2: View {
    var body: some View {
        VStack {
            Button(action: {
                listAllPendingNotifications()
            }) {
                Text("Show Pending Notifications")
            }
            .padding()
            
            Button(action: {
                removeAllPendingNotifications()
            }) {
                Text("Remove All Pending Notifications")
            }
            .padding()
        }
    }

    func listAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("Identifier: \(request.identifier)")
                print("Content: \(request.content)")
                print("Trigger: \(String(describing: request.trigger))")
                print("-----")
            }
        }
    }

    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications have been removed.")
    }
}


