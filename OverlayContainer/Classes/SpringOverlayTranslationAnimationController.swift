//
//  SpringOverlayTranslationAnimationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 21/11/2018.
//

import Foundation

private struct Constant {
    static let defaultDamping: CGFloat = 0.7
    static let defaultResponse: CGFloat = 0.3
    static let minimumVelocityConsideration: CGFloat = 500
    static let minimumTranslationDuration: TimeInterval = 0.1
    static let maximumTranslationDuration: TimeInterval = 0.5
}

/// An `OverlayAnimatedTransitioning` implementation based on `UISpringTimingParameters`.
public class SpringOverlayTranslationAnimationController: OverlayAnimatedTransitioning {

    public var damping: CGFloat = Constant.defaultDamping
    public var response: CGFloat = Constant.defaultResponse

    // MARK: - OverlayAnimatedTransitioning

    public func interruptibleAnimator(using context: OverlayContainerContextTransitioning) -> UIViewImplicitlyAnimating {
        let targetHeight = context.targetNotchHeight
        let distance = abs(targetHeight - context.overlayTranslationHeight)
        let timing = UISpringTimingParameters(
            damping: damping,
            response: response,
            initialVelocity: context.velocity
        )
        let duration = max(
            min(TimeInterval(distance / abs(context.velocity.y)), Constant.maximumTranslationDuration),
            Constant.minimumTranslationDuration
        )
        return UIViewPropertyAnimator(
            duration: duration,
            timingParameters: timing
        )
    }
}

extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGPoint = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        let vector = CGVector(dx: abs(initialVelocity.x / 1000), dy: abs(initialVelocity.y) / 1000)
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: vector)
    }
}
