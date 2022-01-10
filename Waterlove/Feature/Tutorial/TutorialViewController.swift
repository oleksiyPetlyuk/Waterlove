//
//  TutorialViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit
import SnapKit

class TutorialViewController: UIViewController {
  struct Props {
    let pageViewControllerProps: TutorialPageViewController.Props
    let didTapNextButton: Command
    let didChangePageControlValue: CommandWith<Int>
    let didFinishTutorial: Command

    static let initial = Props(
      pageViewControllerProps: .initial,
      didTapNextButton: .nop,
      didChangePageControlValue: .nop,
      didFinishTutorial: .nop
    )
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  @IBOutlet private weak var pageControl: UIPageControl!
  @IBOutlet private weak var pageViewContainer: UIView!

  private var pageViewController: TutorialPageViewController?

  override func viewDidLoad() {
    super.viewDidLoad()

    setupPageViewController()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    pageControl.numberOfPages = props.pageViewControllerProps.pages.count
    pageControl.currentPage = props.pageViewControllerProps.selectedPageIndex ?? 0

    pageViewController?.props = props.pageViewControllerProps
  }

  private func setupPageViewController() {
    let pageViewController = TutorialPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: nil
    )

    addChild(pageViewController)
    pageViewContainer.addSubview(pageViewController.view)

    pageViewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    pageViewController.didMove(toParent: self)

    self.pageViewController = pageViewController
  }

  @IBAction private func didChangePageControlValue(_ sender: UIPageControl) {
    props.didChangePageControlValue.perform(with: sender.currentPage)
  }

  @IBAction private func didTapNextButton(_ sender: UIButton) {
    if
      let selectedPageIndex = props.pageViewControllerProps.selectedPageIndex,
      selectedPageIndex < props.pageViewControllerProps.pages.count - 1 {
      props.didTapNextButton.perform()

      return
    }

    props.didFinishTutorial.perform()
  }
}
