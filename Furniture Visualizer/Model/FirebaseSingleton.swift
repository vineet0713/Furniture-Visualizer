//
//  FirebaseSingleton.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 2/27/20.
//  Copyright © 2020 Vineet Joshi. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

enum StorageError {
    case urlError
    case documentsUrlError
    case downloadError
}

enum DatabaseError {
    case invalidData
}

class FirebaseSingleton {
    static let shared = FirebaseSingleton()
    private init() { }
    
    private lazy var storageRef: StorageReference = {
        return Storage.storage().reference()
    }()
    private lazy var databaseRef: DatabaseReference = {
        return Database.database().reference()
    }()
    
    func loadFromStorage(filePath: String, fileName: String, fileExtension: String,
                         completion: @escaping (_ fileURL: URL?, _ error: StorageError?) -> Void) {
        var fileURL: URL!
        
        var url: URL?
        do {
            url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            completion(fileURL, StorageError.urlError)
            return
        }
        
        guard let documentsURL = url else {
            completion(fileURL, StorageError.documentsUrlError)
            return
        }
        
        fileURL = documentsURL.appendingPathComponent("\(fileName)_local.\(fileExtension)")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // If the file already exists locally, then we shouldn't load the file from Firebase again
            completion(fileURL, nil)
            return
        }
        
        storageRef.child("\(filePath)/\(fileName).\(fileExtension)").write(toFile: fileURL) { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(fileURL, StorageError.downloadError)
            }
            completion(fileURL, nil)
        }
    }
    
    func loadFromDatabase(path: String,
                          completion: @escaping (_ data: [[String:Any]]?, _ error: DatabaseError?) -> Void) {
        databaseRef.child(path).observeSingleEvent(of: .value) { (snapshot) in
            guard let dataArray = snapshot.value as? [Any] else {
                completion(nil, DatabaseError.invalidData)
                return
            }
            // Remove invalid values that may exist in the dataArray
            var modelData: [[String:Any]] = []
            for data in dataArray {
                if let data = data as? [String:Any] {
                    modelData.append(data)
                }
            }
            completion(modelData, nil)
        }
    }
    
}
