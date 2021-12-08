//
//  TutorialViewController.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 07.12.2021.
//

import UIKit
import SnapKit

class TutorialViewController: UIViewController {
  @IBOutlet private weak var pageControl: UIPageControl!

  @IBOutlet private weak var pageViewContainer: UIView!

  var didFinishTutorial: (() -> Void)?

  private lazy var pageViewController: TutorialPageViewController = {
    let pageViewController = TutorialPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: nil
    )

    pageViewController.didUpdatePageIndex = { [weak self] index in
      self?.pageControl.currentPage = index
    }

    pageViewController.didUpdatePageCount = { [weak self] count in
      self?.pageControl.numberOfPages = count
    }

    return pageViewController
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    startPageViewController()
  }

  private func startPageViewController() {
    addChild(pageViewController)
    pageViewContainer.addSubview(pageViewController.view)

    pageViewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    pageViewController.didMove(toParent: self)
  }

  @IBAction func didChangePageControlValue(_ sender: UIPageControl) {
    pageViewController.scrollTo(index: pageControl.currentPage)
  }

  @IBAction func didTapNextButton(_ sender: UIButton) {
    if pageControl.currentPage < pageViewController.orderedViewControllers.count - 1 {
      pageViewController.scrollToNextViewController()

      return
    }

    if let didFinishTutorial = didFinishTutorial {
      didFinishTutorial()
    }
  }
}
