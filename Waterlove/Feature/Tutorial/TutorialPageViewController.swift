//
//  PageViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
  struct Props {
    let onUpdatePageCount: CommandWith<Int>
    let onUpdatePageIndex: CommandWith<Int>

    static let initial = Props(onUpdatePageCount: .nop, onUpdatePageIndex: .nop)
  }

  private(set) var props: Props = .initial

  private(set) var orderedViewControllers: [UIViewController] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    delegate = self

    setupViewControllers()
  }

  func render(_ props: Props) {
    self.props = props

    view.setNeedsLayout()
  }

  private func setupViewControllers() {
    if let vcZero = R.storyboard.main.tutorialStepZero() {
      orderedViewControllers.append(vcZero)
    }

    if let vcOne = R.storyboard.main.tutorialStepOne() {
      orderedViewControllers.append(vcOne)
    }

    if let vcTwo = R.storyboard.main.tutorialStepTwo() {
      orderedViewControllers.append(vcTwo)
    }

    if let initialViewController = orderedViewControllers.first {
      scrollTo(viewController: initialViewController)
    }

    props.onUpdatePageCount.perform(with: orderedViewControllers.count)
  }

  /**
   Scrolls to the next view controller.
   */
  func scrollToNextViewController() {
    if
      let visibleViewController = viewControllers?.first,
      let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
      scrollTo(viewController: nextViewController)
    }
  }

  /**
   Scrolls to the view controller at the given index. Automatically calculates
   the direction.

   - parameter newIndex: the new index to scroll to
   */
  func scrollTo(index newIndex: Int) {
    if
      let firstViewController = viewControllers?.first,
      let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
      let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
      let nextViewController = orderedViewControllers[newIndex]
      scrollTo(viewController: nextViewController, direction: direction)
    }
  }

  /**
   Scrolls to the given 'viewController' page.

   - parameter viewController: the view controller to show.
   */
  private func scrollTo(viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward) {
    setViewControllers([viewController], direction: direction, animated: true) { [weak self] _ in
      // Setting the view controller programmatically does not fire
      // any delegate methods, so we have to manually notify about the new index
      self?.notifyAboutNewIndex()
    }
  }

  /**
   Notifies that the current page index was updated.
   */
  private func notifyAboutNewIndex() {
    if
      let firstViewController = viewControllers?.first,
      let index = orderedViewControllers.firstIndex(of: firstViewController) {
      props.onUpdatePageIndex.perform(with: index)
    }
  }
}

// MARK: UIPageViewControllerDataSource
extension TutorialPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
      return nil
    }

    let previousIndex = viewControllerIndex - 1

    return (previousIndex == -1) ? nil : orderedViewControllers[previousIndex]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
      return nil
    }

    let nextIndex = viewControllerIndex + 1

    return (nextIndex == orderedViewControllers.count) ? nil : orderedViewControllers[nextIndex]
  }
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    notifyAboutNewIndex()
  }
}
