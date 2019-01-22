//
//  GameViewController.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/14/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

class GameViewController: UIViewController {

  // MARK: Properties
  var entityManager: EntityManager!

  /// The physics categories for the nodes in the scene.
  struct Category {
    static let none = 0
    static let player = 1
    static let tree = 2
    static let enemy = 3
    static let floor = 4
    static let all = Int.max
  }

  var sceneView: SCNView!
  var scene: SCNScene!

  /// Manages player control components.
  let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)

  /// Manages particle components.
  let particleComponentSystem = GKComponentSystem(componentClass: ParticleComponent.self)

  /// Holds entities to prevent deallocation.
  var entities = [GKEntity]()

  /// Last update time.
  var previousUpdateTime: TimeInterval = 0

  // MARK: Initialization

  var playerNode: SCNNode!
  var enemyNode: SCNNode!

  var cameraPivotNode: SCNNode!
  var camera: SCNNode!

  var massLabel: SCNText!

  var motion = MotionHelper()
  var motionForce = SCNVector3(0, 0, 0)

  var sounds:[String:SCNAudioSource] = [:]

  override func viewDidLoad() {
    setupScene()
    setupNodes()
    setupSounds()

    setUpEntities()
    addComponentsToComonentSystems()
  }

  override var shouldAutorotate: Bool {
    return false
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
}

// MARK: - Methods
extension GameViewController {
  func setupScene() {
    sceneView = self.view as! SCNView
    sceneView.delegate = self

    //sceneView.allowsCameraControl = true
    scene = SCNScene(named: "art.scnassets/MainScene.scn")
    sceneView.scene = scene

    scene.physicsWorld.contactDelegate = self

    let tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1

    tapRecognizer.addTarget(self, action: #selector(sceneViewTapped(recognizer:)))
    sceneView.addGestureRecognizer(tapRecognizer)
  }

  func setupNodes() {
    playerNode = scene.rootNode.childNode(withName: "player", recursively: true)!
    playerNode.physicsBody?.categoryBitMask = Category.player
    playerNode.physicsBody?.contactTestBitMask = Category.tree | Category.enemy
    playerNode.physicsBody?.collisionBitMask = Category.enemy | Category.floor | Category.tree

    enemyNode = scene.rootNode.childNode(withName: "enemy", recursively: true)!
    enemyNode.physicsBody?.categoryBitMask = Category.enemy
    enemyNode.physicsBody?.contactTestBitMask = Category.player | Category.tree
    enemyNode.physicsBody?.collisionBitMask = Category.player | Category.floor | Category.tree

    cameraPivotNode = scene.rootNode.childNode(withName: "cameraPivot", recursively: true)!

    //    massLabel.string = "MASS"
    camera = cameraPivotNode.childNode(withName: "camera", recursively: true)
    camera.constraints = [SCNLookAtConstraint(target: playerNode)]
  }

  func setupSounds() {
    let sawSound = SCNAudioSource(fileNamed: "chainsaw.wav")!
    let jumpSound = SCNAudioSource(fileNamed: "jump.wav")!
    sawSound.load()
    jumpSound.load()
    sawSound.volume = 0.3
    jumpSound.volume = 0.4

    sounds["saw"] = sawSound
    sounds["jump"] = jumpSound
  }

  func setUpEntities() {
    entityManager = EntityManager(scene: scene)
    
  }

  func makeBoxEntity(forNodeWithName name: String, wantsPlayerControlComponent: Bool = false, withParticleComponentNamed particleComponentName: String? = nil) -> GKEntity {
    // Create the box entity and grab its node from the scene.
    let box = GKEntity()
    guard let boxNode = scene.rootNode.childNode(withName: name, recursively: false) else {
      fatalError("Making box with name \(name) failed because the GameScene scene file contains no nodes with that name.")
    }

//    // Create and attach a geometry component to the box.
//    let geometryComponent = GeometryComponent(geometryNode: boxNode)
//    box.addComponent(geometryComponent)

    // If requested, create and attach a particle component.
    if let particleComponentName = particleComponentName {
      let particleComponent = ParticleComponent(particleName: particleComponentName)
      box.addComponent(particleComponent)
    }

    // If requested, create and attach a player control component.
    if wantsPlayerControlComponent {
      let playerControlComponent = PlayerControlComponent()
      box.addComponent(playerControlComponent)
    }

    return box
  }

  func addComponentsToComonentSystems() {
    for entity in entities {
      particleComponentSystem.addComponent(foundIn: entity)
      playerControlComponentSystem.addComponent(foundIn: entity)
    }
  }

  @objc func sceneViewTapped (recognizer: UITapGestureRecognizer) {
    let location = recognizer.location(in: sceneView)

    let hitResults = sceneView.hitTest(location, options: nil)

    guard hitResults.count > 0, let result = hitResults.first else { return }

    let node = result.node
    if node.name == "player" {
      let jumpSound = sounds["jump"]!
      playerNode.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
      playerNode.physicsBody?.applyForce(SCNVector3(x: 0, y: 4, z: -2), asImpulse: true)
    }
  }
}

extension GameViewController : SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    let player = playerNode.presentation
    let playerPosition = player.position

    let timeSincePreviousUpdate = time - previousUpdateTime

    particleComponentSystem.update(deltaTime: timeSincePreviousUpdate)

    previousUpdateTime = time

    let targetPosition = SCNVector3(x: playerPosition.x, y: playerPosition.y + 5, z: playerPosition.z)
    var cameraPosition = cameraPivotNode.position

    let camDamping: Float = 0.25

    let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
    let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
    let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping

    cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
    cameraPivotNode.position = cameraPosition

    motion.getAccelerometerData { (x, y, z) in
      self.motionForce = SCNVector3(x: x * 4, y: 0, z: (z + 0.3) * 2)
    }

    playerNode.physicsBody?.applyForce(motionForce, asImpulse: false)

    let enemyPosition = enemyNode.presentation.position
    //Aim
    let dx = playerPosition.x - enemyPosition.x
    let dz = playerPosition.z - enemyPosition.z
    print("Enemy: \(enemyNode.physicsBody!.velocity)\nPlayer: \(playerNode.physicsBody!.velocity)\n\n")
    let angle = atan2(dz, dx)

    // Seek
    let vx = cos(angle) * 4.5
    let vz = sin(angle) * 4.5

    enemyNode.physicsBody?.applyForce(SCNVector3(vx, 0, vz), asImpulse: false)
  }
}

extension GameViewController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    var contactNode: SCNNode!

    if contact.nodeA.name == "player" {
      contactNode = contact.nodeB
    }else{
      contactNode = contact.nodeA
    }

    if contactNode.physicsBody?.categoryBitMask == Category.tree {
      contactNode.isHidden = true

      let sawSound = sounds["saw"]!
      playerNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))

      let waitAction = SCNAction.wait(duration: 15)
      let unhideAction = SCNAction.run { (node) in
        node.isHidden = false
      }
      let actionSequence = SCNAction.sequence([waitAction, unhideAction])
  
      contactNode.runAction(actionSequence)
    }
  }
}

