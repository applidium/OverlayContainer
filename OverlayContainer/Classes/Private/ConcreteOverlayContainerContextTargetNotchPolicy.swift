//
//  ConcreteOverlayContainerContextTargetNotchPolicy.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import Foundation

struct ConcreteOverlayContainerContextTargetNotchPolicy: OverlayContainerContextTargetNotchPolicy {
    let overlayViewController: UIViewController
    let overlayTranslationHeight: CGFloat
    let velocity: CGPoint
    let notchHeightByIndex: [Int: CGFloat]

    var notchIndexes: Range<Int> {
        return 0..<notchHeightByIndex.count
    }

    func height(forNotchAt index: Int) -> CGFloat {
        return notchHeightByIndex[index] ?? 0
    }
}
