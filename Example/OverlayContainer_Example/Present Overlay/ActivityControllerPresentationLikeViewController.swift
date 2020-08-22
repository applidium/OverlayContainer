//
//  ActivityControllerPresentationLikeViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 10/04/2020.
//  Copyright © 2020 Gaétan Zanella. All rights reserved.
//

import UIKit
import OverlayContainer

class ActivityControllerPresentationLikeViewController: UIViewController,
    UIViewControllerTransitioningDelegate,
    OverlayTransitioningDelegate,
    OverlayContainerViewControllerDelegate,
    OverlayContainerSheetPresentationControllerDelegate,
    ActionViewControllerDelegate {

    enum Notch: Int, CaseIterable {
        case minimum, medium, maximum
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - ActionViewControllerDelegate

    func actionViewControllerDidSelectionAction() {
        let container = OverlayContainerViewController()
        container.viewControllers = [ColoredViewController()]
        container.delegate = self
        container.moveOverlay(toNotchAt: Notch.medium.rawValue, animated: false)
        container.transitioningDelegate = self
        container.modalPresentationStyle = .custom
        present(container, animated: true, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let dimmingView = TransparentOverlayContainerSheetDimmingView()
        dimmingView.minimumAlpha = 0.0
        dimmingView.maximumAlpha = 0.1
        let controller = OverlayContainerSheetPresentationController(
            dimmingView: dimmingView,
            presentedViewController: presented,
            presenting: presenting
        )
        controller.sheetDelegate = self
        return controller
    }

    // MARK: - OverlayContainerSheetPresentationControllerDelegate

    func overlayContainerSheetDismissalPolicy(for presentationController: OverlayContainerSheetPresentationController) -> OverlayContainerSheetDismissalPolicy {
        var policy = ThresholdOverlayContainerSheetDismissalPolicy()
        policy.dismissingVelocity = .value(2400)
        policy.dismissingPosition = .notch(index: Notch.medium.rawValue)
        return policy
    }

    // MARK: - OverlayTransitioningDelegate

    func overlayTargetNotchPolicy(for overlayViewController: UIViewController) -> OverlayTranslationTargetNotchPolicy? {
        ActivityControllerLikeTargetNotchPolicy()
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        Notch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        transitioningDelegateForOverlay overlayViewController: UIViewController) -> OverlayTransitioningDelegate? {
        self
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch Notch.allCases[index] {
        case .minimum:
            return 100
        case .medium:
            return 300
        case .maximum:
            return availableSpace - 200
        }
    }

    // MARK: - Private

    private func setUp() {
        let action = ActionViewController()
        action.delegate = self
        addChild(action, in: view)
    }
}

struct ActivityControllerLikeTargetNotchPolicy: OverlayTranslationTargetNotchPolicy {

    func targetNotchIndex(using context: OverlayContainerContextTargetNotchPolicy) -> Int {
        let movesUp = context.velocity.y < 0
        if movesUp {
            // (gz) The container can easily move up
            return RushingForwardTargetNotchPolicy().targetNotchIndex(using: context)
        } else {
            // (gz) The container can not easily move down
            let defaultPolicy = RushingForwardTargetNotchPolicy()
            defaultPolicy.minimumVelocity = 2400
            return defaultPolicy.targetNotchIndex(using: context)
        }
    }
}
