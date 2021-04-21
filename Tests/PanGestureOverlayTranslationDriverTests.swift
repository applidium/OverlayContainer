//
//  PanGestureOverlayTranslationDriverTests.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 21/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Quick
import Nimble
@testable import OverlayContainer

class FakeOverlayTranslationGestureRecognizer: OverlayTranslationGestureRecognizer {

    var isCancelled = false

    var mutableView: UIView?

    var translation: CGPoint = .zero

    override var view: UIView? {
        mutableView
    }

    override func translation(in view: UIView?) -> CGPoint {
        translation
    }

    func changeState(_ state: State) {
        self.state = state
        (target as! NSObject).perform(action, with: self)
    }

    private var target: Any!
    private var action: Selector!

    override func addTarget(_ target: Any, action: Selector) {
        self.target = target
        self.action = action
    }

    override func cancel() {
        isCancelled = true
    }
}

class PanGestureOverlayTranslationDriverTests: QuickSpec {

    override func spec() {

        var controller: FakeOverlayTranslationController!
        var gesture: FakeOverlayTranslationGestureRecognizer!
        var driver: PanGestureOverlayTranslationDriver!

        beforeEach {
            controller = FakeOverlayTranslationController()
            gesture = FakeOverlayTranslationGestureRecognizer()
            driver = PanGestureOverlayTranslationDriver(
                translationController: controller,
                panGestureRecognizer: gesture
            )
            let view = UIView()
            gesture.mutableView = view
        }

        it("should not drag not draggable content") {
            controller.isDraggable = false
            XCTAssertFalse(driver.gestureRecognizerShouldBegin(gesture))
        }

        it("should drag draggable content") {
            controller.isDraggable = true
            XCTAssertTrue(driver.gestureRecognizerShouldBegin(gesture))
        }

        it("should drag overlay according to the translation") {
            XCTAssertFalse(controller.isInTranslation)
            gesture.changeState(.began)
            XCTAssertTrue(controller.isInTranslation)
            gesture.translation.y = -100
            gesture.changeState(.changed)
            XCTAssertEqual(controller.translationHeight, 100)
            gesture.translation.y = -90
            gesture.changeState(.changed)
            XCTAssertEqual(controller.translationHeight, 90)
            gesture.changeState(.ended)
            XCTAssertFalse(controller.isInTranslation)
        }
    }
}
