//
//  EntityManager.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
  var entities = Set<GKEntity>()
  var scene: SCNScene

  init(scene: SCNScene) {
    self.scene = scene
  }

  func add(_ entity: GKEntity) {
    entities.insert(entity)

//    if let geometryNode = entity.component(ofType: GeometryComponent.self)?.geometryNode {
//      scene.rootNode.addChildNode(geometryNode)
//    }
  }

  func remove(_ entity: GKEntity) {
    if let geometryNode = entity.component(ofType: RenderComponent.self)?.node {
      geometryNode.removeFromParentNode()
    }

    entities.remove(entity)
  }
}
