//
//  CircularProgressBar.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 15.12.2021.
//

import UIKit

class CircularProgressBar: UIView {
  struct Props {
    let progress: UInt8

    static let initial = Props(progress: 0)
  }

  private enum Constants {
    static let color: UIColor = .systemBlue
    static let ringWidth: CGFloat = 15
  }

  var props: Props = .initial {
    didSet {
      setNeedsDisplay()
    }
  }

  private var backgroundLayer = CAShapeLayer()
  private var progressLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupLayers()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setupLayers()
  }

  override func draw(_ rect: CGRect) {
    let circularPath = createCircularPath(in: rect)

    backgroundLayer.path = circularPath.cgPath

    progressLayer.path = circularPath.cgPath
    progressLayer.lineCap = .round
    progressLayer.strokeStart = 0

    let strokeEnd = CGFloat(props.progress) / 100
    progressLayer.strokeEnd = strokeEnd
    progressLayer.strokeColor = Constants.color.cgColor

    addAnimation(layer: progressLayer, keyPath: "strokeEnd") {
      self.progressLayer.strokeEnd = strokeEnd
    }
  }
}

extension CircularProgressBar {
  private func setupLayers() {
    backgroundLayer.lineWidth = Constants.ringWidth
    backgroundLayer.fillColor = UIColor.clear.cgColor
    backgroundLayer.strokeColor = UIColor.lightGray.cgColor
    layer.addSublayer(backgroundLayer)

    progressLayer.lineWidth = Constants.ringWidth
    progressLayer.fillColor = UIColor.clear.cgColor
    layer.addSublayer(progressLayer)
  }

  private func createCircularPath(in rect: CGRect) -> UIBezierPath {
    let width = rect.width
    let height = rect.height
    let centre = CGPoint(x: width / 2, y: height / 2)
    let radius = (min(width, height) - Constants.ringWidth) / 2
    let startAngle = -CGFloat.pi / 2
    let endAngle = startAngle + 2 * CGFloat.pi

    return UIBezierPath(arcCenter: centre, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
  }

  private func addAnimation(layer: CAShapeLayer, keyPath: String, onComplete: @escaping () -> Void) {
    let animation = CABasicAnimation(keyPath: keyPath)

    animation.duration = 1
    animation.timingFunction = .init(name: .easeInEaseOut)
    animation.delegate = AnimationDelegate { _, completed in
      guard completed else { return }

      onComplete()
    }

    layer.add(animation, forKey: keyPath)
  }
}
