//
//  InterruptibleAnimatorOverlayContainerTransitionCoordinator.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import Foundation

class InterruptibleAnimatorOverlayContainerTransitionCoordinator: OverlayContainerTransitionCoordinator {

    private let animator: UIViewImplicitlyAnimating
    private let context: OverlayContainerTransitionCoordinatorContext

    init(animator: UIViewImplicitlyAnimating, context: OverlayContainerTransitionCoordinatorContext) {
        self.animator = animator
        self.context = context
    }

    func animate(alongsideTransition animation: @escaping (OverlayContainerTransitionCoordinatorContext) -> Void,
                 completion: @escaping (OverlayContainerTransitionCoordinatorContext) -> Void) {
        let context = self.context
        animator.addAnimations? {
            animation(context)
        }
        animator.addCompletion? { _ in
            completion(context)
        }
    }
}
