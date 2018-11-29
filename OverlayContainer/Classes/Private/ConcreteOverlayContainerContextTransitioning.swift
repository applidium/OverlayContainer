//
//  ConcreteOverlayContainerContextTransitioning.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import Foundation

struct ConcreteOverlayContainerContextTransitioning: OverlayContainerContextTransitioning, OverlayContainerTransitionCoordinatorContext {
    let overlayViewController: UIViewController
    let overlayTranslationHeight: CGFloat
    let velocity: CGPoint
    let targetNotchIndex: Int
    let targetNotchHeight: CGFloat
}
