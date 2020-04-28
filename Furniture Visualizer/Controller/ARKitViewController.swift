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
    
    var modelFilenameToSceneURL: [String: URL] = [:]
    var canProjectModels = true
    var modelMetadata: FurnitureModelMetadata?
    var projectedModels: [String] = []
    var sceneIsFullyMapped = false
    
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
        
        resetTrackingConfiguration(with: nil, enableOptions: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard modelFilenameToSceneURL.count == 0 else {
            return
        }
        guard let worldMap = unarchive() else {
            return
        }
        
        let message = "There is a previously saved AR scene. Would you like to load it?"
        let alert = UIAlertController(title: "Load AR Scene", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.loadProperties()
            self.resetTrackingConfiguration(with: worldMap, enableOptions: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
        sceneView.session.delegate = self
        
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
        let profileBarButton = UIBarButtonItem(title: "Profile", style: .plain, target: self,
                                               action: #selector(profileButtonTapped))
        navigationItem.leftBarButtonItem = profileBarButton
        let screenshotBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self,
                                                  action: #selector(screenshotButtonTapped))
        navigationItem.rightBarButtonItem = screenshotBarButton
    }
    
    func setupBottomStackView() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 5
        bottomStackView.setBackgroundColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5))
        
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        bottomStackView.addArrangedSubview(selectButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "save"), for: .normal)
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        saveButton.tintColor = .systemGreen
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        bottomStackView.addArrangedSubview(saveButton)
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(named: "clear"), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        bottomStackView.addArrangedSubview(deleteButton)
        
        let rateButton = UIButton(type: .system)
        rateButton.setTitle("Rate", for: .normal)
        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rateButton.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
        bottomStackView.addArrangedSubview(rateButton)
        
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
        let arScreenshot = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(arScreenshot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showAlert(title: "Unable to Save Screenshot", message: "Please make sure you allow access to your Photo Library.")
        } else {
            showAlert(title: "Screenshot Saved", message: "A screenshot of the ARKit Scene was saved to your Camera Roll.")
        }
    }
    
    @objc func selectButtonTapped() {
        performSegue(withIdentifier: "ARKitToSelectionSegue", sender: self)
    }
    
    @objc func saveButtonTapped() {
        guard sceneIsFullyMapped else {
            showAlert(title: "AR Scene Not Mapped", message: "Please pan around your surroundings to fully map the AR scene.")
            return
        }
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return
            }
            do {
                try self.archive(worldMap)
                self.saveProperties()
                self.showAlert(title: "Scene Saved", message: "The current AR scene has been saved.")
            } catch {
                print("error saving world map!")
            }
        }
    }
    
    @objc func deleteButtonTapped() {
        let message = "Are you sure you want to remove all projected furniture models?"
        let alert = UIAlertController(title: "Confirm Remove", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.removeAllNodes()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func rateButtonTapped() {
        guard let modelMetadata = modelMetadata else {
            return
        }
        let alert = UIAlertController(title: "Rate \(modelMetadata.title)", message: nil, preferredStyle: .alert)
        if let imageURL = FirebaseSingleton.shared.generateFileURL(for: modelMetadata.filename, using: "png") {
            var imageData: Data?
            do {
                imageData = try Data(contentsOf: imageURL)
            } catch {
                print("Image Data was not able to be initialized!")
            }
            if let imageData = imageData {
                alert.addImage(UIImage(data: imageData), maxSize: CGSize(width: 245, height: 300), inset: nil, handler: nil)
            }
        }
        // The width of a UIAlertController is 245.
        // So if the thumbsdown/thumbsup image width is 35, then the left inset should be (245-35)/2 = 105
        alert.addImage(UIImage(named: "thumbsup_green"), maxSize: CGSize(width: 35, height: 35), inset: 105) { (action) in
            self.updateRating(type: "thumbs-up", modelMetadata)
        }
        
        alert.addImage(UIImage(named: "thumbsdown"), maxSize: CGSize(width: 35, height: 35), inset: 105) { (action) in
            self.updateRating(type: "thumbs-down", modelMetadata)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        guard canProjectModels else {
            let warning = "Your device is almost out of memory. Therefore, you cannot project any more furniture models."
            showAlert(title: "Unable to Project Model", message: warning)
            return
        }
        
        guard let modelToProject = modelMetadata?.filename else {
            showAlert(title: "Model Not Selected", message: "Please select a model in order to project it.")
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
        
        let modelAnchor = ARAnchor(name: modelToProject, transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: modelAnchor)
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

// MARK: - Extension: @IBAction Function

extension ARKitViewController {
    
    @IBAction func unwindFromSelection(_ sender: UIStoryboardSegue) {
        guard let senderVC = sender.source as? SelectionViewController else {
            return
        }
        guard let selectedModel = senderVC.selectedModel else {
            return
        }
        modelMetadata = selectedModel
        projectedModels.append("\(selectedModel.filename)Model")
        
        // Download furniture model from Firebase
        DispatchQueue.global(qos: .userInitiated).async {
            FirebaseSingleton.shared.loadFromStorage(filePath: "models", fileName: selectedModel.filename,
                                                     fileExtension: "scn", completion: { (fileURL, error) in
                self.handleFirebaseResult(fileURL, error)
            })
        }
    }
    
}

// MARK: - Extension: ARSCNViewDelegate Functions

extension ARKitViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let modelName = anchor.name else {
            return nil
        }
        
        guard let sceneURL = modelFilenameToSceneURL[modelName] else {
            print("currentSceneURL is nil!")
            return nil
        }
        let modelScene = try? SCNScene(url: sceneURL, options: nil)
        guard let modelNode = modelScene?.rootNode.childNode(withName: "\(modelName)Model", recursively: true) else {
            print("\(modelName)Node was not able to be initialized!")
            return nil
        }
        
        modelNode.categoryBitMask = BodyType.ObjectModel.rawValue
        modelNode.enumerateChildNodes { (node, _) in
            node.categoryBitMask = BodyType.ObjectModel.rawValue
        }
        
        let rootNode = SCNNode()
        rootNode.addChildNode(modelNode)
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

// MARK: - Extension: ARSessionDelegate Functions

extension ARKitViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .mapped:
            sceneIsFullyMapped = true
        default:
            sceneIsFullyMapped = false
        }
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
        guard let nodeName = node.name else {
            return nil
        }
        if projectedModels.contains(nodeName) {
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
        guard let modelMetadata = modelMetadata else {
            return
        }
        modelFilenameToSceneURL[modelMetadata.filename] = fileURL
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
        case .downloadError:
            DispatchQueue.main.async {
                self.showAlert(title: "Unable to Load Model", message: "The 3D furniture model wasn't able to load.")
            }
        }
    }
    
    func updateRating(type: String, _ modelMetadata: FurnitureModelMetadata) {
        DispatchQueue.global(qos: .userInitiated).async {
            let firebasePath = "furnitureModel/\(modelMetadata.id)/\(type)"
            let updatedRating = (type == "thumbs-up") ? (modelMetadata.thumbsUp + 1) : (modelMetadata.thumbsDown + 1)
            FirebaseSingleton.shared.updateRatingToDatabase(path: firebasePath, newValue: updatedRating) { (error) in
                if let error = error {
                    print(error)
                } else {
                    if (type == "thumbs-up") {
                        self.modelMetadata?.thumbsUp = updatedRating
                    } else {
                        self.modelMetadata?.thumbsDown = updatedRating
                    }
                    self.showAlert(title: "Rating Posted", message: "Your rating was successfully posted for other users to see.")
                }
            }
        }
    }
    
    func removeAllNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        resetTrackingConfiguration(with: nil, enableOptions: true)
    }
    
}

// MARK: - Extension: ARKit Persistence Functions
// Source: https://www.appcoda.com/arkit-persistence/

extension ARKitViewController {
    
    func archive(_ worldMap: ARWorldMap) throws {
        let userDefaults = UserDefaults.standard
        
        // Save the world map data in UserDefaults
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        userDefaults.set(data, forKey: "box")
        
        userDefaults.synchronize()
    }
    
    func saveProperties() {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        // Save the modelMetadata struct in UserDefaults
        guard let encodedMetadata = try? encoder.encode(modelMetadata) else {
            return
        }
        userDefaults.set(encodedMetadata, forKey: "modelMetadata")
        
        // Save the keys of dictionary (mapping from a model filename to its scene URL) to UserDefaults
        guard let encodedModelFilenames = try? encoder.encode(Array(modelFilenameToSceneURL.keys)) else {
            return
        }
        userDefaults.set(encodedModelFilenames, forKey: "modelFilenames")
        
        // Save the projectedModels array to UserDefaults
        guard let encodedProjectedModelsArray = try? encoder.encode(projectedModels) else {
            return
        }
        userDefaults.set(encodedProjectedModelsArray, forKey: "projectedModels")
        
        userDefaults.synchronize()
    }
    
    func unarchive() -> ARWorldMap? {
        // Loads the world map data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "box") else {
            return nil
        }
        let unarchivedClasses = [ARWorldMap.classForKeyedUnarchiver()]
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: unarchivedClasses, from: data) else {
            return nil
        }
        return worldMap as? ARWorldMap
    }
    
    func loadProperties() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // Loads the modelMetadata struct from UserDefaults
        guard let savedMetadata = userDefaults.object(forKey: "modelMetadata") as? Data,
              let loadedMetadata = try? decoder.decode(FurnitureModelMetadata.self, from: savedMetadata) else {
            return
        }
        modelMetadata = loadedMetadata
        
        // Loads the keys of dictionary (mapping from a model filename to its scene URL) from UserDefaults
        guard let savedDictionaryKeys = userDefaults.object(forKey: "modelFilenames") as? Data,
            let loadedDictionaryKeys = try? decoder.decode([String].self, from: savedDictionaryKeys) else {
            return
        }
        modelFilenameToSceneURL = [:]
        for modelFilename in loadedDictionaryKeys {
            if let sceneUrl = FirebaseSingleton.shared.generateFileURL(for: modelFilename, using: "scn") {
                modelFilenameToSceneURL[modelFilename] = sceneUrl
            }
        }
        
        // Loads the projectedModels array from UserDefaults
        guard let savedArray = userDefaults.object(forKey: "projectedModels") as? Data,
              let loadedArray = try? decoder.decode([String].self, from: savedArray) else {
            return
        }
        projectedModels = loadedArray
    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap?, enableOptions: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
        }
        if enableOptions {
            let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
            sceneView.session.run(configuration, options: options)
        } else {
            sceneView.session.run(configuration)
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

// This extension is used to return a scaled image with the specified size.
// Source: https://www.youtube.com/watch?v=d-tWSeGj5MY
extension UIImage {
    func imageWithSize(_ size: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

// This extension is used to add an image to a UIAlertController.
// Source: https://www.youtube.com/watch?v=d-tWSeGj5MY
extension UIAlertController {
    func addImage(_ image: UIImage?, maxSize: CGSize, inset: CGFloat?, handler: ((UIAlertAction) -> Void)?) {
        guard let image = image else {
            return
        }
        let imageSize = image.size
        
        let ratio = (imageSize.width >= imageSize.height)
            ? (maxSize.width / imageSize.width)
            : (maxSize.height / imageSize.height)
        let scaledSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        var resizedImage = image.imageWithSize(scaledSize)
        if (imageSize.height >= imageSize.width) {
            let left = inset ?? ((maxSize.width - resizedImage.size.width) / 2)
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
        }
        
        let imageAction = UIAlertAction(title: "", style: .default, handler: handler)
        imageAction.isEnabled = (handler != nil)
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
    }
}
