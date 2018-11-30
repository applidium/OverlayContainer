//
//  OverlayContainerViewControllerDelegate+Defaults.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 23/11/2018.
//

import Foundation

public extension OverlayContainerViewControllerDelegate {
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        transitionningDelegateForOverlay overlayViewController: UIViewController) -> OverlayTransitioningDelegate? {
        return nil
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return nil
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool {
        return true
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction? {
        return nil
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didDragOverlay overlayViewController: UIViewController,
                                        toHeight height: CGFloat,
                                        availableSpace: CGFloat) {}

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        willEndDraggingOverlay overlayViewController: UIViewController,
                                        endNotchIndex: Int,
                                        transitionCoordinator: OverlayContainerTransitionCoordinator) {}
}
