//
//  PanGestureOverlayTranslationDriver.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import Foundation

class PanGestureOverlayTranslationDriver: NSObject, OverlayTranslationDriver {

    private weak var translationController: OverlayTranslationController?
    private let panGestureRecognizer: OverlayTranslationGestureRecognizer

    // MARK: - Life Cycle

    init(translationController: OverlayTranslationController,
         panGestureRecognizer: OverlayTranslationGestureRecognizer) {
        self.translationController = translationController
        self.panGestureRecognizer = panGestureRecognizer
        super.init()
        panGestureRecognizer.addTarget(self, action: #selector(overlayPanGestureAction(_:)))
    }

    // MARK: - Action

    @objc private func overlayPanGestureAction(_ sender: OverlayTranslationGestureRecognizer) {
        guard let controller = translationController, let view = sender.view else { return }
        let translation = sender.translation(in: nil)
        switch sender.state {
        case .began:
            let location = sender.location(in: view)
            let startingPoint = location.offset(by: translation.multiply(by: -1))
            if controller.isDraggable(at: startingPoint, in: view) {
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
        }
    }
}
