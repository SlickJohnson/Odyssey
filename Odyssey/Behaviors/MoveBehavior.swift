//
//  MoveBehavior.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import GameplayKit
import SpriteKit

class MoveBehavior: GKBehavior {
  init(targetSpeed: Float, seek: GKAgent, avoid: [GKAgent]) {
    super.init()

    if targetSpeed > 0 {
      setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))
      setWeight(0.5, for: GKGoal(toSeekAgent: seek))
      setWeight(1.0, for: GKGoal(toAvoid: avoid, maxPredictionTime: 1.0))
    }
  }
}
