//
//  ActionViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 11/04/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import UIKit

protocol ActionViewControllerDelegate: AnyObject {
    func actionViewControllerDidSelectionAction()
}

class ActionViewController: UIViewController {

    weak var delegate: ActionViewControllerDelegate?

    private lazy var button = UIButton()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .red
        view.addSubview(button)
        button.pinToSuperview(with: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0), edges: .top)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.setTitle("Show/Hide Overlay", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    @objc private func buttonAction(_ sender: UIButton) {
        delegate?.actionViewControllerDidSelectionAction()
    }
}
