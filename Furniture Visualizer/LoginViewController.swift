//
//  LoginViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/5/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    let topLabel = UILabel()
    let loginButton = UIButton()
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopLabel()
        setupLoginButton()
    }
    
}

// MARK: - Extension: Setup the UI
extension LoginViewController {
    
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
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            topLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75)
        ])
    }
    
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
    
}

// MARK: - Extension: Objective-C Exposed Functions
extension LoginViewController {
    
    @objc func loginButtonTapped(sender: UIButton!) {
      performSegue(withIdentifier: "loginToARKitSegue", sender: self)
    }
    
}
