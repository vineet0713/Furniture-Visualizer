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

class ARKitViewController: UIViewController {
    
    // MARK: - Properties
    
    var sceneView: ARSCNView!
    var bottomStackView = UIStackView()
    
    var currentSceneURL: URL?
    var canProjectModels = true
    
    enum BodyType: Int {
        case ObjectModel = 2
    }
    var currentAngleY: Float = 0.0
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Furniture AR"
        
        setupSceneView()
        setupNavigationBar()
        setupBottomStackView()
        
        registerGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Download couch model
        DispatchQueue.global(qos: .userInitiated).async {
            FirebaseSingleton.shared.loadFromStorage(fileName: "couch", fileExtension: "scn", completion: { (fileURL, error) in
                self.handleFirebaseResult(fileURL, error)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        canProjectModels = false
    }
    
}

// MARK: - Extension: Setup the UI

extension ARKitViewController {
    
    func setupSceneView() {
        sceneView = ARSCNView()
        view.addSubview(sceneView)
        addConstraintsToSceneView()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
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
    
    func setupNavigationBar() {
        let profileBarButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileButtonTapped))
        navigationItem.leftBarButtonItem = profileBarButton
        let screenshotBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(screenshotButtonTapped))
        navigationItem.rightBarButtonItem = screenshotBarButton
    }
    
    func setupBottomStackView() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 5
        bottomStackView.setBackgroundColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5))
        
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select Furniture", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        bottomStackView.addArrangedSubview(selectButton)
        
        view.addSubview(bottomStackView)
        addConstraintsToBottomStackView()
    }
    
    func registerGestureRecognizers() {
        // Add a tap gesture recognizer (for adding models to sceneView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add a pan gesture recognizer (for moving the models)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        // Add a pinch gesture recognizer (for resizing the models)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        // Add a rotation gesture recognizer (for rotating the models)
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        sceneView.addGestureRecognizer(rotationGestureRecognizer)
    }
    
}

// MARK: - Add Constraints to UI

extension ARKitViewController {
    
    func addConstraintsToSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addConstraintsToBottomStackView() {
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}

// MARK: - Extension: Objective-C Exposed Functions

extension ARKitViewController {
    
    @objc func profileButtonTapped() {
        performSegue(withIdentifier: "ARKitToProfileSegue", sender: self)
    }
    
    @objc func screenshotButtonTapped() {
        // TODO: Save screenshot of the existing scene.
        let alertTitle = "Nonexistent Feature"
        let alertMessage = "This feature has not been implemented yet. Stay tuned!"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func selectButtonTapped() {
        performSegue(withIdentifier: "ARKitToSelectionSegue", sender: self)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        guard canProjectModels else {
            let warning = "Your device is almost out of memory. Therefore, you cannot project any more furniture models."
            showAlert(title: "Unable to Project Model", message: warning)
            return
        }
        
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
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
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
        
        let hitTestPlane = sceneView.hitTest(touch, types: .existingPlane)
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
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
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
    
    @objc func handleRotation(recognizer: UIRotationGestureRecognizer) {
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showCameraAccessDeniedAlert()
    }
    
}

// MARK: - Extension: Helper Functions

extension ARKitViewController {
    
    // Find the parent node for 3D model
    func getParentNodeOf(_ nodeFound: SCNNode?) -> SCNNode? {
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
    func getTouchPoint(from recognizer: UIGestureRecognizer) -> CGPoint? {
        guard let recognizerView = recognizer.view as? ARSCNView else {
            print("recognizerView was not able to be initialized!")
            return nil
        }
        return recognizer.location(in: recognizerView)
    }
    
    // Get the modelNodeHit from a UIGestureRecognizer and a touch point
    func getModelNodeHit(from recognizer: UIGestureRecognizer, using touchPoint: CGPoint) -> SCNNode? {
        let hitTestResult = sceneView.hitTest(
            touchPoint,
            options: [SCNHitTestOption.categoryBitMask: BodyType.ObjectModel.rawValue]
        )
        
        guard let modelNodeHit = getParentNodeOf(hitTestResult.first?.node)?.parent else {
            print("modelNodeHit was not able to be initialized!")
            return nil
        }
        return modelNodeHit
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCameraAccessDeniedAlert() {
        let message = """
                This app needs to access the camera in order to help you visualize the furniture.
                Please go to Settings and allow the app to access the camera.
        """
        let alert = UIAlertController(title: "Camera Access Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            self.openSettings()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
    
    func handleFirebaseResult(_ fileURL: URL?, _ error: StorageError?) {
        currentSceneURL = fileURL
        guard let error = error else {
            print("The scene file was successfully downloaded from Firebase!")
            return
        }
        switch error {
        case .urlError:
            print("An exception was thrown while trying to initialize url!")
            showAlert(
                title: "Unable to Save Model",
                message: "You have run out of disk space, so you cannot save the 3D Model.")
        case .documentsUrlError:
            print("documentsURL was not able to be initialized!")
            showAlert(
                title: "Unable to Save Model",
                message: "You have run out of disk space, so you cannot save the 3D Model.")
        case .fileAlreadyExistsError:
            print("The scene file exists already, so it won't be downloaded from Firebase.")
        case .downloadError:
            DispatchQueue.main.async {
                self.showAlert(title: "Unable to Load Model", message: "The 3D furniture model wasn't able to load.")
            }
        }
    }
    
}

// MARK: - Extension: UIStackView

// This extension is used to change the background color of a UIStackView.
// Source: https://stackoverflow.com/questions/34868344/how-to-change-the-background-color-of-uistackview
extension UIStackView {
    func setBackgroundColor(_ color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
