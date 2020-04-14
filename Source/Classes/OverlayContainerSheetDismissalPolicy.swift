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

/// The policy used by the sheet presentation controller by default.
public struct DefaultOverlayContainerSheetDismissalPolicy: OverlayContainerSheetDismissalPolicy {

    /// `PositionThreshold` defines a position threshold from which the overlay container will be dismissed.
    public enum PositionThreshold {
        /// The policy ignores the overlay translation height
        case none
        /// If the overlay goes under the specified notch, the policy dismisses it.
        case notch(index: Int)
        /// If the overlay goes under the specified translation height, the policy dismisses it.
        case translationHeight(CGFloat)
    }

    /// `VelocityThreshold` defines a velocity threshold from which the overlay container will be dismissed.
    public enum VelocityThreshold {
        /// The policy ignores the overlay translation velocity
        case none
        /// If the overlay goes faster than the specified value, the policy dismisses the container.
        case value(CGFloat)
    }

    /// A velocity threshold that can trigger a dismissal.
    public var velocityThreshold: VelocityThreshold

    /// A position threshold that can trigger a dismissal.
    public var positionThreshold: PositionThreshold

    // MARK: - Life Cycle

    /// Creates a `DefaultOverlayContainerSheetDismissalPolicy` instance.
    ///
    /// - parameter velocityThreshold: The velocity threshold that can trigger a dismissal. The default value is `2000.0` pts/s.
    /// - parameter positionThreshold: The position threshold that can trigger a dismissal. The default value is the first container notch.
    ///
    /// - returns: The new`DefaultOverlayContainerSheetDismissalPolicy` instance.
    public init(velocityThreshold: VelocityThreshold = .value(2000.0),
                positionThreshold: PositionThreshold = .notch(index: 0)) {
        self.velocityThreshold = velocityThreshold
        self.positionThreshold = positionThreshold
    }

    // MARK: - OverlayContainerDimissingPolicy

    public func shouldDismiss(using context: OverlayContainerSheetDismissalPolicyContext) -> Bool {
        switch positionThreshold {
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
        switch velocityThreshold {
        case .none:
            return false
        case let .value(value):
            return context.velocity.y > value
        }
    }
}
