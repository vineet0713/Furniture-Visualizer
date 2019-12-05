//
//  LoginViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/5/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginButton()
    }
    
}

// MARK: - Extension: Setup the UI
extension LoginViewController {
    
    func setupLoginButton() {
        let loginButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        let defaultColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        loginButton.setTitleColor(defaultColor, for: .normal)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions
extension LoginViewController {
    
    @objc func loginButtonTapped(sender: UIButton!) {
      performSegue(withIdentifier: "loginToARKitSegue", sender: self)
    }
    
}
