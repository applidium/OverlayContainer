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

    enum OverlayNotch: Int, CaseIterable {
        case minimum, medium, maximum
    }

    private let searchViewController = SearchViewController(showsCloseAction: false)
    private let mapsViewController = MapsViewController()

    private var sizeClass: UIUserInterfaceSizeClass = .unspecified
    private var needsSetup = true

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shortcuts"
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard needsSetup else { return }
        needsSetup = false
        setUp(for: traitCollection)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.setUp(for: newCollection)
        }, completion: nil)
    }

    // MARK: - Private

    private func setUp(for traitCollection: UITraitCollection) {
        guard sizeClass != traitCollection.horizontalSizeClass else { return }
        sizeClass = traitCollection.horizontalSizeClass
        children.first.flatMap { removeChild($0) }
        switch sizeClass {
        case .compact:
            let overlayController = OverlayContainerViewController()
            overlayController.delegate = self
            overlayController.viewControllers = [
                mapsViewController,
                searchViewController
            ]
            addChild(overlayController, in: view)
        case .regular:
            let splitController = UISplitViewController()
            // (gz) 2018-12-03 Both `OverlayContainerViewController` & `StackViewController` disable autorizing mask.
            // whereas `UINavigationController` & `UISplitViewController` need it.
            searchViewController.view.translatesAutoresizingMaskIntoConstraints = true
            mapsViewController.view.translatesAutoresizingMaskIntoConstraints = true
            splitController.viewControllers = [
                UINavigationController(rootViewController: searchViewController),
                mapsViewController
            ]
            splitController.preferredDisplayMode = .allVisible
            addChild(splitController, in: view)
        case .unspecified:
            break
        @unknown default:
            break
        }
    }
}

extension ShortcutsLikeViewController: OverlayContainerViewControllerDelegate {

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch OverlayNotch.allCases[index] {
            case .maximum:
                return availableSpace * 3 / 4
            case .medium:
                return availableSpace / 2
            case .minimum:
                return availableSpace * 1 / 4
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (overlayViewController as? SearchViewController)?.tableView
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let header = (overlayViewController as? SearchViewController)?.header else {
            return false
        }
        return header.bounds.contains(coordinateSpace.convert(point, to: header))
    }
}
