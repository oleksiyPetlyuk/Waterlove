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
    let intookWaterAmount: Measurement<UnitVolume>

    static let initial = Props(progressBarProps: .initial, intookWaterAmount: .init(value: 0, unit: .milliliters))
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

  private let formatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit

    return formatter
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
    progressValueLabel.text = "\(props.progressBarProps.progress) %"
    intookWaterAmountLabel.text = formatter.string(from: props.intookWaterAmount)
  }
}
