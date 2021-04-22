//
//  HeightConstraintOverlayTranslationControllerTests.swift
//  OverlayContainer_Tests
//
//  Created by Gaétan Zanella on 21/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Quick
import Nimble
@testable import OverlayContainer

class HeightConstraintOverlayTranslationControllerTests: QuickSpec {

    // MARK: - QuickSpec

    override func spec() {

        var constraint: NSLayoutConstraint!
        var translationController: HeightConstraintOverlayTranslationController!
        var configuration: FakeConfiguration!
        var delegate: FakeDelegate!

        beforeEach {
            configuration = FakeConfiguration()
            constraint = NSLayoutConstraint()
            translationController = HeightConstraintOverlayTranslationController(
                translationHeightConstraint: constraint,
                configuration: configuration
            )
            delegate = FakeDelegate()
            translationController.delegate = delegate
        }

        describe("Dragging") {
            it("should update dragging state") {
                XCTAssertFalse(delegate.willStartDragging)
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: -1.0, usesFunction: false)
                XCTAssertTrue(delegate.willStartDragging)
                translationController.endOverlayTranslation(withVelocity: .zero)
                XCTAssertTrue(delegate.willEndDragging)
                delegate.willStartDragging = false
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: -1.0, usesFunction: false)
                XCTAssertTrue(delegate.willStartDragging)
            }

            it("should update constraint") {
                constraint.constant = 100
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: -1.0, usesFunction: false)
                XCTAssertEqual(constraint.constant, 101.0)
                constraint.constant = 300
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: 1.0, usesFunction: false)
                XCTAssertEqual(constraint.constant, 299.0)
            }

            it("should not update constraint if maximum is reached") {
                constraint.constant = 300
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: -1.0, usesFunction: false)
                XCTAssertEqual(constraint.constant, 300)
            }

            it("should not update constraint if minimum is reached") {
                constraint.constant = 100
                translationController.startOverlayTranslation()
                translationController.dragOverlay(withOffset: 1.0, usesFunction: false)
                XCTAssertEqual(constraint.constant, 100)
            }
        }

        describe("transition coordinators") {

            it("should target correct index") {
                let animated = [true, false]
                animated.forEach { isAnimated in
                    (configuration.minimumNotchIndex...configuration.maximumNotchIndex).forEach { index in
                        delegate.willMoveIndex = nil
                        delegate.didMoveIndex = nil
                        delegate?.transitionCoordinator = nil
                        let expectation = XCTestExpectation()
                        let velocity = CGPoint(x: 0, y: 10 * index)
                        let previousHeight = constraint.constant
                        translationController.scheduleOverlayTranslation(.toIndex(index), velocity: velocity, animated: isAnimated) {
                            expectation.fulfill()
                        }
                        XCTAssertNil(delegate.transitionCoordinator)
                        translationController.performDeferredTranslations()
                        let result: FakeTransitionCoordinator = .indexTransition(
                            index,
                            isAnimated: isAnimated,
                            notches: configuration.notches,
                            velocity: velocity,
                            currentHeight: isAnimated ? previousHeight : constraint.constant
                        )
                        self.expect(delegate.transitionCoordinator, toEqual: result)
                        XCTAssertEqual(delegate.willMoveIndex, index)
                        if isAnimated {
                            XCTAssertNil(delegate.didMoveIndex)
                            configuration.controller.completion?(.end)
                        }
                        XCTAssertEqual(delegate.didMoveIndex, index)
                        self.wait(for: [expectation], timeout: 0.1)
                    }
                }
            }

            it("should target index based on target policy") {
                [0, 1, 2].forEach { index in
                    delegate.willMoveIndex = nil
                    delegate.didMoveIndex = nil
                    configuration.notchPolicy.index = index
                    translationController.scheduleOverlayTranslation(.basedOnTargetPolicy, velocity: .zero, animated: false)
                    XCTAssertNil(delegate.willMoveIndex)
                    XCTAssertNil(delegate.didMoveIndex)
                    translationController.performDeferredTranslations()
                    XCTAssertEqual(delegate.willMoveIndex, index)
                    XCTAssertEqual(delegate.didMoveIndex, index)
                    XCTAssertEqual(
                        constraint.constant,
                        configuration.heightForNotch(at: configuration.notchPolicy.index)
                    )
                }
            }

            it("should target last reached index") {
                translationController.scheduleOverlayTranslation(.toLastReachedNotchIndex, velocity: .zero, animated: false)
                translationController.performDeferredTranslations()
                XCTAssertEqual(
                    constraint.constant,
                    configuration.heightForNotch(at: 0)
                )
                translationController.scheduleOverlayTranslation(.toIndex(1), velocity: .zero, animated: false)
                translationController.performDeferredTranslations()
                translationController.scheduleOverlayTranslation(.toLastReachedNotchIndex, velocity: .zero, animated: false)
                translationController.performDeferredTranslations()
                XCTAssertEqual(
                    constraint.constant,
                    configuration.heightForNotch(at: 1)
                )
            }
        }
    }

    private func expect(_ lhs: OverlayContainerTransitionCoordinator?, toEqual rhs: OverlayContainerTransitionCoordinator) {
        XCTAssertEqual(lhs?.isAnimated, rhs.isAnimated)
        XCTAssertEqual(lhs?.isDragging, rhs.isDragging)
        XCTAssertEqual(lhs?.isCancelled, rhs.isCancelled)
        XCTAssertEqual(lhs?.notchIndexes, rhs.notchIndexes)
        XCTAssertEqual(lhs?.reachableIndexes, rhs.reachableIndexes)
        XCTAssertEqual(lhs?.velocity, rhs.velocity)
        XCTAssertEqual(lhs?.overlayTranslationHeight, rhs.overlayTranslationHeight)
        XCTAssertEqual(lhs?.targetTranslationHeight, rhs.targetTranslationHeight)
        XCTAssertEqual(lhs?.translationProgress(), rhs.translationProgress())
        XCTAssertEqual(lhs?.overallTranslationProgress(), rhs.overallTranslationProgress())
    }
}

