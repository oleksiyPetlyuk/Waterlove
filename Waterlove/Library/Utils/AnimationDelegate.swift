//
//  AnimationDelegate.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 16.12.2021.
//

import Foundation
import QuartzCore

final class AnimationDelegate: NSObject, CAAnimationDelegate {
  let didStop: ((CAAnimation, Bool) -> Void)?

  init(didStop: ((CAAnimation, Bool) -> Void)? = nil) {
    self.didStop = didStop
  }

  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    self.didStop?(anim, flag)
  }
}
