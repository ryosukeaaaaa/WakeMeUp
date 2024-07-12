import UIKit
import SwiftUI
import KeyboardObserving // KeyboardObservingライブラリをインポート

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  // A Keyboard that will be added to the environment.
  var keyboard = Keyboard()


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

    // Use a UIHostingController as window root view controller
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: YourView()
          // Adds the keyboard to the environment
          .environmentObject(keyboard)
      )
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}

import KeyboardObserving

struct YourView: View {

  var body: some View {
    KeyboardObservingView {
      // Your content goes here!
    }
  }
}
