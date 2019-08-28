//
//  OverlayNavigationAnimationContrller.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 26/02/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import UIKit

class OverlayNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let operation: UINavigationController.Operation

    private let duration: TimeInterval = 0.3

    // MARK: - Life Cycle

    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animatedViewController: UIViewController
        let options: UIView.AnimationOptions
        let initialFrame: CGRect
        let finalFrame: CGRect
        let toViewController = transitionContext.viewController(forKey: .to)!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        switch operation {
        case .none:
            transitionContext.completeTransition(false)
            return
        case .pop:
            options = .curveEaseIn
            animatedViewController = fromViewController
            transitionContext.containerView.addSubview(toViewController.view)
            transitionContext.containerView.addSubview(fromViewController.view)
            initialFrame = transitionContext.initialFrame(for: fromViewController)
            finalFrame = CGRect(
                x: initialFrame.origin.x,
                y: initialFrame.height,
                width: initialFrame.width,
                height: initialFrame.height
            )
        case .push:
            options = .curveEaseOut
            animatedViewController = toViewController
            transitionContext.containerView.addSubview(fromViewController.view)
            transitionContext.containerView.addSubview(toViewController.view)
            finalFrame = transitionContext.finalFrame(for: toViewController)
            initialFrame = CGRect(
                x: finalFrame.origin.x,
                y: finalFrame.height,
                width: finalFrame.width,
                height: finalFrame.height
            )
        @unknown default:
            return
        }
        animatedViewController.view.frame = initialFrame
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                animatedViewController.view.frame = finalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
