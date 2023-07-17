//
//  OverlayTranslationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import UIKit

public enum OverlayTranslationPosition {
    case top, bottom, inFlight, stationary
}

public protocol OverlayTranslationController: AnyObject {
    var lastTranslationEndNotchIndex: Int { get }
    var translationHeight: CGFloat { get }
    var translationPosition: OverlayTranslationPosition { get }

    func isDraggable(at point: CGPoint, in coordinateSpace: UICoordinateSpace) -> Bool

    func overlayHasReachedANotch() -> Bool

    func startOverlayTranslation()
    func dragOverlay(withOffset offset: CGFloat, usesFunction: Bool)
	func dragOverlay(toNotchIndex index: Int, fractionComplete percent: CGFloat)
    func endOverlayTranslation(withVelocity velocity: CGPoint, at index: Int?)
}

public extension OverlayTranslationController {
	func endOverlayTranslation(withVelocity velocity: CGPoint) {
		endOverlayTranslation(withVelocity: velocity, at: nil)
	}
}
