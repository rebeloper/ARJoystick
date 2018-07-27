//
//  ViewController.swift
//  ARJoystick
//
//  Created by Alex Nagy on 27/07/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// MARK: - Game State

struct GameState {
  static let detectSurface = 0  // Scan playable surface (Plane Detection On)
  static let pointToSurface = 1 // Point to surface to see focus point (Plane Detection Off)
  static let readyToPlay = 2    // Focus point visible on surface, we are ready to play
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  
  let arscnView: ARSCNView = {
    let view = ARSCNView()
    return view
  }()
  
//  lazy var skView: SKView = {
//    let view = SKView()
//    view.isMultipleTouchEnabled = true
//    view.backgroundColor = .clear
//    view.isHidden = true
//    return view
//  }()
  
  lazy var startButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    button.setTitle("Start", for: .normal)
    button.tintColor = .white
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    button.isHidden = true
    return button
  }()
  
  var gameState: Int = GameState.detectSurface
  var focusPoint: CGPoint!
  var gameWorldCenterTransform: SCNMatrix4 = SCNMatrix4Identity
  var statusMessage: String = ""
  var trackingStatus: String = ""
  
  var focusNode: SCNNode!
  
  var floorTemplateNode: SCNNode!
  var floor: SCNNode!
  
  var heroTemplateNode: SCNNode!
  var hero: SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupARSCNView()
//    setupSKView()
    initSceneView()
    initScene()
    initARSession()
    loadModels()
    addFocusNode()
    setupARSCNViewSubviews()
//    setupSKViewScene()
    
//    NotificationCenter.default.addObserver(forName: joystickNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
//      guard let userInfo = notification.userInfo else { return }
//      let data = userInfo["data"] as! AnalogJoystickData
//
//      //      print(data.description)
//
//      self.hero.position = SCNVector3(self.hero.position.x + Float(data.velocity.x * joystickVelocityMultiplier), self.hero.position.y, self.hero.position.z - Float(data.velocity.y * joystickVelocityMultiplier))
//
//      self.hero.eulerAngles.y = Float(data.angular) + Float(180.0.degreesToRadians)
//
//    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  func setupARSCNView() {
    view.addSubview(arscnView)
    arscnView.fillSuperview()
  }
  
  func setupARSCNViewSubviews() {
    arscnView.addSubview(startButton)
    
    startButton.anchor(arscnView.safeAreaLayoutGuide.topAnchor, left: arscnView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: arscnView.safeAreaLayoutGuide.rightAnchor, topConstant: 6, leftConstant: 6, bottomConstant: 0, rightConstant: 6, widthConstant: 0, heightConstant: 44)
    
  }
  
