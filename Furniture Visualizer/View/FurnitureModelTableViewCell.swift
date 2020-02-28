//
//  FurnitureModelTableViewCell.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 2/27/20.
//  Copyright © 2020 Vineet Joshi. All rights reserved.
//

import UIKit

class FurnitureModelTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    let SAMPLE_TITLE = "title"
    let SAMPLE_DESCRIPTION = "description"
    let SAMPLE_RATING = "100%"
    
    // MARK: - Properties
    
    let rootStackView = UIStackView()
    
    let modelImageView = UIImageView()
    let modelInfoStackView = UIStackView()
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let ratingStackView = UIStackView()
    
    let ratingImageView = UIImageView()
    let ratingLabel = UILabel()
    
    // MARK: - UITableViewCell Life Cycle Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        setupLabels()
        setupRatingStackView()
        setupModelInfoStackView()
        setupRootStackView()
        addConstraintsToRootStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}

// MARK: - Extension: Setup the UI

extension FurnitureModelTableViewCell {
    
    func setupLabels() {
        titleLabel.font = titleLabel.font.withSize(20)
        titleLabel.text = SAMPLE_TITLE
        titleLabel.textColor = .blue
        descriptionLabel.font = descriptionLabel.font.withSize(20)
        descriptionLabel.text = SAMPLE_DESCRIPTION
        descriptionLabel.textColor = .blue
        ratingLabel.font = ratingLabel.font.withSize(30)
        ratingLabel.text = SAMPLE_RATING
        ratingLabel.textColor = .blue
    }
    
    func setupRatingStackView() {
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .equalSpacing
        ratingStackView.spacing = 10
        ratingStackView.addArrangedSubview(ratingImageView)
        ratingStackView.addArrangedSubview(ratingLabel)
    }
    
    func setupModelInfoStackView() {
        modelInfoStackView.axis = .vertical
        modelInfoStackView.distribution = .equalSpacing
        modelInfoStackView.spacing = 10
        modelInfoStackView.addArrangedSubview(titleLabel)
        modelInfoStackView.addArrangedSubview(descriptionLabel)
        modelInfoStackView.addArrangedSubview(ratingStackView)
    }
    
    func setupRootStackView() {
        rootStackView.addArrangedSubview(modelImageView)
        rootStackView.addArrangedSubview(modelInfoStackView)
        contentView.addSubview(rootStackView)
    }
    
}

// MARK: - Add Constraints to UI

extension FurnitureModelTableViewCell {
    
    func addConstraintsToRootStackView() {
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
}
