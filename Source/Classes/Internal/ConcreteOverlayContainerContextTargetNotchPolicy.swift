//
//  ConcreteOverlayContainerContextTargetNotchPolicy.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import UIKit

struct ConcreteOverlayContainerContextTargetNotchPolicy: OverlayContainerContextTargetNotchPolicy {
    let overlayViewController: UIViewController
    let overlayTranslationHeight: CGFloat
    let velocity: CGPoint
    let notchHeightByIndex: [Int: CGFloat]
    let reachableIndexes: [Int]

    func height(forNotchAt index: Int) -> CGFloat {
        return notchHeightByIndex[index] ?? 0
    }
}
