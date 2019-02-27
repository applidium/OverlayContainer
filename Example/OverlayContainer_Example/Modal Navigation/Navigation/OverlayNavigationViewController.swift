//
//  OverlayNavigationViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 26/02/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import UIKit

protocol OverlayNavigationViewControllerDelegate: AnyObject {
    func overlayNavigationViewController(_ navigationController: OverlayNavigationViewController,
                                         didShow viewController: UIViewController,
                                         animated: Bool)
}

class OverlayNavigationViewController: UIViewController {

    weak var delegate: OverlayNavigationViewControllerDelegate?

    private let underlyingNavigationController = UINavigationController()

    var topViewController: UIViewController? {
        return underlyingNavigationController.topViewController
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }

    // MARK: - Public

    func push(_ viewController: UIViewController, animated: Bool) {
        underlyingNavigationController.pushViewController(viewController, animated: animated)
    }

    func popViewController(animated: Bool) {
        underlyingNavigationController.popViewController(animated: animated)
    }

    func popToRootViewController(animated: Bool) {
        underlyingNavigationController.popToRootViewController(animated: animated)
    }

    // MARK: - Private

    private func setUpViewController() {
        underlyingNavigationController.delegate = self
        addChild(underlyingNavigationController, in: view)
        underlyingNavigationController.setNavigationBarHidden(true, animated: true)
    }
}

extension OverlayNavigationViewController: UINavigationControllerDelegate {

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayNavigationAnimationController(operation: operation)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        delegate?.overlayNavigationViewController(
            self,
            didShow: viewController,
            animated: animated
        )
    }
}
