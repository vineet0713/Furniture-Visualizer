//
//  SelectionViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/19/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit
import FirebaseStorage

class SelectionViewController: UIViewController {
    
    // MARK: - Constants
    
    let CELL_IDENTIFIER = "modelCell"
    let CELL_HEIGHT: CGFloat = 125
    
    // MARK: - Properties
    
    var tableView: UITableView!
    var modelData: [FurnitureModelMetadata] = []
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "Select Furniture"
        
        setupTableView()
        
        // Load the furniture model metadata from Firebase
        FirebaseSingleton.shared.loadFromDatabase(path: "furnitureModel") { (dataArray, error) in
            self.handleFirebaseResult(dataArray, error)
        }
    }
    
}

// MARK: - Extension: Setup the UI

extension SelectionViewController {
    
    func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(FurnitureModelTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        view.addSubview(tableView)
        addConstraintsToTableView()
    }
    
}

// MARK: - Add Constraints to UI

extension SelectionViewController {
    
    func addConstraintsToTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

// MARK: - UITableViewDataSource

extension SelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as? FurnitureModelTableViewCell else {
            return UITableViewCell()
        }
        
        let data = modelData[indexPath.row]
        
        // Get the Image from FireStorage
        
        let imgRef = Storage.storage().reference(withPath: "images/\(data.filename).png")
        
        imgRef.getData(maxSize: 1 * 1024 * 1024) { imgData, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                cell.modelImageView.image = UIImage(data: imgData!)
            }
        }
        
        cell.titleLabel.text = data.title
        cell.descriptionLabel.text = data.description
        
        // Set the Rating Image and Rating Color
        
        if (data.rating < 0.5) {
            cell.ratingImageView.image = UIImage(named: "thumbsup_red")
            cell.ratingLabel.textColor = .systemRed
        }
        else {
            cell.ratingImageView.image = UIImage(named: "thumbsup_green")
            cell.ratingLabel.textColor = .systemGreen
        }
        
        cell.ratingLabel.text = String(data.rating * 100) + "%"
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Handle the selection of a furniture model.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
}

// MARK: - Helper Functions

extension SelectionViewController {
    
    func handleFirebaseResult(_ dataArray: [[String:Any]]?, _ error: DatabaseError?) {
        guard let dataArray = dataArray else {
            print("Failed to load from database!")
            return
        }
        for data in dataArray {
            modelData.append(FurnitureModelMetadata(
                filename: (data["filename"] as? String) ?? "",
                title: (data["title"] as? String) ?? "",
                description: (data["description"] as? String) ?? "",
                rating: (data["rating"] as? Double) ?? 0))
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
