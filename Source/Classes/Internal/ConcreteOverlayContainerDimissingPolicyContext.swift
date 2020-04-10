//
//  ConcreteOverlayContainerDimissingPolicyContext.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 07/04/2020.
//  Copyright © 2020 Gaétan Zanella. All rights reserved.
//

import Foundation

struct ConcreteOverlayContainerDismissalPolicyContext: OverlayContainerSheetDismissalPolicyContext {
    var heightByNotch: [Int: CGFloat] = [:]
    var velocity: CGPoint = .zero
    var overlayTranslationHeight: CGFloat = 0.0
    var notchIndexes = 0..<1
    var reachableIndexes: [Int] = []

    func height(forNotchAt index: Int) -> CGFloat {
        return heightByNotch[index] ?? 0
    }

    mutating func complete(with context: OverlayContainerTransitionContext) {
        overlayTranslationHeight = context.overlayTranslationHeight
        notchIndexes = context.notchIndexes
        reachableIndexes = context.reachableIndexes
        heightByNotch = [:]
        notchIndexes.forEach { notch in
            heightByNotch[notch] = context.height(forNotchAt: notch)
        }
    }
}
