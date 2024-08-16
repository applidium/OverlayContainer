//
//  FakeOverlayTranslationController.swift
//  OverlayContainer_Tests
//
//  Created by Gaétan Zanella on 21/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Foundation
@testable import OverlayContainer
import UIKit

class FakeOverlayTranslationController: OverlayTranslationController {
	func endOverlayTranslation(withVelocity velocity: CGPoint, at index: Int?) {
		
	}
	
	func dragOverlay(toNotchIndex index: Int, fractionComplete percent: CGFloat) {
		
	}
	

    var lastTranslationEndNotchIndex: Int = 0

    private var initialTranslationHeight: CGFloat = 0.0
    var translationHeight: CGFloat = 0.0

    var translationPosition: OverlayTranslationPosition = .bottom

    var isDraggable = true

    private(set) var isInTranslation = false

    var hasReachedANotch = false

    func isDraggable(at point: CGPoint, in coordinateSpace: UICoordinateSpace) -> Bool {
        isDraggable
    }

    func overlayHasReachedANotch() -> Bool {
        hasReachedANotch
    }

    func startOverlayTranslation() {
        initialTranslationHeight = translationHeight
        isInTranslation = true
    }

    func dragOverlay(withOffset offset: CGFloat, usesFunction: Bool) {
        translationHeight = initialTranslationHeight - offset
    }

    func endOverlayTranslation(withVelocity velocity: CGPoint) {
        isInTranslation = false
    }
}
