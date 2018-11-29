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

    var maximumNotchIndex: Int {
        return  max(numberOfNotches() - 1, 0)
    }

    var minimumNotchIndex: Int {
        return 0
    }

    var maximumNotchHeight: CGFloat {
        return heightForNotch(at: maximumNotchIndex)
    }

    var minimumNotchHeight: CGFloat {
        return heightForNotch(at: minimumNotchIndex)
    }

    private(set) var notchHeightByIndex: [Int: CGFloat] = [:]

    // MARK: - Life Cycle

    init(overlayContainerViewController: OverlayContainerViewController) {
        self.overlayContainerViewController = overlayContainerViewController
    }

    // MARK: - Public

    func reloadNotchHeights() {
        let numberOfNotches = requestNumberOfNotches()
        let heights = (0..<numberOfNotches).map { requestHeightForNotch(at: $0) }
        assert(heights.sorted() == heights, "The notches should be sorted by height. The notch at the first index must be the smaller one.")
        let values = heights.enumerated().map { ($0, $1) }
        notchHeightByIndex = Dictionary(uniqueKeysWithValues: values)
    }

    func numberOfNotches() -> Int {
        return notchHeightByIndex.count
    }

    func heightForNotch(at index: Int) -> CGFloat {
        return notchHeightByIndex[index] ?? 0
    }

    func sortedHeights() -> [CGFloat] {
        return Array(notchHeightByIndex.values.sorted())
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

    // MARK: - Private

    private func requestHeightForNotch(at index: Int) -> CGFloat {
        guard let controller = overlayContainerViewController else { return 0 }
        return delegate?.overlayContainerViewController(
            controller,
            heightForNotchAt: index,
            availableSpace: overlayContainerViewController?.view.frame.height ?? 0
        ) ?? 0
    }

    private func requestNumberOfNotches() -> Int {
        guard let controller = overlayContainerViewController else { return 0 }
        return delegate?.numberOfNotches(in: controller) ?? 0
    }
}
