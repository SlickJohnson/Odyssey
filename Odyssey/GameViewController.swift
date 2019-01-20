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

class GameViewController: UIViewController {

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
  }

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

    enemyNode.constraints = [SCNLookAtConstraint(target: playerNode)]
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

extension GameViewController : SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    let player = playerNode.presentation
    let playerPosition = player.position


    let targetPosition = SCNVector3(x: playerPosition.x, y: playerPosition.y + 5, z: playerPosition.z + 5)
    var cameraPosition = cameraPivotNode.position

    let camDamping: Float = 0.3

    let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
    let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
    let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping

    cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
    cameraPivotNode.position = cameraPosition

    motion.getAccelerometerData { (x, y, z) in
      self.motionForce = SCNVector3(x: x * 0.30, y: 0, z: (y + 0.4) * -0.30)
    }

    playerNode.physicsBody?.applyForce(motionForce, asImpulse: true)

    let enemyPosition = enemyNode.presentation.position
    //Aim
    let angle = enemyPosition.angleBetweenVectors(playerPosition)
    
//    enemyNode.rotation.z = angle

    // Seek
//    let vx = cos(angle) * 1
//    let vz = sin(angle) * 1

    enemyNode.physicsBody?.applyForce(SCNVector3(0, 0, 0), asImpulse: true)
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

