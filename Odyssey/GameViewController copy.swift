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
  @IBOutlet var sceneView: SCNView!
  /// The main node controlled by user during gameplay.
  var player: SCNNode!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupScene()
  }

  @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // check what nodes are tapped
    let p = gestureRecognize.location(in: sceneView)
    let hitResults = sceneView.hitTest(p, options: [:])
    // check that we clicked on at least one object
    if hitResults.count > 0 {
      // retrieved the first clicked object
      let result = hitResults[0]

      // get its material
      let material = result.node.geometry!.firstMaterial!

      // highlight it
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 0.5

      // on completion - unhighlight
      SCNTransaction.completionBlock = {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5

        material.emission.contents = UIColor.black

        SCNTransaction.commit()
      }

      material.emission.contents = UIColor.red

      SCNTransaction.commit()
    }
  }
}

/// MARK: - Configuration
extension GameViewController {
  /// Create scene and nodes
  func setupScene() {
    sceneView.allowsCameraControl = true
    sceneView.showsStatistics = true
    sceneView.backgroundColor = UIColor.black

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    sceneView.addGestureRecognizer(tapGesture)

    guard let scene = sceneView.scene else { return }

    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)

    cameraNode.position = SCNVector3(x: 0, y: 0, z: 45)

    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    scene.rootNode.addChildNode(lightNode)

    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)

    let playerScene = SCNScene(named: "art.scnassets/ship.scn")!

    player = scene.rootNode.childNode(withName: "ship", recursively: true)!

    let ground = SCNPlane(width: 100, height: 100)
    ground.firstMaterial?.diffuse.contents = UIColor.lightGray
    ground.firstMaterial?.isDoubleSided = true

    let groundNode = SCNNode(geometry: ground)
//    groundNode.position = SCNVector3(0, 0, 0)
    groundNode.eulerAngles = SCNVector3(0, 0, 0)

    scene.rootNode.addChildNode(groundNode)

  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }

}
