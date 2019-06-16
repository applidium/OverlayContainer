//
//  ShowOverlayExampleViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 11/04/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import OverlayContainer
import UIKit


class ShowOverlayExampleViewController: UIViewController,
    ActionViewControllerDelegate,
    OverlayContainerViewControllerDelegate {

    enum Notch: Int, CaseIterable {
        case min, med, max
    }

    private let actionViewController = ActionViewController()
    private let coloredViewController = ColoredViewController()
    private let overlayContainerController = OverlayContainerViewController()

    var showsOverlay = false
    var lastKnownOverlayHeight: CGFloat = 0

    // MARK: - UIViewController

    override func loadView() {
        view = UIView()
        addChild(overlayContainerController, in: view)
        actionViewController.delegate = self
        overlayContainerController.delegate = self
        overlayContainerController.viewControllers = [
            actionViewController,
            coloredViewController
        ]
    }

    // MARK: - ActionViewControllerDelegate

    func actionViewControllerDidSelectionAction() {
        showsOverlay.toggle()
        let targetNotch: Notch = showsOverlay ? .med : .min
        overlayContainerController.moveOverlay(toNotchAt: targetNotch.rawValue, animated: true)
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return Notch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch Notch.allCases[index] {
        case .max:
            return availableSpace - 100
        case .med:
            return availableSpace / 2
        case .min:
            return 0
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        willTranslateOverlay overlayViewController: UIViewController,
                                        transitionCoordinator: OverlayContainerTransitionCoordinator) {
        transitionCoordinator.animate(alongsideTransition: nil) { [weak self] context in
            self?.lastKnownOverlayHeight = context.targetTranslationHeight
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        willEndDraggingOverlay overlayViewController: UIViewController,
                                        atVelocity velocity: CGPoint) {
        let availableSpace = containerViewController.view.bounds.height
        let medHeight = availableSpace / 2
        let isUnderMedNotch = lastKnownOverlayHeight < medHeight
        let goesFast = velocity.y > 1200
        showsOverlay = !(isUnderMedNotch || goesFast)
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        canReachNotchAt index: Int,
                                        forOverlay overlayViewController: UIViewController) -> Bool {
        switch Notch.allCases[index] {
        case .max:
            return showsOverlay
        case .med:
            return showsOverlay
        case .min:
            return !showsOverlay
        }
    }
}
