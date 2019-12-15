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
    var currentSceneURL: URL?
    
    enum BodyType: Int {
        case ObjectModel = 2
    }
    var currentAngleY: Float = 0.0
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        registerGestureRecognizers()
        setupLogoutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadModelsFromFirebase()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

// MARK: - Extension: Setup the UI
extension ARKitViewController {
    
    private func setupSceneView() {
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
    }
    
    private func addConstraintsToSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func registerGestureRecognizers() {
        // Add a tap gesture recognizer (for adding models to sceneView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add a pan gesture recognizer (for moving the models)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
        
        // Add a pinch gesture recognizer (for resizing the models)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        // Add a rotation gesture recognizer (for rotating the models)
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.sceneView.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    private func setupLogoutButton() {
        let logoutButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        let defaultColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        logoutButton.setTitleColor(defaultColor, for: .normal)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
}

// MARK: - Extension: Firebase
extension ARKitViewController {
    
    private func loadModelsFromFirebase() {
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
        if FileManager.default.fileExists(atPath: sceneURL.path) {
            // If the file already exists locally, then we shouldn't load the file from Firebase again
            print("The scene file exists already, so it won't be downloaded from Firebase.")
            return
        }
        currentSceneURL = sceneURL
        
        storageRef.child("models/couch.scn").write(toFile: sceneURL) { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("The scene file was successfully downloaded from Firebase!")
        }
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions
extension ARKitViewController {
    
    @objc private func logoutButtonTapped(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else {
            print("recognizerView was not able to be initialized!")
            return
        }
        
        let touch = recognizer.location(in: recognizerView)
        guard let hitTestResult = recognizerView.hitTest(touch, types: .existingPlane).first else {
            print("hitTestResult was not able to be initialized!")
            return
        }
        
        let couchAnchor = ARAnchor(name: "couch", transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: couchAnchor)
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .changed else {
            print("recognizer.state is not changed, so we don't need to do anything")
            return
        }
        
        guard let touch = getTouchPoint(from: recognizer),
              let modelNodeHit = getModelNodeHit(from: recognizer, using: touch)
        else {
            print("modelNodeHit is nil!")
            return
        }
        
        let hitTestPlane = self.sceneView.hitTest(touch, types: .existingPlane)
        guard let planeHit = hitTestPlane.first else {
            print("hitTestPlane.first is nil!")
            return
        }
        
        modelNodeHit.position = SCNVector3(
            planeHit.worldTransform.columns.3.x,
            // planeHit.worldTransform.columns.3.y,
            modelNodeHit.position.y,
            planeHit.worldTransform.columns.3.z
        )
    }
    
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .changed else {
            print("recognizer.state is not changed, so we don't need to do anything")
            return
        }
        
        guard let touch = getTouchPoint(from: recognizer),
              let modelNodeHit = getModelNodeHit(from: recognizer, using: touch)
        else {
            print("modelNodeHit is nil!")
            return
        }
        
        let pinchScaleX = Float(recognizer.scale * CGFloat((modelNodeHit.scale.x)))
        let pinchScaleY = Float(recognizer.scale * CGFloat((modelNodeHit.scale.y)))
        let pinchScaleZ = Float(recognizer.scale * CGFloat((modelNodeHit.scale.z)))
        
        modelNodeHit.scale = SCNVector3Make(pinchScaleX, pinchScaleY, pinchScaleZ)
        recognizer.scale = 1
    }
    
    @objc private func handleRotation(recognizer: UIRotationGestureRecognizer) {
        guard let touch = getTouchPoint(from: recognizer),
              let modelNodeHit = getModelNodeHit(from: recognizer, using: touch)
        else {
            print("modelNodeHit is nil!")
            return
        }
        
        switch recognizer.state {
        case .changed:
            let rotation = Float(recognizer.rotation)
            modelNodeHit.eulerAngles.y = currentAngleY - rotation
        default:
            // for '.ended', '.cancelled', '.failed'
            currentAngleY = modelNodeHit.eulerAngles.y
        }
    }
    
}

// MARK: - Extension: ARSCNViewDelegate Functions
extension ARKitViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor.name == "couch" else {
            return nil
        }
        
        guard let sceneURL = currentSceneURL else {
            print("currentSceneURL is nil!")
            return nil
        }
        let couchScene = try? SCNScene(url: sceneURL, options: nil)
        guard let couchNode = couchScene?.rootNode.childNode(withName: "couchModel", recursively: true) else {
            print("couchNode was not able to be initialized!")
            return nil
        }
        
        couchNode.categoryBitMask = BodyType.ObjectModel.rawValue
        couchNode.enumerateChildNodes { (node, _) in
            node.categoryBitMask = BodyType.ObjectModel.rawValue
        }
        
        let rootNode = SCNNode()
        rootNode.addChildNode(couchNode)
        return rootNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("Plane Detected")
        }
    }
    
}

// MARK: - Extension: Helper Functions
extension ARKitViewController {
    
    // Find the parent node for 3D model
    private func getParentNodeOf(_ nodeFound: SCNNode?) -> SCNNode? {
        guard let node = nodeFound else {
            print("nodeFound is nil!")
            return nil
        }
        if node.name == "couchModel" {
            return node
        }
        guard let parent = node.parent else {
            print("node.parent is nil!")
            return nil
        }
        return getParentNodeOf(parent)
    }
    
    // Get the touch point (CGPoint) from a UIGestureRecognizer
    private func getTouchPoint(from recognizer: UIGestureRecognizer) -> CGPoint? {
        guard let recognizerView = recognizer.view as? ARSCNView else {
            print("recognizerView was not able to be initialized!")
            return nil
        }
        return recognizer.location(in: recognizerView)
    }
    
    // Get the modelNodeHit from a UIGestureRecognizer and a touch point
    private func getModelNodeHit(from recognizer: UIGestureRecognizer, using touchPoint: CGPoint) -> SCNNode? {
        let hitTestResult = self.sceneView.hitTest(
            touchPoint,
            options: [SCNHitTestOption.categoryBitMask: BodyType.ObjectModel.rawValue]
        )
        
        guard let modelNodeHit = getParentNodeOf(hitTestResult.first?.node)?.parent else {
            print("modelNodeHit was not able to be initialized!")
            return nil
        }
        return modelNodeHit
    }
    
}
