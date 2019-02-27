//
//  DetailHeaderView.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 30/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol DetailHeaderViewDelegate: AnyObject {
    func detailHeaderViewDidSelectCloseAction(_ headerView: DetailHeaderView)
}

class DetailHeaderView: UIView {

    weak var delegate: DetailHeaderViewDelegate?

    var showsCloseAction: Bool {
        set {
            button.isHidden = !newValue
        }
        get {
            return !button.isHidden
        }
    }

    @IBOutlet private var button: UIButton!

    @IBAction private func closeAction(_ sender: Any) {
        delegate?.detailHeaderViewDidSelectCloseAction(self)
    }
}
