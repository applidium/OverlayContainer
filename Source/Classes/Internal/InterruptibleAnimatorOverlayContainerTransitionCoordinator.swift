//
//  InterruptibleAnimatorOverlayContainerTransitionCoordinator.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import UIKit

class InterruptibleAnimatorOverlayContainerTransitionCoordinator: OverlayContainerTransitionCoordinator {

    private let animator: UIViewImplicitlyAnimating
    private let context: OverlayContainerTransitionCoordinatorContext

    // MARK: - Life Cycle

    init(animator: UIViewImplicitlyAnimating, context: OverlayContainerTransitionCoordinatorContext) {
        self.animator = animator
        self.context = context
    }

    // MARK: - OverlayContainerTransitionCoordinatorContext

    var isAnimated: Bool {
        return context.isAnimated
    }

    var targetTranslationHeight: CGFloat {
        return context.targetTranslationHeight
    }

    var overlayTranslationHeight: CGFloat {
        return context.overlayTranslationHeight
    }

    var notchIndexes: Range<Int> {
        return context.notchIndexes
    }

    var reachableIndexes: [Int] {
        return context.reachableIndexes
    }

    func height(forNotchAt index: Int) -> CGFloat {
        return context.height(forNotchAt: index)
    }

    // MARK: - OverlayContainerTransitionCoordinator

    func animate(alongsideTransition animation: ((OverlayContainerTransitionCoordinatorContext) -> Void)?,
                 completion: ((OverlayContainerTransitionCoordinatorContext) -> Void)?) {
        let context = self.context
        animator.addAnimations? {
            animation?(context)
        }
        animator.addCompletion? { _ in
            completion?(context)
        }
    }
}
