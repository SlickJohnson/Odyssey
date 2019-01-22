//
//  GeometryComponent.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import Foundation

import SceneKit
import GameplayKit

class RenderComponent: GKComponent {
  let node = SCNNode()

  override func didAddToEntity() {
    node.entity = entity
  }

  override func willRemoveFromEntity() {
    node.entity = nil
  }
}
