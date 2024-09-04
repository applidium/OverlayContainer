//
//  PanGestureOverlayTranslationDriver.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import UIKit

class PanGestureOverlayTranslationDriver: NSObject,
                                          OverlayTranslationDriver,
                                          UIGestureRecognizerDelegate {

    private weak var translationController: OverlayTranslationController?
    private let panGestureRecognizer: OverlayTranslationGestureRecognizer
	private var shouldBeginCondition: (() -> Bool)?
	private var shouldRecognizeSimultaneously: (() -> Bool)?

    // MARK: - Life Cycle

	init(
		translationController: OverlayTranslationController,
		panGestureRecognizer: OverlayTranslationGestureRecognizer,
		shouldBeginCondition: (() -> Bool)?,
		shouldRecognizeSimultaneously: (() -> Bool)?
	) {
        self.translationController = translationController
        self.panGestureRecognizer = panGestureRecognizer
		self.shouldBeginCondition = shouldBeginCondition
		self.shouldRecognizeSimultaneously = shouldRecognizeSimultaneously
        super.init()
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(overlayPanGestureAction(_:)))
    }

    // MARK: - OverlayTranslationDriver

    func clean() {
        // no-op
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view,
              let gesture = gestureRecognizer as? OverlayTranslationGestureRecognizer else {
            return false
        }
		let isDraggable = translationController?.isDraggable(at: gesture.startingLocation, in: view) ?? false
		
        return isDraggable && shouldBeginCondition?() == true
    }

    // MARK: - Action

    @objc private func overlayPanGestureAction(_ sender: OverlayTranslationGestureRecognizer) {
        guard let controller = translationController, let view = sender.view else { return }
        let translation = sender.translation(in: nil)
        switch sender.state {
        case .began:
            controller.startOverlayTranslation()
            if controller.isDraggable(at: sender.startingLocation, in: view) {
                controller.dragOverlay(withOffset: translation.y, usesFunction: true)
            } else {
                sender.cancel()
            }
        case .changed:
            controller.dragOverlay(withOffset: translation.y, usesFunction: true)
        case .failed, .ended, .cancelled:
            let velocity = sender.velocity(in: nil)
            controller.endOverlayTranslation(withVelocity: velocity)
        case .possible:
            break
        @unknown default:
            break
        }
    }
	
	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool {
		shouldRecognizeSimultaneously?() == true
	}
}
