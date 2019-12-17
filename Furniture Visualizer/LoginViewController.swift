//
//  LoginViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/5/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    let topLabel = UILabel()
    let loginButton = UIButton()
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginButton()
        setupTopLabel()
    }
    
}

// MARK: - Extension: Setup the UI
extension LoginViewController {
    
    func setupLoginButton() {
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        let defaultColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        loginButton.setTitleColor(defaultColor, for: .normal)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        addConstraintsToLoginButton()
    }
    
    func addConstraintsToLoginButton() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupTopLabel() {
        topLabel.text = "Furniture Visualizer"
        topLabel.font = UIFont.systemFont(ofSize: 50)
        topLabel.textAlignment = .center
        topLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(topLabel)
        addConstraintsToTopLabel()
    }
    
    func addConstraintsToTopLabel() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -100),
            topLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75)
        ])
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions
extension LoginViewController {
    
    @objc func loginButtonTapped(sender: UIButton!) {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        authUI.delegate = self
        authUI.providers = [FUIEmailAuth()]
        present(authUI.authViewController(), animated: true, completion: nil)
    }
    
}

// MARK: - Extension: FUIAuthDelegate Functions
extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let result = authDataResult else {
            print("authDataResult is nil!")
            return
        }
        
        print(result.user.uid)
        print("isEmailVerified: \(result.user.isEmailVerified)")
        print("isAnonymous: \(result.user.isAnonymous)")
        print(result.user.displayName ?? "empty displayName")
        print(result.user.email ?? "empty email")
        print(result.user.phoneNumber ?? "empty phoneNumber")
        print(result.user.photoURL ?? "empty photoURL")
        print(result.user.metadata)
        
        performSegue(withIdentifier: "loginToARKitSegue", sender: self)
    }
    
}
