//
//  HeightConstraintOverlayTranslationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import UIKit

private typealias TranslationCompletionBlock = () -> Void

private struct TranslationMetaData {
    let isAnimated: Bool
    let velocity: CGPoint
    let index: Int

    static let `default` = TranslationMetaData(isAnimated: false, velocity: .zero, index: 0)
}

class HeightConstraintOverlayTranslationController: OverlayTranslationController {

    weak var delegate: OverlayTranslationControllerDelegate?


    private var overlayViewController: UIViewController? {
        return delegate?.overlayViewController(for: self)
    }

    private var translationEndNotchIndex = 0
    private var deferredTranslation: TranslationMetaData?
    private var deferredTranslationCompletionBlocks: [TranslationCompletionBlock] = []

    private var translationEndNotchHeight: CGFloat {
        return configuration.heightForNotch(at: translationEndNotchIndex)
    }

    private let configuration: OverlayContainerConfiguration
    private let translationHeightConstraint: NSLayoutConstraint

    // MARK: - Life Cycle

    init(translationHeightConstraint: NSLayoutConstraint,
         configuration: OverlayContainerConfiguration) {
        self.translationHeightConstraint = translationHeightConstraint
        self.configuration = configuration
    }

    // MARK: - Public

    func performDeferredTranslations() {
        guard let overlay = delegate?.overlayViewController(for: self),
            let deferredTranslation = deferredTranslation else {
                return
        }
        let completions = deferredTranslationCompletionBlocks
        let index = deferredTranslation.index
        let velocity = deferredTranslation.velocity
        let isAnimated = deferredTranslation.isAnimated
        self.deferredTranslation = nil
        self.deferredTranslationCompletionBlocks = []
        translationEndNotchIndex = index
        dragOverlay(toHeight: translationEndNotchHeight)
        guard isAnimated else {
            completions.forEach { $0() }
            return
        }
        let height = translationHeight
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
            completions.forEach { $0() }
        })
        animator.startAnimation()
    }

    // MARK: - OverlayTranslationController

    var lastTranslationEndNotchIndex: Int {
        return translationEndNotchIndex
    }

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
        deferredTranslation = TranslationMetaData(isAnimated: animated, velocity: velocity, index: index)
        completion.flatMap { deferredTranslationCompletionBlocks.append($0) }
        delegate?.translationControllerDidScheduleTranslations(self)
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
