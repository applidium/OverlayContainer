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
            overlayContainer = OverlayContainerViewController()
            delegate = OverlayContainerDelegateImplementation()
            overlay = UIViewController()
            overlayContainer.loadViewIfNeeded()
            overlayContainer.view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
            overlayContainer.delegate = delegate
            overlayContainer.viewControllers = [overlay]
        }
        it("should move the overlay to the specified notch") {
            Notch.allCases.forEach { notch in
                overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
                overlayContainer.view.layoutIfNeeded()
                expect(overlay.view.frame.height).to(equal(delegate.height(for: notch)))
            }
        }
        it("should invalidate the current notches") {
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
    }
}
