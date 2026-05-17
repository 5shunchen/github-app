//
//  AppDelegate.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        configureGitHubAuth()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "githubapp" {
            GitHubAuthManager.shared.handleCallback(url: url)
            return true
        }
        return false
    }
    
    private func configureGitHubAuth() {
        let config = GitHubAuthConfig(
            clientId: "YOUR_CLIENT_ID",
            clientSecret: "YOUR_CLIENT_SECRET",
            redirectUri: "githubapp://callback",
            scopes: ["user", "repo", "notifications"]
        )
        GitHubAuthManager.shared.configure(with: config)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        TokenRefreshManager.shared.invalidate()
    }
}
