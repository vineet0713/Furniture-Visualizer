//
//  ProfileViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/19/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit
import FirebaseUI

class ProfileViewController: UIViewController {
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "My Profile"
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions

extension ProfileViewController {
    
    @objc func logoutButtonTapped() {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.logout()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Extension: Helper Function

extension ProfileViewController {
    
    func logout() {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        do {
            try authUI.signOut()
            print("signOut succeeded!")
        } catch {
            print("ERROR: signOut failed!")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
