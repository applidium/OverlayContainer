//
//  ScrollViewDelegateTest.swift
//  OverlayContainer_Tests
//
//  Created by Gaétan Zanella on 24/12/2018.
//  Copyright © 2018 Gaétan Zanella. All rights reserved.
//

import Nimble
import Quick
import OverlayContainer

private class ScrollViewController: UIViewController, UIScrollViewDelegate {
    var scrollView = UIScrollView()
}

class OverlayScrollViewDelegateTest: QuickSpec {
    override func spec() {
        let viewController = ScrollViewController()
        let overlayContainer = OverlayContainerViewController()
        overlayContainer.viewControllers = [viewController]
        overlayContainer.loadViewIfNeeded()
        it("should observe the scroll view delegate") {
            overlayContainer.drivingScrollView = viewController.scrollView
            expect(viewController.scrollView.delegate).toNot(beNil())
            viewController.scrollView.delegate = viewController
            expect(viewController.scrollView.delegate).toNot(beIdenticalTo(viewController))
        }
    }
}
