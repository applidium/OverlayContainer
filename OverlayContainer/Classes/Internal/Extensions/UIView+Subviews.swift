//
//  UIView+Subviews.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 19/11/2018.
//

import Foundation

extension UIView {
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
