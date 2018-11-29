//
//  OverlayTransitioningDelegate.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 14/11/2018.
//

import Foundation


public protocol OverlayContainerContextTargetNotchPolicy {
    var overlayViewController: UIViewController { get }
    var overlayTranslationHeight: CGFloat { get }
    var velocity: CGPoint { get }
    var notchIndexes: Range<Int> { get }
    func heightForNotch(at index: Int) -> CGFloat
}

public protocol OverlayContainerContextTransitioning {
    var overlayViewController: UIViewController { get }
    var overlayTranslationHeight: CGFloat { get }
    var velocity: CGPoint { get }
    var targetNotchIndex: Int { get }
    var targetNotchHeight: CGFloat { get }
}

public protocol OverlayAnimatedTransioningTargetNotchPolicy {
    func targetNotchIndex(using context: OverlayContainerContextTargetNotchPolicy) -> Int
}

public protocol OverlayAnimatedTransitioning {
    func interruptibleAnimator(using context: OverlayContainerContextTransitioning) -> UIViewImplicitlyAnimating
}

public protocol OverlayTransitioningDelegate: class {
    func overlayTargetNotchPolicy(for overlayViewController: UIViewController) -> OverlayAnimatedTransioningTargetNotchPolicy?
    func animationController(for overlayViewController: UIViewController) -> OverlayAnimatedTransitioning?
}
