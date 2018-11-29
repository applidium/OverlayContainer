//
//  UIViewController+Children.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 19/11/2018.
//

import UIKit

public extension UIViewController {
    public func addChild(_ child: UIViewController, in containerView: UIView) {
        guard containerView.isDescendant(of: view) else { return }
        addChild(child)
        containerView.addSubview(child.view)
        child.view.pinToSuperview()
        child.didMove(toParent: self)
    }

    public func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
