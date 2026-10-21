import Flutter
import UIKit

@objc class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
          let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController() as? FlutterViewController else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = controller
    self.window = window

    // Flutter 3.29's AppDelegate resolves its plugin registry through this window.
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.window = window
      GeneratedPluginRegistrant.register(with: appDelegate)
    }

    window.makeKeyAndVisible()
  }
}
