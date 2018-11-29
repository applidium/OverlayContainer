//
//  OverlayContainerViewControllerDelegate.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 23/11/2018.
//

import Foundation

public protocol OverlayContainerViewControllerDelegate: class {
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView?
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        transitionningDelegateForOverlay overlayViewController: UIViewController) -> OverlayTransitioningDelegate?
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction?
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didDragOverlay overlayViewController: UIViewController,
                                        toHeight height: CGFloat)
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        willEndReachingNotchAt index: Int,
                                        transitionCoordinator: OverlayContainerTransitionCoordinator)
}
