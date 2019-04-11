//
//  HeightConstraintOverlayTranslationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import UIKit

class HeightConstraintOverlayTranslationController: OverlayTranslationController {

    weak var delegate: OverlayTranslationControllerDelegate?

    var translationHeight: CGFloat {
        return translationHeightConstraint.constant
    }

    var translationPosition: OverlayTranslationPosition {
        let isAtTop = translationHeight == maximumReachableNotchHeight()
        let isAtBottom = translationHeight == minimumReachableNotchHeight()
        if isAtTop && isAtBottom {
            return .stationary
        }
        if isAtTop {
            return .top
        } else if isAtBottom {
            return .bottom
        } else {
            return .inFlight
        }
    }

    private let translationHeightConstraint: NSLayoutConstraint
    private weak var overlayViewController: UIViewController?

    private(set) var translationEndNotchIndex = 0

    private var translationEndNotchHeight: CGFloat {
        return configuration.heightForNotch(at: translationEndNotchIndex)
    }

    private let configuration: OverlayContainerViewControllerConfiguration

    // MARK: - Life Cycle

    init(translationHeightConstraint: NSLayoutConstraint,
         overlayViewController: UIViewController,
         configuration: OverlayContainerViewControllerConfiguration) {
        self.translationHeightConstraint = translationHeightConstraint
        self.overlayViewController = overlayViewController
        self.configuration = configuration
    }

    // MARK: - Public

    func isDraggable(at point: CGPoint, in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let overlay = overlayViewController else { return false }
        return configuration.shouldStartDraggingOverlay(
            overlay,
            at: point,
            in: coordinateSpace
        )
    }

    func overlayHasReachedANotch() -> Bool {
        return enabledNotchIndexes().contains {
            configuration.heightForNotch(at: $0) == translationHeight
        }
    }

    func dragOverlay(withOffset offset: CGFloat, usesFunction: Bool) {
        guard let viewController = overlayViewController else { return }
        let maximumHeight = maximumReachableNotchHeight()
        let minimumHeight = minimumReachableNotchHeight()
        let translation = translationEndNotchHeight - offset
        let height: CGFloat
        if usesFunction {
            let parameters = ConcreteOverlayTranslationParameters(
                minimumHeight: minimumHeight,
                maximumHeight: maximumHeight,
                translation: translation
            )
            let function = configuration.overlayTranslationFunction(using: parameters, for: viewController)
            height = function.overlayTranslationHeight(using: parameters)
        } else {
            height = max(minimumHeight, min(maximumHeight, translation))
        }
        dragOverlay(toHeight: max(height.oc_rounded(), 0))
    }

    func endOverlayTranslation(withVelocity velocity: CGPoint) {
        guard let controller = overlayViewController, overlayHasAmibiguousTranslationHeight() else { return }
        let context = ConcreteOverlayContainerContextTargetNotchPolicy(
            overlayViewController: controller,
            overlayTranslationHeight: translationHeight,
            velocity: velocity,
            notchHeightByIndex: configuration.notchHeightByIndex,
            reachableIndexes: enabledNotchIndexes()
        )
        let policy = configuration.overlayTargetNotchPolicy(forOverlay: controller)
        let index = policy.targetNotchIndex(using: context)
        moveOverlay(toNotchAt: index, velocity: velocity, animated: true)
    }

    func moveOverlay(toNotchAt index: Int, velocity: CGPoint, animated: Bool, completion: (() -> Void)? = nil) {
        guard let overlay = overlayViewController else { return }
        assert(
            index < configuration.numberOfNotches(),
            "Invalid notch index (\(index)). The overlay can not be moved to an index greater or equal to the number of notches (\(configuration.numberOfNotches()))"
        )
        let height = translationHeight
        translationEndNotchIndex = index
        dragOverlay(toHeight: translationEndNotchHeight)
        guard animated else {
            completion?()
            return
        }
        let context = ConcreteOverlayContainerContextTransitioning(
            overlayViewController: overlay,
            overlayTranslationHeight: height,
            velocity: velocity,
            targetNotchIndex: translationEndNotchIndex,
            targetNotchHeight: translationEndNotchHeight,
            notchHeightByIndex: configuration.notchHeightByIndex,
            reachableIndexes: enabledNotchIndexes()
        )
        let animationController = configuration.animationController(forOverlay: overlay)
        let animator = animationController.interruptibleAnimator(using: context)
        let coordinator = InterruptibleAnimatorOverlayContainerTransitionCoordinator(
            animator: animator,
            context: context
        )
        delegate?.translationController(
            self,
            willReachNotchAt: translationEndNotchIndex,
            transitionCoordinator: coordinator
        )
        animator.addCompletion?({ _ in
            completion?()
        })
        animator.startAnimation()
    }

    // MARK: - Private

    private func overlayHasAmibiguousTranslationHeight() -> Bool {
        let heights = enabledNotchIndexes().map { configuration.heightForNotch(at: $0) }
        guard let index = heights.index(where: { $0 == translationHeight }) else {
            return true
        }
        return configuration.heightForNotch(at: index) != translationEndNotchHeight
    }

    private func dragOverlay(toHeight height: CGFloat) {
        guard translationHeightConstraint.constant != height else { return }
        translationHeightConstraint.constant = height
        delegate?.translationController(self, didDragOverlayToHeight: height)
    }

    private func enabledNotchIndexes() -> [Int] {
        guard let controller = overlayViewController else { return [] }
        return configuration.enabledNotchIndexes(for: controller)
    }

    private func minimumReachableNotchHeight() -> CGFloat {
        let minimum = enabledNotchIndexes().first.flatMap {
            configuration.heightForNotch(at: $0)
        } ?? configuration.maximumNotchHeight
        // (gz) 2019-04-11 If the overlay is still at a disabled notch
        return min(translationEndNotchHeight, minimum)
    }

    private func maximumReachableNotchHeight() -> CGFloat {
        let maximum = enabledNotchIndexes().last.flatMap {
            configuration.heightForNotch(at: $0)
        } ?? configuration.maximumNotchHeight
        // (gz) 2019-04-11 If the overlay is still at a disabled notch
        return max(translationEndNotchHeight, maximum)
    }
}
