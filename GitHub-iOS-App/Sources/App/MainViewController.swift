//
//  MainViewController.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import UIKit

public final class MainViewController: UIViewController {
    
    private var isAuthenticated: Bool {
        GitHubAuthManager.shared.isAuthenticated
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStatusChanged),
            name: NSNotification.Name("AuthStatusChanged"),
            object: nil
        )
    }
    
    private func setupInitialState() {
        if isAuthenticated {
            showProfile()
        } else {
            showLogin()
        }
    }
    
    @objc private func authStatusChanged() {
        setupInitialState()
    }
    
    private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        
        if let presented = presentedViewController {
            presented.dismiss(animated: false)
        }
        
        present(navController, animated: true)
    }
    
    private func showProfile() {
        let profileVC = ProfileViewController()
        profileVC.delegate = self
        
        let navController = UINavigationController(rootViewController: profileVC)
        navController.modalPresentationStyle = .fullScreen
        
        if let presented = presentedViewController {
            presented.dismiss(animated: false)
        }
        
        present(navController, animated: true)
    }
}

extension MainViewController: LoginViewControllerDelegate {
    public func loginDidSucceed() {
        NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
    }
    
    public func loginDidCancel() {
        print("Login cancelled")
    }
}

extension MainViewController: ProfileViewControllerDelegate {
    public func didLogout() {
        NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
    }
}
