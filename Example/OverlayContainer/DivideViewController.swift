//
//  DivideViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 30/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class DivideViewController: UIViewController {

    var leftViewController: UIViewController? {
        didSet {
            guard isViewLoaded else { return }
            remove(oldValue)
            insert(leftViewController, in: leftContainerView)
        }
    }

    var rightViewController: UIViewController? {
        didSet {
            guard isViewLoaded else { return }
            remove(oldValue)
            insert(rightViewController, in: rightContainerView)
        }
    }

    @IBOutlet private var leftContainerView: UIView!
    @IBOutlet private var rightContainerView: UIView!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        insert(leftViewController, in: leftContainerView)
        insert(rightViewController, in: rightContainerView)
    }

    // MARK: - Private

    private func insert(_ viewController: UIViewController?, in containerView: UIView) {
        viewController.flatMap { addChild($0, in: containerView) }
    }

    private func remove(_ viewController: UIViewController?) {
        viewController.flatMap { removeChild($0) }
    }
}
