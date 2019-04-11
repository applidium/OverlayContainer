//
//  ConcreteOverlayContainerContextTransitioning.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import UIKit

struct ConcreteOverlayContainerContextTransitioning:
    OverlayContainerContextTransitioning,
    OverlayContainerTransitionCoordinatorContext {

    let overlayViewController: UIViewController
    let overlayTranslationHeight: CGFloat
    let velocity: CGPoint
    let targetNotchIndex: Int
    let targetNotchHeight: CGFloat
    let notchHeightByIndex: [Int: CGFloat]
    let reachableIndexes: [Int]

    var notchIndexes: Range<Int> {
        return 0..<notchHeightByIndex.count
    }

    func height(forNotchAt index: Int) -> CGFloat {
        return notchHeightByIndex[index] ?? 0
    }
}
