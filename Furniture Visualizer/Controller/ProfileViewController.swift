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
    
    // MARK: - Constants
    
    let CELL_IDENTIFIER = "profileModelCell"
    let CELL_WIDTH = 175
    let CELL_HEIGHT = 200
    
    // MARK: - Properties
    
    var nameLabel: UILabel!
    var emailLabel: UILabel!
    var changePasswordButton: UIButton!
    var collectionView: UICollectionView!
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "My Profile"
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
        
        setupUI()
        
        addConstraintsToNameLabel()
        addConstraintsToEmailLabel()
        addConstraintsToChangePasswordButton()
        addConstraintsToCollectionView()
    }
    
}

// MARK: - Extension: Setup the UI

extension ProfileViewController {
    
    func setupUI() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 21)
        view.addSubview(nameLabel)
        
        emailLabel = UILabel()
        emailLabel.font = UIFont.systemFont(ofSize: 21)
        view.addSubview(emailLabel)
        
        setLabelText()
        
        changePasswordButton = UIButton(type: .system)
        changePasswordButton.setTitle("Change Password", for: .normal)
        changePasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        view.addSubview(changePasswordButton)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: CELL_WIDTH, height: CELL_HEIGHT)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(ProfileFurnitureModelCollectionViewCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
        collectionView.backgroundColor = .systemBlue
        view.addSubview(collectionView)
    }
    
    func setLabelText() {
        let userDefaults = UserDefaults.standard
        nameLabel.text = "Name: " + (userDefaults.string(forKey: "displayName") ?? "[nonexistent name]")
        emailLabel.text = "Email: " + (userDefaults.string(forKey: "email") ?? "[nonexistent email]")
    }
    
}

// MARK: - Add Constraints to UI

extension ProfileViewController {
    
    func addConstraintsToNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10)
        ])
    }
    
    func addConstraintsToEmailLabel() {
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 25),
            emailLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10)
        ])
    }
    
    func addConstraintsToChangePasswordButton() {
        changePasswordButton.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            changePasswordButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 25),
            changePasswordButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    func addConstraintsToCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: changePasswordButton.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
}

// MARK: - UICollectionViewDataSource

// TODO: Fetch the correct data for this user and populate the cell.
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as? ProfileFurnitureModelCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.modelImageView.image = UIImage(named: "placeholder")
        if indexPath.row % 3 == 0 {
            cell.titleLabel.text = "Computer Desk"
            cell.modelImageView.downloadImage(with: "desk")
            cell.ratingImageView.image = UIImage(named: "thumbsup_green")
        } else if indexPath.row % 3 == 1 {
            cell.titleLabel.text = "Bed"
            cell.modelImageView.downloadImage(with: "bed")
            cell.ratingImageView.image = UIImage(named: "thumbsup_red")
        } else if indexPath.row % 3 == 2 {
            cell.titleLabel.text = "Fireplace"
            cell.modelImageView.downloadImage(with: "fireplace")
            cell.ratingImageView.image = UIImage(named: "thumbsup_grey")
        }
        
        return cell
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
    
    @objc func changePasswordButtonTapped() {
        let message = "This feature has not been implemented yet. Stay tuned!"
        let alert = UIAlertController(title: "Nonexistent Feature", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
