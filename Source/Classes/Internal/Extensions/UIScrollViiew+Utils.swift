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

    var scrollsDown: Bool {
        return panGestureRecognizer.yDirection == .down
    }

    var isContentOriginInBounds: Bool {
        topOffsetInContent <= 0.0
    }

    var isContentReachedBottom: Bool {
        let distanceFromBottom = contentSize.height - topOffsetInContent
//        print("distance \(distanceFromBottom) content \(contentSize.height) height \(frame.height)")
        return distanceFromBottom < frame.height
    }

    var topOffsetInContent: CGFloat {
        contentOffset.y + oc_adjustedContentInset.top
    }

    func scrollToTop() {
        contentOffset.y = -oc_adjustedContentInset.top
    }
}


extension UIScrollView {
    
    var oc_adjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.adjustedContentInset
        } else {
            // Fallback on earlier versions
            return self.contentInset
        }
    }
}
