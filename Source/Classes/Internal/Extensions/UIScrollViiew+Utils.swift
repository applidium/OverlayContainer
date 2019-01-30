//
//  UIScrollViiew+Utils.swift
//  Pods
//
//  Created by Gaétan Zanella on 28/11/2018.
//

import UIKit

extension UIScrollView {

    var scrollsUp: Bool {
        return panGestureRecognizer.yDirection == .up
    }

    var isContentOriginInBounds: Bool {
        return contentOffset.y <= -contentInset.top
    }

    func scrollToTop() {
        contentOffset.y = -contentInset.top
    }
}
