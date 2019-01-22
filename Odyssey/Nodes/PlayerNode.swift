//
//  PlayerNode.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit
import SceneKit
import GameplayKit

class PlayerNode: SCNNode, GKAgentDelegate {
  var enabled = true

//  var stateMachine: GKStateMachine!
//
//  func enterNormalState() {
//    self.stateMachine.enterState(NormalState)
//  }

  var agent = GKAgent3D()

  func agentWillUpdate(_ agent: GKAgent) {
    if let agent = agent as? GKAgent3D {
      agent.position = float3(x: position.x, y: position.y, z: position.z)
    }
  }

  func agentDidUpdate(_ agent: GKAgent) {
    if let agent = agent as? GKAgent3D {
      position = SCNVector3(CGFloat(agent.position.x), CGFloat(agent.position.y), CGFloat(agent.position.z))
    }
  }
}
