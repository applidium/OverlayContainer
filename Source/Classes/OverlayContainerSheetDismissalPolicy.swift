//
//  OverlayContainerSheetDismissalPolicy.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 07/04/2020.
//  Copyright © 2020 Gaétan Zanella. All rights reserved.
//

import UIKit

/// A protocol that provides contextual information on the drag-to-dismiss gesture state.
public protocol OverlayContainerSheetDismissalPolicyContext: OverlayContainerTransitionContext {
    /// The overlay velocity at the moment the touch was released.
    var velocity: CGPoint { get }
}

/// A protocol that defines the dismissal policy associated to an overlay container sheet controller.
public protocol OverlayContainerSheetDismissalPolicy {
    /// Asks the policy if the presented view controller should be dismissed when a drag-to-dismiss gesture happens.
    ///
    /// - parameter context: The context object containing information about the current overlay container state.
    ///
    /// - returns: `true` if the presented view controller should be dismissed or `false` if it should not.
    func shouldDismiss(using context: OverlayContainerSheetDismissalPolicyContext) -> Bool
}

/// A policy that disables the drag-to-dismiss gesture.
public struct DisabledOverlayContainerSheetDismissalPolicy: OverlayContainerSheetDismissalPolicy {

    // MARK: - Life Cycle

    public init() {}

    // MARK: - OverlayContainerDismissalPolicy

    public func shouldDismiss(using context: OverlayContainerSheetDismissalPolicyContext) -> Bool {
        return false
    }
}

/// The policy used by the sheet presentation controller by default.
public struct DefaultOverlayContainerSheetDismissalPolicy: OverlayContainerSheetDismissalPolicy {

    /// `DismissingThreshold` defines a threshold from which the overlay container will be dismissed.
    public enum DismissingThreshold {
        /// The policy ignores the overlay translation height
        case none
        /// If the overlay goes under the specified notch, the policy dismisses it.
        case notch(index: Int)
        /// If the overlay goes under the specified translation height, the policy dismisses it.
        case translationHeight(CGFloat)
    }

    /// A boolean indicating whether the policy should ignore the current velocity of the drag gesture.
    public var ignoresTranslationVelocity: Bool
    /// The velocity that could trigger a dismissal.
    public var triggeringVelocity: CGFloat
    /// The threshold that could trigger a dismissal.
    public var threshold: DismissingThreshold

    // MARK: - Life Cycle

    /// Creates a `DefaultOverlayContainerSheetDismissalPolicy` instance.
    ///
    /// - parameter ignoresTranslationVelocity: A boolean indicating whether the policy should ignore the current velocity of the drag gesture. The default value is `false`.
    /// - parameter triggeringVelocity:  The velocity that could trigger a dismissal in pts/s. The default value is `2000.0` pts/s.
    /// - parameter threshold: The threshold that could trigger a dismissal. The default value is the first container notch.
    ///
    /// - returns: The new`DefaultOverlayContainerSheetDismissalPolicy` instance.
    public init(ignoresTranslationVelocity: Bool = false,
                triggeringVelocity: CGFloat = 2000.0,
                threshold: DismissingThreshold = .notch(index: 0)) {
        self.ignoresTranslationVelocity = ignoresTranslationVelocity
        self.triggeringVelocity = triggeringVelocity
        self.threshold = threshold
    }

    // MARK: - OverlayContainerDimissingPolicy

    public func shouldDismiss(using context: OverlayContainerSheetDismissalPolicyContext) -> Bool {
        switch threshold {
        case .none:
            break
        case let .notch(index):
            if context.overlayTranslationHeight < context.height(forNotchAt: index) {
                return true
            }
        case let .translationHeight(height):
            if context.overlayTranslationHeight < height {
                return true
            }
        }
        return context.velocity.y > triggeringVelocity && !ignoresTranslationVelocity
    }
}