//  func setupSKView() {
//    view.addSubview(skView)
//    skView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 180)
//  }
//
//  func setupSKViewScene() {
//    let scene = ARJoystickSKScene(size: CGSize(width: view.bounds.size.width, height: 180))
//    scene.scaleMode = .resizeFill
//    skView.presentScene(scene)
//    skView.ignoresSiblingOrder = true
//    //    skView.showsFPS = true
//    //    skView.showsNodeCount = true
//    //    skView.showsPhysics = true
//  }
  
  // MARK: - Initialization
  
  func initSceneView() {
    arscnView.delegate = self
    arscnView.autoenablesDefaultLighting = true
    
    focusPoint = CGPoint(x: view.center.x,
                         y: view.center.y + view.center.y * 0.25)
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    arscnView.scene = scene
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print(Constants.arWorldTrackingNotSupportedTrackingStatusMessage)
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    arscnView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
  }
  
  // MARK: - Load Models
  
  func loadModels() {
    
    let focusScene = SCNScene(named: Constants.focusScenePath)!
    focusNode = focusScene.rootNode.childNode(withName: Constants.focusNodeName, recursively: false)!
    focusNode.isHidden = true
    
    let floorScene = SCNScene(named: Constants.floorScenePath)!
    floorTemplateNode = floorScene.rootNode.childNode(withName: Constants.floorNodeName, recursively: false)!
    
    let heroScene = SCNScene(named: Constants.heroScenePath)!
    heroTemplateNode = heroScene.rootNode.childNode(withName: Constants.heroNodeName, recursively: false)!
    
  }
  
  // MARK: - Add Focus Node
  
  func addFocusNode() {
    arscnView.scene.rootNode.addChildNode(focusNode)
  }
  
  // MARK: - Helper Functions
  
  func createARPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
    let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = Constants.surfaceTexturePath
    planeGeometry.materials = [planeMaterial]
    
    let planeNode = SCNNode(geometry: planeGeometry)
    planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    
    return planeNode
  }
  
  func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
    let planeGeometry = planeNode.geometry as! SCNPlane
    planeGeometry.width = CGFloat(planeAchor.extent.x)
    planeGeometry.height = CGFloat(planeAchor.extent.z)
    planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
  }
  
  func removeARPlaneNode(node: SCNNode) {
    for childNode in node.childNodes {
      childNode.removeFromParentNode()
    }
  }
  
  func updateFocusNode() {
    let results = self.arscnView.hitTest(self.focusPoint,
                                         types: [.existingPlaneUsingExtent])
    
    if results.count == 1 {
      if let match = results.first {
        let t = match.worldTransform
        self.focusNode.position = SCNVector3( x: t.columns.3.x,
                                              y: t.columns.3.y + 0.01,
                                              z: t.columns.3.z)
        self.gameState = GameState.readyToPlay
      }
    } else {
      self.gameState = GameState.pointToSurface
    }
  }
  
  func suspendARPlaneDetection() {
    let config = arscnView.session.configuration as! ARWorldTrackingConfiguration
    config.planeDetection = []
    arscnView.session.run(config)
  }
  
  func hideARPlaneNodes() {
    for anchor in (self.arscnView.session.currentFrame?.anchors)! {
      if let node = self.arscnView.node(for: anchor) {
        for child in node.childNodes {
          let material = child.geometry?.materials.first!
          material?.colorBufferWriteMask = []
        }
      }
    }
  }
  
  // MARK: - Game Logic
  
  @objc func startGame() {
    DispatchQueue.main.async {
      self.startButton.isHidden = true
      self.focusNode.isHidden = true
      self.suspendARPlaneDetection()
      self.hideARPlaneNodes()
      self.gameState = GameState.pointToSurface
      self.createGameWorld()
    }
  }
  
  func createGameWorld() {
    gameWorldCenterTransform = focusNode.transform
//    skView.isHidden = false
    
    addFloor(to: arscnView.scene.rootNode)
    addHero()
  }
  
  func addFloor(to rootNode: SCNNode) {
    floor = floorTemplateNode.clone()
    floor.name = Constants.floorNodeName
    
    floor.position = SCNVector3(gameWorldCenterTransform.m41,
                                gameWorldCenterTransform.m42,
                                gameWorldCenterTransform.m43)
    
    let rotate = simd_float4x4(SCNMatrix4MakeRotation(arscnView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
    let rotateTransform = simd_mul(simd_float4x4(gameWorldCenterTransform), rotate)
    floor.transform = SCNMatrix4(rotateTransform)
    
    rootNode.addChildNode(floor)
  }
  
  func addHero() {
    hero = heroTemplateNode.clone()
    hero.name = Constants.heroNodeName
    hero.position = SCNVector3(0.0, 0.005, 0.0)
    hero.eulerAngles = SCNVector3(0,180.0.degreesToRadians,0)
    hero.scale = SCNVector3(0.0004, 0.0004, 0.0004)
    floor.addChildNode(hero)
  }
  
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
      self.updateFocusNode()
    }
  }
  
  func updateStatus() {
    
    switch gameState {
    case GameState.detectSurface:
      statusMessage = Constants.detectSurfaceStatusMessage
    case GameState.pointToSurface:
      statusMessage = Constants.pointToSurfaceStatusMessage
    case GameState.readyToPlay:
      statusMessage = Constants.readyToPlayStatusMessage
    default:
      statusMessage = Constants.noSuchGameStateStatusMessage
    }
    
    let status = statusMessage != "" ?
      "\(trackingStatus)\n\(statusMessage)" : "\(trackingStatus)"
    
    print("Status: \(status)")
  }
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = Constants.notAvailableTrackingStatusMessage
      break
    case .normal:
      self.trackingStatus = Constants.normalTrackingStatusMessage
      break
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = Constants.excessiveMotionTrackingStatusMessage
        break
      case .insufficientFeatures:
        self.trackingStatus = Constants.insufficientFeaturesTrackingStatusMessage
        break
      case .relocalizing:
        self.trackingStatus = Constants.relocalizingTrackingStatusMessage
        break
      case .initializing:
        self.trackingStatus = Constants.initializingTrackingStatusMessage
        break
      }
    }
  }
  
  // MARK: - Session Error Managent
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    DispatchQueue.main.async {
      self.trackingStatus = "\(Constants.sessionDidFailWithErrorStatusMessage)\(error.localizedDescription)"
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    DispatchQueue.main.async {
      self.trackingStatus = Constants.sessionWasInterruptedStatusMessage
    }
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    DispatchQueue.main.async {
      self.trackingStatus = Constants.sessionInterruptionEndedStatusMessage
    }
  }
  
  // MARK: - Plane Management
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    if let planeAnchor = anchor as? ARPlaneAnchor {
      
      DispatchQueue.main.async {
        let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
        
        if self.startButton.isHidden {
          self.startButton.isHidden = false
        }
        if self.focusNode.isHidden {
          self.focusNode.isHidden = false
        }
      }
      
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0 {
      DispatchQueue.main.async {
        self.updateARPlaneNode(planeNode: node.childNodes[0], planeAchor: planeAnchor)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.removeARPlaneNode(node: node)
    }
  }
  
}

