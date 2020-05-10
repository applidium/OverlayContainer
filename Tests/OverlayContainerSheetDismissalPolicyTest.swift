//
//  OverlayContainerSheetDismissalPolicyTest.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 14/04/2020.
//  Copyright © 2020 Gaétan Zanella. All rights reserved.
//

import Nimble
import Quick
import OverlayContainer

private enum Notch: Int, CaseIterable {
    case min, med, max
}

class FakeOverlayContainerSheetDismissalPolicyContext: OverlayContainerSheetDismissalPolicyContext {
    var targetTranslationHeight: CGFloat { overlayTranslationHeight }

    var isDragging: Bool { false }
    var velocity: CGPoint = .zero
    var overlayTranslationHeight: CGFloat = 0

    var notchIndexes: Range<Int> {
        0..<Notch.allCases.count
    }

    var reachableIndexes: [Int] {
        Notch.allCases.map { $0.rawValue }
    }

    func height(forNotchAt index: Int) -> CGFloat {
        switch Notch.allCases[index] {
        case .max:
            return 200
        case .med:
            return 100
        case .min:
            return 0
        }
    }
}

class OverlayContainerSheetDismissalPolicyTest: QuickSpec {

    override func spec() {

        var context: FakeOverlayContainerSheetDismissalPolicyContext!
        var policy: ThresholdOverlayContainerSheetDismissalPolicy!

        beforeEach {
            policy = ThresholdOverlayContainerSheetDismissalPolicy()
            context = FakeOverlayContainerSheetDismissalPolicyContext()
        }

        it("should dismiss if the translation reaches the threshold") {
            context.overlayTranslationHeight = 190
            policy.dismissingVelocity = .none
            policy.dismissingPosition = .translationHeight(200)
            expect(policy.shouldDismiss(using: context)).to(beTrue())
        }

        it("should not dismiss if the translation does not reach the threshold") {
            context.overlayTranslationHeight = 200
            policy.dismissingVelocity = .none
            policy.dismissingPosition = .translationHeight(100)
            expect(policy.shouldDismiss(using: context)).to(beFalse())
        }

        it("should dismiss if the translation reaches the threshold notch") {
            context.overlayTranslationHeight = context.height(forNotchAt: Notch.med.rawValue) - 1
            policy.dismissingVelocity = .none
            policy.dismissingPosition = .notch(index: Notch.med.rawValue)
            expect(policy.shouldDismiss(using: context)).to(beTrue())
        }

        it("should not dismiss if the translation does not reach the threshold notch") {
            context.overlayTranslationHeight = context.height(forNotchAt: Notch.med.rawValue) + 1
            policy.dismissingVelocity = .none
            policy.dismissingPosition = .notch(index: Notch.med.rawValue)
            expect(policy.shouldDismiss(using: context)).to(beFalse())
        }

        it("should ignore the notch height if threashold is none") {
            context.overlayTranslationHeight = 0
            context.velocity.y = 100000
            policy.dismissingVelocity = .none
            policy.dismissingPosition = .none
            expect(policy.shouldDismiss(using: context)).to(beFalse())
        }

        it("should dismiss if the translation velocity reaches the threshold") {
            context.overlayTranslationHeight = 0
            context.velocity.y = 1000
            policy.dismissingVelocity = .value(900)
            policy.dismissingPosition = .none
            expect(policy.shouldDismiss(using: context)).to(beTrue())
        }

        it("should not dismiss if the translation velocity does not reach the threshold") {
            context.overlayTranslationHeight = 0
            context.velocity.y = 900
            policy.dismissingVelocity = .value(1000)
            policy.dismissingPosition = .none
            expect(policy.shouldDismiss(using: context)).to(beFalse())
        }
    }
}
