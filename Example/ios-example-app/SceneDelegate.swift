import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Lifecycle
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: RootViewController())
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
        self.window = window
        // The SDK still reads `UIApplication.shared.delegate?.window` for safe area insets.
        (UIApplication.shared.delegate as? AppDelegate)?.window = window

        handle(urlContexts: connectionOptions.urlContexts)
    }

    // MARK: - URL Handling
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handle(urlContexts: URLContexts)
    }
}

// MARK: - Helpers
private extension SceneDelegate {
    func handle(urlContexts: Set<UIOpenURLContext>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        for context in urlContexts {
            _ = appDelegate.application(UIApplication.shared, open: context.url)
        }
    }
}
