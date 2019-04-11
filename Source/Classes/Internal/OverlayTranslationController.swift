//
//  OverlayTranslationController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import UIKit

enum OverlayTranslationPosition {
    case top, bottom, inFlight, stationary
}

protocol OverlayTranslationControllerDelegate: class {
    func translationController(_ translationController: OverlayTranslationController,
                               didDragOverlayToHeight height: CGFloat)
    func translationController(_ translationController: OverlayTranslationController,
                               willReachNotchAt index: Int,
                               transitionCoordinator: OverlayContainerTransitionCoordinator)
}

protocol OverlayTranslationController: class {
    var translationHeight: CGFloat { get }
    var translationPosition: OverlayTranslationPosition { get }

    func isDraggable(at point: CGPoint, in coordinateSpace: UICoordinateSpace) -> Bool
    func overlayHasReachedANotch() -> Bool

    func moveOverlay(toNotchAt index: Int, velocity: CGPoint, animated: Bool, completion: (() -> Void)?)

    func dragOverlay(withOffset offset: CGFloat, usesFunction: Bool)
    func endOverlayTranslation(withVelocity velocity: CGPoint)
}
