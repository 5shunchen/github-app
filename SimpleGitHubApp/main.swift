import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 60))
        label.text = "🎉 GitHub iOS v1.0.0"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        vc.view.addSubview(label)
        let subLabel = UILabel(frame: CGRect(x: 0, y: 220, width: UIScreen.main.bounds.width, height: 40))
        subLabel.text = "定制开发版本"
        subLabel.font = UIFont.systemFont(ofSize: 18)
        subLabel.textAlignment = .center
        subLabel.textColor = .secondaryLabel
        vc.view.addSubview(subLabel)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}
