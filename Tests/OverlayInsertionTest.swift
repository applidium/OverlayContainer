//
//  OverlayInsertionTest.swift
//  OverlayContainer_Tests
//
//  Created by Gaétan Zanella on 24/12/2018.
//  Copyright © 2018 Gaétan Zanella. All rights reserved.
//

import Quick
import Nimble
import OverlayContainer

class OverlayInsertionTest: QuickSpec {
    override func spec() {
        let overlayContainer = OverlayContainerViewController()
        overlayContainer.loadViewIfNeeded()

        it("should insert overlay") {
            let overlay1 = UIViewController()
            overlayContainer.viewControllers = [overlay1]
            expect(overlayContainer.children).to(equal([overlay1]))
        }

        it("should replace overlay") {
            let overlay2 = UIViewController()
            overlayContainer.viewControllers = [overlay2]
            expect(overlayContainer.children).to(equal([overlay2]))
        }
    
        it("should remove overlay") {
            overlayContainer.viewControllers = []
            expect(overlayContainer.children).to(equal([]))
        }
    }
}
