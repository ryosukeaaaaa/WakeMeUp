import SwiftUI
import GoogleMobileAds

struct ContentViewl: View {
    var body: some View {
        VStack{
            Spacer()
        AdMobView()
            .frame(width: 150, height: 60)
        }
    }
}


struct AdMobView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<AdMobView>) -> GADBannerView{
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        // 修正された部分
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context:  UIViewRepresentableContext<AdMobView>) {
    }
}

struct DemoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentViewl()
        }
    }
}
