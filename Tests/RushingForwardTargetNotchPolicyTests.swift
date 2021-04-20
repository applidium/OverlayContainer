//
//  RushingForwardTargetNotchPolicyTests.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 20/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Quick
import Nimble
@testable import OverlayContainer

private struct TargetContext: OverlayContainerContextTargetNotchPolicy {

    var heightByIndex: [Int: CGFloat] = [:]
    var isDragging = false
    var velocity: CGPoint = .zero
    var overlayTranslationHeight: CGFloat = 0.0
    var reachableIndexes: [Int] = []
    var notchIndexes: Range<Int> {
        0..<heightByIndex.count
    }

    let overlayViewController = UIViewController()

    func height(forNotchAt index: Int) -> CGFloat {
        heightByIndex[index] ?? 0.0
    }
}

class RushingForwardTargetNotchPolicyTests: QuickSpec {

    override func spec() {

        var context: TargetContext!
        var policy: RushingForwardTargetNotchPolicy!

        beforeEach {
            context = TargetContext()
            policy = RushingForwardTargetNotchPolicy()
        }

        it("should target expected index when stationnary") {
            context.heightByIndex = [
                0: 100.0,
                1: 200.0,
                2: 300.0,
            ]
            context.reachableIndexes = Array(context.notchIndexes)
            context.velocity = .zero
            let expectedIndexByHeight: [CGFloat: Int] = [
                0.0: 0,
                50.0: 0,
                100.0: 0,
                149.0: 0,
                151.0: 1,
                200.0: 1,
                249.0: 1,
                251.0: 2,
                300.0: 2,
                310.0: 2,
                100000.0: 2,
            ]
            expectedIndexByHeight.forEach { height, index in
                context.overlayTranslationHeight = height
                let target = policy.targetNotchIndex(using: context)
                XCTAssertEqual(target, index, "\(target) for height:\(height) does notch match \(index)")
            }
        }

        it("should bypass indexes at high velocity") {
            context.heightByIndex = [
                0: 100.0,
                1: 200.0,
                2: 300.0,
            ]
            context.reachableIndexes = Array(context.notchIndexes)
            let expectedIndexByVelocity: [(CGPoint, CGFloat, Int)] = [
                (CGPoint(x: 0.0, y: -100.0), 125, 0),
                (CGPoint(x: 0.0, y: -200.0), 125, 0),
                (CGPoint(x: 0.0, y: -500.0), 125, 1),
                (CGPoint(x: 0.0, y: 100.0), 251, 2),
                (CGPoint(x: 0.0, y: 200.0), 251, 2),
                (CGPoint(x: 0.0, y: 500.0), 251, 1),
            ]
            expectedIndexByVelocity.forEach { velocity, height, index in
                context.velocity = velocity
                context.overlayTranslationHeight = height
                policy.minimumDuration = 0.0
                policy.minimumVelocity = 400.0
                let target = policy.targetNotchIndex(using: context)
                XCTAssertEqual(target, index, "\(target) for velocity:(\(velocity.x), \(velocity.y)) does notch match \(index)")
            }
        }

        it("should not target disabled indexes") {
            context.heightByIndex = [
                0: 100.0,
                1: 200.0,
                2: 300.0,
            ]
            context.reachableIndexes = [1, 2]
            context.velocity = .zero
            let expectedIndexByHeight: [CGFloat: Int] = [
                0.0: 1,
                50.0: 1,
                100.0: 1,
                149.0: 1,
            ]
            expectedIndexByHeight.forEach { height, index in
                context.overlayTranslationHeight = height
                let target = policy.targetNotchIndex(using: context)
                XCTAssertEqual(target, index, "\(target) for height:\(height) does notch match \(index)")
            }
        }
    }
}
