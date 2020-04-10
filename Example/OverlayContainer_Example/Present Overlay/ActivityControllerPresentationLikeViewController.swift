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
        let root = UIViewController()
        root.addChild(container, in: root.view)
        root.transitioningDelegate = self
        root.modalPresentationStyle = .custom
        present(root, animated: true, completion: nil)
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
        var policy = DefaultOverlayContainerSheetDismissalPolicy()
        policy.threshold = .notch(index: Notch.medium.rawValue)
        return policy
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        Notch.allCases.count
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
