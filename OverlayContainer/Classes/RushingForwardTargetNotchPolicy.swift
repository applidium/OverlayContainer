//
//  RushingForwardTargetNotchPolicy.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 27/11/2018.
//

import Foundation

private struct Constant {
    static let durationConsiduration: CGFloat = 0.1
    static let minimumVelocityConsideration: CGFloat = 400
}

public class RushingForwardTargetNotchPolicy: OverlayAnimatedTransioningTargetNotchPolicy {

    public var minimumVelocityConsideration: CGFloat = Constant.minimumVelocityConsideration

    public func targetNotchIndex(using context: OverlayContainerContextTargetNotchPolicy) -> Int {
        guard !context.notchIndexes.isEmpty else { return 0 }
        let height = Constant.durationConsiduration * -context.velocity.y + context.overlayTranslationHeight
        let closestNotches = context.notchIndexes.sorted {
            let lhsHeight = context.heightForNotch(at: $0)
            let rhsHeight = context.heightForNotch(at: $1)
            let lhsDistance = abs(height - lhsHeight)
            let rhsDistance = abs(height - rhsHeight)
            return (lhsDistance, lhsHeight) < (rhsDistance, rhsHeight)
        }
        if context.notchIndexes.count > 1 && abs(context.velocity.y) > Constant.minimumVelocityConsideration {
            let lhs = closestNotches[0]
            let rhs = closestNotches[1]
            if context.velocity.y < 0 {
                return max(lhs, rhs)
            } else {
                return min(lhs, rhs)
            }
        } else {
            return closestNotches[0]
        }
    }
}
