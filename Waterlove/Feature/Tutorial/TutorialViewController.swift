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
    let onDidFinishTutorial: Command

    static let initial = Props(onDidFinishTutorial: .nop)
  }

  private(set) var props: Props = .initial

  @IBOutlet private weak var pageControl: UIPageControl!

  @IBOutlet private weak var pageViewContainer: UIView!

  private var pageViewController: TutorialPageViewController?

  override func viewDidLoad() {
    super.viewDidLoad()

    addPageViewController()
  }

  func render(_ props: Props) {
    self.props = props

    view.setNeedsLayout()
  }

  private func makeProps() -> TutorialPageViewController.Props {
    return .init(
      onUpdatePageCount: .init { [weak self] count in
        self?.pageControl.numberOfPages = count
      },
      onUpdatePageIndex: .init { [weak self] index in
        self?.pageControl.currentPage = index
      }
    )
  }

  private func addPageViewController() {
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

    pageViewController.render(makeProps())

    self.pageViewController = pageViewController
  }

  @IBAction func didChangePageControlValue(_ sender: UIPageControl) {
    pageViewController?.scrollTo(index: sender.currentPage)
  }

  @IBAction func didTapNextButton(_ sender: UIButton) {
    if
      let pageViewController = pageViewController,
      pageControl.currentPage < pageViewController.orderedViewControllers.count - 1 {
      pageViewController.scrollToNextViewController()

      return
    }

    props.onDidFinishTutorial.perform()
  }
}
