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
    
    let MODEL_IMAGE_VIEW_WIDTH = CGFloat(250)
    let MODEL_IMAGE_VIEW_HEIGHT = CGFloat(180)

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
        titleLabel.textColor = .black
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        descriptionLabel.text = SAMPLE_DESCRIPTION
        descriptionLabel.textColor = .systemGray
        ratingLabel.font = ratingLabel.font.withSize(18)
        ratingLabel.text = SAMPLE_RATING
    }
    
    func setupRatingStackView() {
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 5
        ratingImageView.bounds = CGRect(x: 0, y: 0, width: 5, height: 5)
        ratingImageView.contentMode = .scaleAspectFit
        ratingStackView.addArrangedSubview(ratingImageView)
        ratingStackView.addArrangedSubview(ratingLabel)
    }
    
    func setupModelInfoStackView() {
        modelInfoStackView.axis = .vertical
        modelInfoStackView.distribution = .fillEqually
        modelInfoStackView.spacing = 5
        modelInfoStackView.addArrangedSubview(titleLabel)
        modelInfoStackView.addArrangedSubview(descriptionLabel)
        modelInfoStackView.addArrangedSubview(ratingStackView)
    }
    
    func setupRootStackView() {
        rootStackView.axis = .horizontal
        rootStackView.distribution = .fillEqually
        rootStackView.spacing = 10
        modelImageView.bounds = CGRect(x: 0, y: 0, width: MODEL_IMAGE_VIEW_WIDTH, height: MODEL_IMAGE_VIEW_HEIGHT)
        modelImageView.contentMode = .scaleAspectFit
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
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
}
