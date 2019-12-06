//
//  ARKitViewController.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/5/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import FirebaseStorage

class ARKitViewController: UIViewController {
    
    // MARK: - Properties
    
    var sceneView: ARSCNView!
    var planes = [UUID : VirtualPlane]()
    var currentSceneURL: URL?
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupLogoutButton()
        loadModelsFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

// MARK: - Extension: Setup the UI
extension ARKitViewController {
    
    func setupLogoutButton() {
        let logoutButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        let defaultColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        logoutButton.setTitleColor(defaultColor, for: .normal)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
    func setupSceneView() {
        sceneView = ARSCNView()
        view.addSubview(sceneView)
        
        addConstraintsToSceneView()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Improves the lighting of the sceneView
        sceneView.autoenablesDefaultLighting = true
        
        // Sets debug options on the sceneView
        let debugValue: UInt = ARSCNDebugOptions.showWorldOrigin.rawValue | ARSCNDebugOptions.showFeaturePoints.rawValue
        sceneView.debugOptions = SCNDebugOptions(rawValue: debugValue)
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add a tap gesture recognizer (for adding models to sceneView)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(addCouchToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(recognizer)
    }
    
    func addConstraintsToSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
}

// MARK: - Extension: Firebase
extension ARKitViewController {
    
    func loadModelsFromFirebase() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        var url: URL?
        do {
            url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("An exception was thrown while trying to initialize url!")
            return
        }
        
        guard let documentsURL = url else {
            print("documentsURL was not able to be initialized!")
            return
        }
        
        let sceneURL = documentsURL.appendingPathComponent("couch_local.scn")
        currentSceneURL = sceneURL
        
        if FileManager.default.fileExists(atPath: sceneURL.path) {
            // If the file already exists locally, then we shouldn't load the file from Firebase again
            print("The file exists already!")
            return
        }
        
        let downloadTask = storageRef.child("models/couch.scn").write(toFile: sceneURL)
        downloadTask.observe(.success) { snapshot in
            print("The file was successfully downloaded from Firebase")
        }
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions
extension ARKitViewController {
    
    @objc func logoutButtonTapped(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addCouchToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        // Translates the hitTestResults to x/y/z coordinates for the tapped location
        guard let hitTestResult = hitTestResults.first else {
            print("hitTestResult was not able to be initialized!")
            return
        }
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        // Initializes the couchNode and adds it to sceneView
        guard let sceneURL = currentSceneURL else {
            print("currentSceneURL is nil!")
            return
        }
        let couchScene = try? SCNScene(url: sceneURL, options: nil)
        guard let couchNode = couchScene?.rootNode.childNode(withName: "couchModel", recursively: true) else {
            print("couchNode was not able to be initialized!")
            return
        }
        couchNode.position = SCNVector3(x,y,z)
        couchNode.scale = SCNVector3(0.75, 0.75, 0.75)
        sceneView.scene.rootNode.addChildNode(couchNode)
    }
    
}

// MARK: - Extension: ARSCNViewDelegate Functions
extension ARKitViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let arPlaneAnchor = anchor as? ARPlaneAnchor else {
            print("arPlaneAnchor was not able to be initialized!")
            return
        }
        let plane = VirtualPlane(anchor: arPlaneAnchor)
        self.planes[arPlaneAnchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let arPlaneAnchor = anchor as? ARPlaneAnchor else {
            print("arPlaneAnchor was not able to be initialized!")
            return
        }
        guard let plane = planes[arPlaneAnchor.identifier] else {
            print("plane was not able to be initialized!")
            return
        }
        plane.updateWithNewAnchor(arPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let arPlaneAnchor = anchor as? ARPlaneAnchor else {
            print("arPlaneAnchor was not able to be initialized!")
            return
        }
        guard let index = planes.index(forKey: arPlaneAnchor.identifier) else {
            print("index was not able to be initialized!")
            return
        }
        planes.remove(at: index)
        sceneView.scene.rootNode.removeAllActions()
    }
    
}
