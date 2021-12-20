//
//  PageViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
  struct Props {
    let pages: [TutorialStepViewController.Props]
    let selectedPageIndex: Int?
    let didUpdatePageIndex: CommandWith<Int>

    static let initial = Props(pages: [], selectedPageIndex: nil, didUpdatePageIndex: .nop)
  }

  var props: Props = .initial {
    didSet {
      guard isViewLoaded else { return }

      view.setNeedsLayout()
    }
  }

  private var orderedViewControllers: [TutorialStepViewController] = []

  private var currentViewController: TutorialStepViewController? {
    guard let viewController = viewControllers?.first else { return nil }

    return viewController as? TutorialStepViewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    delegate = self
  }

  override func viewWillLayoutSubviews() {
    for page in props.pages {
      guard let controller = R.storyboard.main.tutorialStepViewController() else { return }

      controller.props = .init(id: page.id, image: page.image, heading: page.heading, subheading: page.subheading)

      if !orderedViewControllers.contains(where: { $0.props.id == page.id }) {
        orderedViewControllers.append(controller)
      }
    }

    if
      let selectedPageIndex = props.selectedPageIndex,
      orderedViewControllers.indices.contains(selectedPageIndex),
      orderedViewControllers[selectedPageIndex].props.id != currentViewController?.props.id {
      if
        let currentViewController = currentViewController,
        let index = orderedViewControllers.firstIndex(of: currentViewController),
        index < selectedPageIndex {
        scrollTo(viewController: orderedViewControllers[selectedPageIndex])
      } else {
        scrollTo(viewController: orderedViewControllers[selectedPageIndex], direction: .reverse)
      }
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
      let firstViewController = viewControllers?.first as? TutorialStepViewController,
      let index = orderedViewControllers.firstIndex(of: firstViewController) {
      props.didUpdatePageIndex.perform(with: index)
    }
  }
}

// MARK: Page View Controller DataSource
extension TutorialPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard
      let tutorialStepViewController = viewController as? TutorialStepViewController,
      let viewControllerIndex = orderedViewControllers.firstIndex(of: tutorialStepViewController)
    else {
      return nil
    }

    let previousIndex = viewControllerIndex - 1

    return (previousIndex == -1) ? nil : orderedViewControllers[previousIndex]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard
      let tutorialStepViewController = viewController as? TutorialStepViewController,
      let viewControllerIndex = orderedViewControllers.firstIndex(of: tutorialStepViewController)
    else {
      return nil
    }

    let nextIndex = viewControllerIndex + 1

    return (nextIndex == orderedViewControllers.count) ? nil : orderedViewControllers[nextIndex]
  }
}

// MARK: Page View Controller Delegate
extension TutorialPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    notifyAboutNewIndex()
  }
}
