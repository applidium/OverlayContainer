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

class OverlayNotchHeightTest: QuickSpec, OverlayContainerViewControllerDelegate {

    enum Notch: Int, CaseIterable {
        case minimum, medium, maximum
    }

    // MARK: - QuickSpec

    override func spec() {
        let overlayContainer = OverlayContainerViewController()
        overlayContainer.loadViewIfNeeded()
        overlayContainer.view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
        let overlay = UIViewController()
        overlayContainer.delegate = self
        overlayContainer.viewControllers = [overlay]
        it("should move the overlay to the specified notch") {
            Notch.allCases.forEach { notch in
                overlayContainer.moveOverlay(toNotchAt: notch.rawValue, animated: false)
                overlayContainer.view.layoutIfNeeded()
                expect(overlay.view.frame.height).to(equal(self.height(for: notch)))
            }
        }
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return Notch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        return height(for: Notch.allCases[index])
    }

    private func height(for notch: Notch) -> CGFloat {
        switch notch {
        case .minimum:
            return 0
        case .medium:
            return 50
        case .maximum:
            return 100
        }
    }
}
