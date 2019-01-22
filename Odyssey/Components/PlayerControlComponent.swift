//
//  PlayerControlComponent.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import GameplayKit
import SceneKit

class PlayerControlComponent: GKComponent {
  var geometryComponent: RenderComponent? {
    return entity?.component(ofType: RenderComponent.self)
  }

//  /// Makes the geometry component jump.
//  func jump() {
//    let jumpVector = SCNVector3(x: 0, y: 2, z:  0)
//    geometryComponent?.applyImpulse(jumpVector)
//  }
}
