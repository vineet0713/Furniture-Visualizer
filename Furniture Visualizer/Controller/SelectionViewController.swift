//
//  SelectionViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/19/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

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
        cell.titleLabel.text = data.title
        cell.descriptionLabel.text = data.description
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