private extension FakeTransitionCoordinator {

    static func indexTransition(_ index: Int,
                                isAnimated: Bool,
                                notches: [Int: CGFloat],
                                velocity: CGPoint,
                                currentHeight: CGFloat) -> Self {
        FakeTransitionCoordinator(
            notches: notches,
            isAnimated: isAnimated,
            isCancelled: false,
            targetTranslationHeight: notches[index]!,
            isDragging: false,
            velocity: isAnimated ? velocity : .zero,
            overlayTranslationHeight: currentHeight,
            reachableIndexes: Array(0..<notches.count)
        )
    }
}

private struct FakeTransitionCoordinator: OverlayContainerTransitionCoordinator {

    var notches: [Int: CGFloat] = [:]

    var isAnimated: Bool = false

    var isCancelled: Bool = false

    var targetTranslationHeight: CGFloat = 0.0

    var isDragging: Bool = false

    var velocity: CGPoint = .zero

    var overlayTranslationHeight: CGFloat = 0.0

    var notchIndexes: Range<Int> {
        0..<notches.count
    }

    var reachableIndexes: [Int] = []

    func height(forNotchAt index: Int) -> CGFloat {
        notches[index] ?? 0.0
    }

    func animate(alongsideTransition animation: ((OverlayContainerTransitionCoordinatorContext) -> Void)?,
                 completion: ((OverlayContainerTransitionCoordinatorContext) -> Void)?) {}
}

private class FakeDelegate: HeightConstraintOverlayTranslationControllerDelegate {

    var willMoveIndex: Int?
    var didMoveIndex: Int?
    var willStartDragging = false
    var willTranslate = false
    var willEndDragging = false
    var didScheduleTranslations = false
    var transitionCoordinator: OverlayContainerTransitionCoordinator?

