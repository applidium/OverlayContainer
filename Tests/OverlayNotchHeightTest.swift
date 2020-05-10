//
//  OverlayNotchHeightTest.swift
//  OverlayContainer_Tests
//
//  Created by Gaétan Zanella on 24/12/2018.
//  Copyright © 2018 Gaétan Zanella. All rights reserved.
//

import Nimble
import Quick
import OverlayContainer

private enum Notch: Int, CaseIterable {
    case minimum, medium, maximum
}

private enum NewNotch: Int, CaseIterable {
    case minimum, medium
}

private class OverlayContainerDelegateImplementation: OverlayContainerViewControllerDelegate {

    var usesNewNotches = false

    // MARK: - Public

    func height(for notch: Notch) -> CGFloat {
        switch notch {
        case .minimum:
            return 0
        case .medium:
            return 50
        case .maximum:
            return 100
        }
    }

    func height(forNew notch: NewNotch) -> CGFloat {
        switch notch {
        case .minimum:
            return 10
        case .medium:
            return 200
        }
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        if usesNewNotches {
            return NewNotch.allCases.count
        }
        return Notch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        if usesNewNotches {
            return height(forNew: NewNotch.allCases[index])
        }
        return height(for: Notch.allCases[index])
    }
}

class OverlayNotchHeightTest: QuickSpec {

    // MARK: - QuickSpec

    override func spec() {
        var overlayContainer: OverlayContainerViewController!
        var delegate: OverlayContainerDelegateImplementation!
        var overlay: UIViewController!

        beforeEach {
            overlayContainer = OverlayContainerViewController(style: .flexibleHeight)
            delegate = OverlayContainerDelegateImplementation()
            overlay = UIViewController()
            overlayContainer.view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
        }

        it("should move the overlay to the specified notch") {
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
            overlayContainer.loadViewIfNeeded()
            Notch.allCases.forEach { notch in
                overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
                overlayContainer.view.layoutIfNeeded()
                expect(overlay.view.frame.height).to(equal(delegate.height(for: notch)))
            }
        }

        it("should invalidate the current notches") {
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
            overlayContainer.loadViewIfNeeded()
            Notch.allCases.forEach { notch in
                overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
                overlayContainer.view.layoutIfNeeded()
                expect(overlay.view.frame.height).to(equal(delegate.height(for: notch)))
            }
            delegate.usesNewNotches = true
            overlayContainer.invalidateNotchHeights()
            NewNotch.allCases.forEach { notch in
                overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
                overlayContainer.view.layoutIfNeeded()
                expect(overlay.view.frame.height).to(equal(delegate.height(forNew: notch)))
            }
        }

        it("should call completion callback after animation is finished") {
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
            overlayContainer.loadViewIfNeeded()
            overlayContainer.view.layoutIfNeeded()
            Notch.allCases.forEach { notch in
                waitUntil(timeout: 1) { done in
                    overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: true) {
                        expect(true).to(beTrue())
                        done()
                    }
                    overlayContainer.view.layoutIfNeeded()
                }
            }
        }

        it("should call completion callback when animation is set to false") {
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
            overlayContainer.loadViewIfNeeded()
            overlayContainer.view.layoutIfNeeded()
            Notch.allCases.forEach { notch in
                waitUntil(timeout: 1) { done in
                    overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false) {
                        expect(true).to(beTrue())
                        done()
                    }
                    overlayContainer.view.layoutIfNeeded()
                }
            }
        }

        it("should call completion callbacks in order") {
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
            overlayContainer.loadViewIfNeeded()
            overlayContainer.view.layoutIfNeeded()
            waitUntil(timeout: 1) { done in
                var i = 0
                overlayContainer.moveOverlay(toNotchAt: Notch.minimum.rawValue, animated: false) {
                    i += 1
                }
                overlayContainer.moveOverlay(toNotchAt: Notch.medium.rawValue, animated: false) {
                    i += 1
                    expect(i).to(equal(2))
                    expect(overlay.view.frame.height).to(equal(delegate.height(for: .medium)))
                    done()
                }
                overlayContainer.view.layoutIfNeeded()
            }
        }

        it("should move the overlay even if the overlay is set before the delegate") {
            let notch = Notch.maximum
            overlayContainer.delegate = delegate
            overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
            overlayContainer.viewControllers = [overlay]
            overlayContainer.view.layoutIfNeeded()
            expect(overlay.view.frame.height).to(equal(delegate.height(for: notch)))
        }

        it("should move the overlay even if the overlay is set after the delegate") {
            let notch = Notch.maximum
            overlayContainer.viewControllers = [overlay]
            overlayContainer.delegate = delegate
            overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
            overlayContainer.view.layoutIfNeeded()
            expect(overlay.view.frame.height).to(equal(delegate.height(for: notch)))
        }
    }
}
