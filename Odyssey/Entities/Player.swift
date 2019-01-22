//
//  Player.swift
//  Odyssey
//
//  Created by Willie Johnson on 1/20/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import GameplayKit

class Player: GKEntity {
  let agent: GKAgent3D

  var renderComponent: RenderComponent {
    guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A Player must have an RenderComponent.") }
    return renderComponent
  }

  override init() {
    agent = GKAgent3D()

    super.init()

    let renderComponent = RenderComponent()
    addComponent(renderComponent)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
