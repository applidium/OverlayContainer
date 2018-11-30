//
//  ShortcutsLikeViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 29/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import OverlayContainer
import UIKit

class ShortcutsLikeViewController: UIViewController {

    private let detailViewController = DetailViewController()
    private let masterViewController = MasterViewController()

    private var sizeClass: UIUserInterfaceSizeClass = .unspecified

    // MARK: - UIViewController

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpIfNeeded()
    }

    private func setUpIfNeeded() {
        guard sizeClass != traitCollection.horizontalSizeClass else { return }
        sizeClass = traitCollection.horizontalSizeClass
        children.first.flatMap { removeChild($0) }
        switch sizeClass {
        case .compact:
            let overlayController = OverlayContainerViewController()
            overlayController.delegate = self
            overlayController.viewControllers = [detailViewController]
            let stackController = StackViewController()
            stackController.viewControllers = [
                masterViewController,
                overlayController
            ]
            addChild(stackController, in: view)
        case .regular:
            let splitController = DivideViewController()
            splitController.leftViewController = detailViewController
            splitController.rightViewController = masterViewController
            addChild(splitController, in: view)
        case .unspecified:
            break
        }
    }
}

extension ShortcutsLikeViewController: OverlayContainerViewControllerDelegate {

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return 2
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        if index == 0 {
            return 200
        }
        return availableSpace - 200
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (overlayViewController as? DetailViewController)?.tableView
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let header = (overlayViewController as? DetailViewController)?.header else {
            return false
        }
        return header.bounds.contains(coordinateSpace.convert(point, to: header))
    }
}
