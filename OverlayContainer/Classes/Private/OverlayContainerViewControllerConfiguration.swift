//
//  OverlayContainerViewControllerDelegateWrapper.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 20/11/2018.
//

import Foundation

class OverlayContainerViewControllerConfiguration {

    private weak var overlayContainerViewController: OverlayContainerViewController?

    weak var delegate: OverlayContainerViewControllerDelegate?

    var lastNotchIndex: Int {
        return  max(numberOfNotches() - 1, 0)
    }

    var firstNotchIndex: Int {
        return 0
    }

    var lastNotchHeight: CGFloat {
        return heightForNotch(at: lastNotchIndex)
    }

    var firstNotchHeight: CGFloat {
        return heightForNotch(at: firstNotchIndex)
    }

    // MARK: - Life Cycle

    init(overlayContainerViewController: OverlayContainerViewController) {
        self.overlayContainerViewController = overlayContainerViewController
    }

    // MARK: - Public

    func numberOfNotches() -> Int {
        guard let controller = overlayContainerViewController else { return 0 }
        return delegate?.numberOfNotches(in: controller) ?? 0
    }

    func heightForNotch(at index: Int) -> CGFloat {
        guard let controller = overlayContainerViewController else { return 0 }
        return delegate?.overlayContainerViewController(
            controller,
            heightForNotchAt: index,
            availableSpace: overlayContainerViewController?.view.frame.height ?? 0
        ) ?? 0
    }

    func heights() -> [CGFloat] {
        return (0..<numberOfNotches()).map { heightForNotch(at: $0) }
    }

    func animationController(forOverlay overlay: UIViewController) -> OverlayAnimatedTransitioning {
        guard let controller = overlayContainerViewController else {
            return SpringOverlayTranslationAnimationController()
        }
        let transitioningDelegate = delegate?.overlayContainerViewController(
            controller,
            transitionningDelegateForOverlay: overlay
        )
        return transitioningDelegate?.animationController(for: overlay) ?? SpringOverlayTranslationAnimationController()
    }

    func overlayTargetNotchPolicy(forOverlay overlay: UIViewController) -> OverlayAnimatedTransioningTargetNotchPolicy {
        guard let controller = overlayContainerViewController else {
            return RushingForwardTargetNotchPolicy()
        }
        let transitioningDelegate = delegate?.overlayContainerViewController(
            controller,
            transitionningDelegateForOverlay: overlay
        )
        return transitioningDelegate?.overlayTargetNotchPolicy(for: overlay) ?? RushingForwardTargetNotchPolicy()
    }

    func scrollView(drivingOverlay controller: UIViewController) -> UIScrollView? {
        guard let containerController = overlayContainerViewController else { return nil }
        return delegate?.overlayContainerViewController(containerController, scrollViewDrivingOverlay: controller)
    }

    func shouldStartDraggingOverlay(_ viewController: UIViewController,
                                       at point: CGPoint,
                                       in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let containerController = overlayContainerViewController else { return false }
        return delegate?.overlayContainerViewController(
            containerController,
            shouldStartDraggingOverlay: viewController,
            at: point,
            in: coordinateSpace
        ) ?? true
    }

    func overlayTranslationFunction(using context: OverlayTranslationParameters,
                                    for overlayViewController: UIViewController) -> OverlayTranslationFunction {
        guard let containerController = overlayContainerViewController else {
            return RubberBandOverlayTranslationFunction()
        }
        return delegate?.overlayContainerViewController(
            containerController,
            overlayTranslationFunctionForOverlay: overlayViewController
        ) ?? RubberBandOverlayTranslationFunction()
    }
}