    func overlayViewController(for translationController: OverlayTranslationController) -> UIViewController? {
        UIViewController()
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willMoveOverlayToNotchAt index: Int) {
        willMoveIndex = index
    }

    func translationController(_ translationController: OverlayTranslationController,
                               didMoveOverlayToNotchAt index: Int) {
        didMoveIndex = index
    }

    func translationControllerWillStartDraggingOverlay(_ translationController: OverlayTranslationController) {
        willStartDragging = true
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willEndDraggingAtVelocity velocity: CGPoint) {
        willEndDragging = true
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willTranslateOverlayWith transitionCoordinator: OverlayContainerTransitionCoordinator) {
        self.transitionCoordinator = transitionCoordinator
    }

    func translationControllerDidScheduleTranslations(_ translationController: OverlayTranslationController) {
        didScheduleTranslations = true
    }
}

private struct FakeTranslationFunction: OverlayTranslationFunction {

    var height: CGFloat = 0.0

    func overlayTranslationHeight(using parameters: OverlayTranslationParameters) -> CGFloat {
        height
    }
}

private struct FakeTargetNotchPolicy: OverlayTranslationTargetNotchPolicy {

    var index = 0

    func targetNotchIndex(using context: OverlayContainerContextTargetNotchPolicy) -> Int {
        index
    }
}

private class FakeOverlayAnimatedTransitioning: NSObject, OverlayAnimatedTransitioning, UIViewImplicitlyAnimating {

    var context: OverlayContainerContextTransitioning?
    var completion: ((UIViewAnimatingPosition) -> Void)?

    func interruptibleAnimator(using context: OverlayContainerContextTransitioning) -> UIViewImplicitlyAnimating {
        self.context = context
        return self
    }

    var state: UIViewAnimatingState = .stopped

    var isRunning: Bool = false

    var isReversed: Bool = false

    var fractionComplete: CGFloat = 0.0

    func startAnimation() {}

    func startAnimation(afterDelay delay: TimeInterval) {}

    func pauseAnimation() {}

    func stopAnimation(_ withoutFinishing: Bool) {}

    func finishAnimation(at finalPosition: UIViewAnimatingPosition) {}

    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        self.completion = completion
    }
}

private class FakeConfiguration: OverlayContainerConfiguration {

    var function = FakeTranslationFunction()
    var controller = FakeOverlayAnimatedTransitioning()
    var notchPolicy = FakeTargetNotchPolicy()
    var notches: [Int: CGFloat] = [
        0: 100.0,
        1: 200.0,
        2: 300.0,
    ]
    var shouldDrag = true
    var disabledIndexes = [Int]()

    // MARK: - OverlayContainerConfiguration

    func numberOfNotches() -> Int {
        notches.count
    }

    func heightForNotch(at index: Int) -> CGFloat {
        notches[index] ?? 0.0
    }

    func canReachNotch(at index: Int,
                       for overlayViewController: UIViewController) -> Bool {
        !disabledIndexes.contains(index)
    }

    func animationController(forOverlay overlay: UIViewController) -> OverlayAnimatedTransitioning {
        controller
    }

    func overlayTargetNotchPolicy(forOverlay overlay: UIViewController) -> OverlayTranslationTargetNotchPolicy {
        notchPolicy
    }

    func scrollView(drivingOverlay controller: UIViewController) -> UIScrollView? {
        nil
    }

    func shouldStartDraggingOverlay(_ viewController: UIViewController,
                                    at point: CGPoint,
                                    in coordinateSpace: UICoordinateSpace) -> Bool {
        shouldDrag
    }

    func overlayTranslationFunction(using context: OverlayTranslationParameters,
                                    for overlayViewController: UIViewController) -> OverlayTranslationFunction {
        function
    }
}
