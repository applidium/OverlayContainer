//
//  InterruptibleAnimatorOverlayContainerTransitionCoordinator.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import UIKit

class DraggingOverlayContainerTransitionCoordinator: OverlayContainerTransitionCoordinator {

    private let context: OverlayContainerTransitionCoordinatorContext

    // MARK: - Life Cycle

    init(context: OverlayContainerTransitionCoordinatorContext) {
        self.context = context
    }

    // MARK: - OverlayContainerTransitionCoordinatorContext

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
        animation?(context)
        completion?(context)
    }
}
