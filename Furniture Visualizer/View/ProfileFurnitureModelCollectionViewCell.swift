//
//  ProfileFurnitureModelCollectionViewCell.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 5/5/20.
//  Copyright © 2020 Vineet Joshi. All rights reserved.
//

import UIKit

class ProfileFurnitureModelCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    let SAMPLE_TITLE = "title"
    
    let MODEL_IMAGE_VIEW_HEIGHT = CGFloat(140)
    let RATING_IMAGE_VIEW_HEIGHT = CGFloat(30)
    
    // MARK: - Properties
    
    let modelImageView = UIImageView()
    let titleLabel = UILabel()
    let ratingImageView = UIImageView()
    
    // MARK: - UICollectionViewCell Life Cycle Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        setupUI()
        
        addConstraintsToModelImageView()
        addConstraintsToTitleLabel()
        addConstraintsToRatingImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Extension: Setup the UI

extension ProfileFurnitureModelCollectionViewCell {
    
    func setupUI() {
        titleLabel.font = titleLabel.font.withSize(16)
        titleLabel.textAlignment = .center
        titleLabel.text = SAMPLE_TITLE
        
        ratingImageView.bounds = .zero
        ratingImageView.contentMode = .scaleAspectFit
        
        modelImageView.bounds = .zero
        modelImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(modelImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingImageView)
    }
    
}

// MARK: - Add Constraints to UI

extension ProfileFurnitureModelCollectionViewCell {
    
    func addConstraintsToModelImageView() {
        modelImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modelImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            modelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            modelImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            modelImageView.heightAnchor.constraint(equalToConstant: MODEL_IMAGE_VIEW_HEIGHT)
        ])
    }
    
    func addConstraintsToTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: modelImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalTo: ratingImageView.heightAnchor)
        ])
    }
    
    func addConstraintsToRatingImageView() {
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingImageView.topAnchor.constraint(equalTo: modelImageView.bottomAnchor, constant: 10),
            ratingImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            ratingImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            ratingImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            ratingImageView.heightAnchor.constraint(equalToConstant: RATING_IMAGE_VIEW_HEIGHT),
            ratingImageView.widthAnchor.constraint(equalTo: ratingImageView.heightAnchor)
        ])
    }
    
}
