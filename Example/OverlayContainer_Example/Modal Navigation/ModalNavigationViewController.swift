//
//  ModalNavigationViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 27/02/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import OverlayContainer
import UIKit

class ModalNavigationViewController: UIViewController, SearchViewControllerDelegate {

    enum OverlayNotch: Int, CaseIterable {
        case minimum, maximum
    }

    private let overlayController = OverlayContainerViewController()
    private let overlayNavigationController = OverlayNavigationViewController()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        overlayController.delegate = self
        overlayNavigationController.delegate = self
        overlayController.viewControllers = [MapsViewController(), overlayNavigationController]
        pushSearchViewController()
        addChild(overlayController, in: view)
    }

    // MARK: - SearchViewControllerDelegate

    func searchViewControllerDidSelectARow(_ searchViewController: SearchViewController) {
        pushSearchViewController()
    }

    func searchViewControllerDidSelectCloseAction(_ searchViewController: SearchViewController) {
        overlayNavigationController.popViewController(animated: true)
    }

    // MARK: - Private

    private func pushSearchViewController() {
        let search = SearchViewController(showsCloseAction: true)
        search.delegate = self
        overlayNavigationController.push(search, animated: true)
    }
}

extension ModalNavigationViewController: OverlayNavigationViewControllerDelegate {

    // MARK: - OverlayNavigationViewControllerDelegate

    func overlayNavigationViewController(_ navigationController: OverlayNavigationViewController,
                                         didShow viewController: UIViewController,
                                         animated: Bool) {
        overlayController.drivingScrollView = (viewController as? SearchViewController)?.tableView
    }
}

extension ModalNavigationViewController: OverlayContainerViewControllerDelegate {

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
        case .minimum:
            return availableSpace * 1 / 4
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let header = (overlayNavigationController.topViewController as? SearchViewController)?.header else {
            return false
        }
        let convertedPoint = coordinateSpace.convert(point, to: header)
        return header.bounds.contains(convertedPoint)
    }
}

