//
//  FurnitureModelMetadata.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 2/27/20.
//  Copyright © 2020 Vineet Joshi. All rights reserved.
//

import Foundation

struct FurnitureModelMetadata: Codable {
    let id: Int
    let filename: String
    let title: String
    let description: String
    var thumbsUp: Int
    var thumbsDown: Int
}
