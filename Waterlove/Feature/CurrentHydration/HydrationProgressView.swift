//
//  HydrationProgressView.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 16.12.2021.
//

import UIKit
import SnapKit

class HydrationProgressView: UIView {
  struct Props {
    let progressBarProps: CircularProgressBar.Props
    let progressValue: CGFloat
    let intookWaterAmount: UInt

    static let initial = Props(progressBarProps: .initial, progressValue: 0, intookWaterAmount: 0)
  }

  var props: Props = .initial {
    didSet {
      render()
    }
  }

  private var circularProgressBar = CircularProgressBar(frame: .zero)

  private var containerView = UIView(frame: .zero)

  private var progressValueLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .largeTitle)
    label.textAlignment = .center
    label.numberOfLines = 0

    return label
  }()

  private var intookWaterAmountLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .title1)
    label.textAlignment = .center
    label.numberOfLines = 0

    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupViews()
    setupConstraints()
    render()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setupViews()
    setupConstraints()
    render()
  }

  private func setupViews() {
    addSubview(circularProgressBar)
    containerView.addSubview(progressValueLabel)
    containerView.addSubview(intookWaterAmountLabel)
    circularProgressBar.addSubview(containerView)
  }

  private func setupConstraints() {
    circularProgressBar.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    progressValueLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.right.equalToSuperview().offset(-8)
      make.left.equalToSuperview().offset(8)
      make.bottom.equalTo(intookWaterAmountLabel.snp.top)
    }

    intookWaterAmountLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(8)
      make.right.equalToSuperview().offset(-8)
      make.bottom.equalToSuperview().offset(-8)
    }

    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func render() {
    circularProgressBar.props = props.progressBarProps
    progressValueLabel.text = String(format: "%.0f %%", props.progressValue * 100)
    intookWaterAmountLabel.text = "\(props.intookWaterAmount) ml"
  }
}
