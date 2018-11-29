//
//  OverlayScrollViewTranslationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 20/11/2018.
//

import UIKit

class OverlayTranslationGestureRecognizer: UIPanGestureRecognizer {
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}
