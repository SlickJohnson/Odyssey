//
//  PhysicsComponent.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
  var physicsbody: SKPhysicsBody

  init(physicsbody: SKPhysicsBody) {
    self.physicsbody = physicsbody
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("nope")
  }
}
