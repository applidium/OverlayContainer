//
//  OverlayContainerViewControllerDelegate.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 23/11/2018.
//

import UIKit

/// The container delegate is responsible for defining the aspect and the behavior of the container.
public protocol OverlayContainerViewControllerDelegate: class {

    /// Asks the delegate for the number of notches in the container.
    /// **Required**.
    ///
    /// - parameter containerViewController: The container requesting this information.
    ///
    /// - returns: The number of notches in `containerViewController`.
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int

    /// Asks the delegate for the height of a notch in a specified location.
    /// **Required**.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter index: The index that locates the notch.
    /// - parameter availableSpace: The height of the zone defined by the overlay.
    ///
    /// - returns: A nonnegative floating-point value that specifies the height that notch should be.
    ///
    /// - attention: The notches must be ordered from the smallest one (index 0) to the highest one
    /// and must not exceed the available space.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat

    /// Asks the delegate for a scroll view driving the current top overlay view controller translation.
    ///
    /// The container view controller can coordinate the scrolling of a scroll view
    /// to the child view controllers translation. The children will be moved up & down as the user scrolls.
    /// The content offset of the scroll view will be adjusted accordingly.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    ///
    /// - returns: A scroll view to use as a translation driver.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView?

    /// Asks the delegate if the container should drag its children when the user starts a pan gesture at the specified location.
    ///
    /// The container view controller detects pan gestures on its own view.
    /// It calls this method each time a pan gesture is detected.
    /// If the gesture begins in the scroll view specified in `overlayContainerViewController(_:, scrollViewDrivingOverlay:)`,
    /// the gesture is aborted and this method is not called.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    /// - parameter point: The starting point of the gesture.
    /// - parameter coordinateSpace: The coordinate space of point.
    ///
    /// - returns: `true` if the translation should start or `false` if it should not.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool

    /// Tells the delegate when the user drags its children to the specified height.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    /// - parameter height: The height of the translation.
    /// - parameter availableSpace: The height of the zone defined by the overlay.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didDragOverlay overlayViewController: UIViewController,
                                        toHeight height: CGFloat,
                                        availableSpace: CGFloat)

    /// Tells the delegate when the user finishs dragging its children. The container is about to
    /// animate the translation end to the specified notch.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    /// - parameter transitionCoordinator: The transition coordinator object associated with the translation end.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didEndDraggingOverlay overlayViewController: UIViewController,
                                        transitionCoordinator: OverlayContainerTransitionCoordinator)

    /// Asks the delegate for a translation function when dragging the specified view controller.
    ///
    /// The function is only used for translation based on the container pan gesture recognizer.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    ///
    /// - returns: A overlay translation function.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction?

    /// Asks the delegate for a object providing the translation end animator.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter overlayViewController: The current top overlay view controller.
    ///
    /// - returns: A object implementing the `OverlayTransitioningDelegate` protocol.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        transitioningDelegateForOverlay overlayViewController: UIViewController) -> OverlayTransitioningDelegate?

    /// Asks the delegate if the container can reach the specified notch.
    ///
    /// - parameter containerViewController: The container requesting this information.
    /// - parameter index: The index locating the notch.
    /// - parameter overlayViewController: The current top overlay view controller.
    ///
    /// - returns: `true` if the overlay is allowed to reach the specified notch index or `false` if it should not.
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        canReachNotchAt index: Int,
                                        forOverlay overlayViewController: UIViewController) -> Bool
}
