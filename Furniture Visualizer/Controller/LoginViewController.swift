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
    let loginButton = UIButton(type: .system)
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginButton()
        setupTopLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        saveLoginInformation(user.displayName ?? "empty displayName", user.email ?? "empty email")
        performSegue(withIdentifier: "LoginToARKitSegue", sender: self)
    }
    
}

// MARK: - Extension: Setup the UI

extension LoginViewController {
    
    func setupLoginButton() {
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        addConstraintsToLoginButton()
    }
    
    func setupTopLabel() {
        topLabel.text = "Furniture Visualizer"
        topLabel.font = UIFont.systemFont(ofSize: 50)
        topLabel.textAlignment = .center
        topLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(topLabel)
        addConstraintsToTopLabel()
    }
    
}

// MARK: - Add Constraints to UI

extension LoginViewController {
    
    func addConstraintsToLoginButton() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
    
    @objc func loginButtonTapped() {
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
        
        saveLoginInformation(result.user.displayName ?? "empty displayName", result.user.email ?? "empty email")
        
        performSegue(withIdentifier: "LoginToARKitSegue", sender: self)
    }
    
}

// MARK: - Helper Function

extension LoginViewController {
    
    func saveLoginInformation(_ displayName: String, _ email: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(displayName, forKey: "displayName")
        userDefaults.set(email, forKey: "email")
        userDefaults.synchronize()
    }
    
}
