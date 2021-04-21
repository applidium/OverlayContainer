//
//  ScrollViewOverlayTranslationDriverTests.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 20/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Quick
import Nimble
@testable import OverlayContainer

class ScrollViewOverlayTranslationDriverTests: QuickSpec {

    override func spec() {

        var driver: ScrollViewOverlayTranslationDriver!
        var controller: FakeOverlayTranslationController!
        var emulator: ScrollViewEmulator!

        beforeEach {
            controller = FakeOverlayTranslationController()
            let scrollView = EmulatedScrollView()
            driver = ScrollViewOverlayTranslationDriver(
                translationController: controller,
                scrollView: scrollView
            )
            emulator = ScrollViewEmulator(
                scrollView: EmulatedScrollView(),
                delegate: driver
            )
        }

        it("should not adjust content offset when at top") {
            controller.hasReachedANotch = true
            controller.translationPosition = .top
            controller.translationHeight = 100.0
            emulator.emulate(.swipeUp(10))
            XCTAssertEqual(emulator.scrollView.contentOffset.y, 10.0)
            XCTAssertEqual(controller.translationHeight, 100.0)
        }

        it("should not adjust content offset when at bottom") {
            controller.hasReachedANotch = true
            controller.translationPosition = .bottom
            controller.translationHeight = 100.0
            emulator.emulate(.swipeDown(10))
            XCTAssertEqual(emulator.scrollView.contentOffset.y, -10.0)
            XCTAssertEqual(controller.translationHeight, 100.0)
        }

        it("should adjust content offset when moving up & down") {
            controller.hasReachedANotch = false
            controller.translationPosition = .inFlight
            controller.translationHeight = 100.0
            let gesture = Gesture(
                Gesture.Path
                    .point(x: 100, y: 90.0)
                    .movingY(10)
                    .movingY(-20)
                    .movingY(20)
            )
            .onPointReached { i in
                switch i {
                case 0:
                    break
                case 1:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 0.0)
                    XCTAssertEqual(controller.translationHeight, 90)
                case 2:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 0.0)
                    XCTAssertEqual(controller.translationHeight, 110)
                case 3:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 0.0)
                    XCTAssertEqual(controller.translationHeight, 90)
                default:
                    fatalError()
                }
            }
            emulator.emulate(gesture)
        }

        it("should not adjust the content offset of a scrolled scroll view when moving down in translation") {
            controller.hasReachedANotch = false
            controller.translationPosition = .inFlight
            controller.translationHeight = 100.0
            emulator.scrollView.contentOffset.y = 100
            let gesture = Gesture(
                Gesture.Path
                    .point(x: 100, y: 90.0)
                    .movingY(10)
                    .movingY(-20)
                    .movingY(20)
                    .movingY(80)
            )
            .onPointReached { i in
                switch i {
                case 0:
                    break
                case 1:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 90)
                    XCTAssertEqual(controller.translationHeight, 100)
                case 2:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 90)
                    XCTAssertEqual(controller.translationHeight, 120)
                case 3:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 70)
                    XCTAssertEqual(controller.translationHeight, 120)
                case 4:
                    XCTAssertEqual(emulator.scrollView.contentOffset.y, 0)
                    XCTAssertEqual(controller.translationHeight, 110)
                default:
                    fatalError()
                }
            }
            emulator.emulate(gesture)
        }

        it("should adjust content offset when moving down") {
            controller.hasReachedANotch = false
            controller.translationPosition = .inFlight
            controller.translationHeight = 100.0
            // Moves down
            emulator.emulate(.swipeDown(10))
            XCTAssertEqual(emulator.scrollView.contentOffset.y, 0.0)
            XCTAssertEqual(controller.translationHeight, 90)
        }

        it("should target idle offset when scroll view released in translation") {
            controller.hasReachedANotch = false
            controller.translationPosition = .inFlight
            controller.translationHeight = 100.0
            var target = CGPoint(x: 0.0, y: 100)
            emulator.emulate(.swipeUp(10.0), targetOffset: &target)
            XCTAssertEqual(target, .zero)
        }

        it("should not adjust offset target when scroll view released at top") {
            controller.hasReachedANotch = true
            controller.translationPosition = .top
            controller.translationHeight = 100.0
            var target = CGPoint(x: 0.0, y: 100)
            emulator.emulate(.swipeUp(10.0), targetOffset: &target)
            XCTAssertEqual(target.y, 100.0)
        }

        it("should not translate or adjust offset when stationary") {
            controller.hasReachedANotch = true
            controller.translationPosition = .stationary
            controller.translationHeight = 100.0
            emulator.emulate(.swipeUp(10))
            XCTAssertEqual(emulator.scrollView.contentOffset.y, 10)
            emulator.emulate(.swipeDown(20))
            XCTAssertEqual(emulator.scrollView.contentOffset.y, -10)
        }
    }
}

