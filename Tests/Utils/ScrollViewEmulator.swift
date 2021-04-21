//
//  ScrollViewEmulator.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 20/04/2021.
//  Copyright © 2021 Gaétan Zanella. All rights reserved.
//

import Foundation
@testable import OverlayContainer

class EmulatedScrollView: UIScrollView {

    var mutableIsTracking = false
    var emulatedPanGesture = EmulatedPanGestureRecognizer()

    override var isTracking: Bool {
        mutableIsTracking
    }

    override var panGestureRecognizer: UIPanGestureRecognizer {
        emulatedPanGesture
    }
}

class EmulatedPanGestureRecognizer: UIPanGestureRecognizer {

    var velocity: CGPoint = .zero
    var translation: CGPoint = .zero

    override func translation(in view: UIView?) -> CGPoint {
        translation
    }

    override func velocity(in view: UIView?) -> CGPoint {
        velocity
    }
}

struct Gesture {

    fileprivate struct Value {
        let path: Path
        let endVelocity: CGPoint
        let onPointReached: (Int) -> Void
    }

    struct Path {
        let points: [CGPoint]

        init(_ points: CGPoint...) {
            self.points = points
        }

        init(_ points: [CGPoint]) {
            self.points = points
        }

        static func line(_ points: CGPoint...) -> Path {
            Path(points)
        }

        static func point(x: CGFloat = 0.0, y: CGFloat = 0.0) -> Self {
            Path(CGPoint(x: x, y: y))
        }

        func movingX(_ offset: CGFloat) -> Self {
            let lastY = points.last?.y ?? 0
            let lastX = points.last?.x ?? 0
            return Path(points + [CGPoint(x: lastX + offset, y: lastY)])
        }

        func movingY(_ offset: CGFloat) -> Self {
            let lastY = points.last?.y ?? 0
            let lastX = points.last?.x ?? 0
            return Path(points + [CGPoint(x: lastX, y: lastY + offset)])
        }
    }

    fileprivate var value: Value

    init(_ path: Path) {
        self.init(value: Value(path: path, endVelocity: .zero, onPointReached: { _ in }))
    }

    private init(value: Value) {
        self.value = value
    }

    func onPointReached(_ block: @escaping (Int) -> Void) -> Self {
        Gesture(value: Value(path: value.path, endVelocity: value.endVelocity, onPointReached: block))
    }

    func endVelocity(_ endVelocity: CGPoint) -> Self {
        Gesture(value: Value(path: value.path, endVelocity: endVelocity, onPointReached: value.onPointReached))
    }

    static func swipe(from origin: CGPoint, to destination: CGPoint) -> Gesture {
        Gesture(.line(origin, destination))
    }

    static func swipeUp(_ offset: CGFloat) -> Gesture {
        Gesture(.line(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: -offset)))
    }

    static func swipeDown(_ offset: CGFloat) -> Gesture {
        Gesture(.line(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: offset)))
    }
}

class ScrollViewEmulator {

    private var isDragging = false
    let scrollView: EmulatedScrollView
    private weak var delegate: OverlayScrollViewDelegate?

    // MARK: - Life Cycle

    init(scrollView: EmulatedScrollView,
         delegate: OverlayScrollViewDelegate) {
        self.scrollView = scrollView
        self.delegate = delegate
    }

    // MARK: - Public

    func emulate(_ gesture: Gesture) {
        var offset: CGPoint = .zero
        emulate(gesture, targetOffset: &offset)
    }

    func emulate(_ gesture: Gesture,
                 targetOffset: UnsafeMutablePointer<CGPoint>) {
        guard gesture.value.path.points.count > 1 else { return }
        scrollView.mutableIsTracking = true
        delegate?.overlayScrollViewWillBeginDragging(scrollView)
        let start = gesture.value.path.points[0]
        var last: CGPoint?
        gesture.value.path.points.enumerated().forEach { i, point in
            if let last = last {
                scrollView.emulatedPanGesture.translation = CGPoint(x: point.x - start.x, y: point.y - start.y)
                scrollView.contentOffset.x += -(point.x - last.x)
                scrollView.contentOffset.y += -(point.y - last.y)
                if point.y > last.y {
                    scrollView.emulatedPanGesture.velocity.y = 10
                } else if point.y < last.y {
                    scrollView.emulatedPanGesture.velocity.y = -10
                } else {
                    scrollView.emulatedPanGesture.velocity.y = 0
                }
                delegate?.overlayScrollViewDidScroll(scrollView)
            }
            gesture.value.onPointReached(i)
            last = point
        }
        delegate?.overlayScrollView(
            scrollView,
            willEndDraggingwithVelocity: gesture.value.endVelocity,
            targetContentOffset: targetOffset
        )
        scrollView.mutableIsTracking = false
    }
}
