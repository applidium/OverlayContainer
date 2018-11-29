//
//  OverlayViewController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 12/11/2018.
//

import UIKit

public class OverlayContainerViewController: UIViewController, OverlayScrollViewDelegate {

    enum TranslationPosition {
        case top, bottom, inFlight
    }

    public var delegate: OverlayContainerViewControllerDelegate? {
        set {
            configuration.delegate = newValue
            needsOverlayContainerHeightUpdate = true
        }
        get {
            return configuration.delegate
        }
    }

    public var viewControllers: [UIViewController] = [] {
        didSet {
            guard isViewLoaded else { return }
            oldValue.forEach { removeChild($0) }
            loadOverlayViews()
        }
    }

    public var topViewController: UIViewController? {
        return viewControllers.last
    }

    private lazy var overlayPanGesture: OverlayTranslationGestureRecognizer = self.makePanGesture()
    private lazy var overlayContainerView = OverlayContainerView()
    private lazy var overlayTranslationView = OverlayTranslationView()
    private var overlayContainerViewHeightConstraint: NSLayoutConstraint?
    private var translationHeightConstraint: NSLayoutConstraint?

    private lazy var configuration: OverlayContainerViewControllerConfiguration = self.makeConfiguration()
    private let proxy = OverlayScrollViewDelegateProxy()

    // (gz) 2018-11-27 The overlay's transaction is not always equal to the scroll view translation.
    // The user can scroll bottom then drag the overlay up repeatedly in a single gesture.
    private var overlayTranslation: CGFloat = 0
    private var scrollViewTranslation: CGFloat = 0
    private var lastContentOffsetWhileScrolling: CGPoint = .zero

    private var needsOverlayContainerHeightUpdate = true {
        didSet {
            view.setNeedsLayout()
        }
    }

    private(set) var targetNotchIndex = 0

    private var targetNotchHeight: CGFloat {
        return configuration.heightForNotch(at: targetNotchIndex)
    }

    private var overlayTranslationHeight: CGFloat {
        return translationHeightConstraint?.constant ?? 0
    }

    private var translationPosition: OverlayContainerViewController.TranslationPosition {
        if overlayTranslationHeight == configuration.lastNotchHeight {
            return .top
        } else if overlayTranslationHeight == configuration.firstNotchHeight {
            return .bottom
        } else {
            return .inFlight
        }
    }

    // MARK: - UIViewController

    public override func loadView() {
        view = PassThroughView()
        loadTranslationViews()
        loadOverlayViews()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpPanGesture()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard needsOverlayContainerHeightUpdate else { return }
        needsOverlayContainerHeightUpdate = false
        overlayContainerViewHeightConstraint?.constant = configuration.lastNotchHeight
        dragOverlay(toHeight: targetNotchHeight)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        needsOverlayContainerHeightUpdate = true
    }

    // MARK: - Public

    public func moveOverlay(toNotchAt index: Int, animated: Bool) {
        view.layoutIfNeeded()
        moveOverlay(toNotchAt: index, velocity: .zero, animated: animated)
    }

    // MARK: - OverlayScrollViewDelegate


    func overlayScrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousTranslation = scrollViewTranslation
        scrollViewTranslation = scrollView.panGestureRecognizer.translation(in: view).y
        if shouldDragOverlay(following: scrollView) {
            overlayTranslation += scrollViewTranslation - previousTranslation
            let offset = adjustedContentOffset(dragging: scrollView)
            scrollView.contentOffset = offset
            dragOverlay(forOffset: overlayTranslation, usesFunction: false)
        } else {
            lastContentOffsetWhileScrolling = scrollView.contentOffset
        }
    }

    func overlayScrollView(_ scrollView: UIScrollView,
                           willEndDraggingwithVelocity velocity: CGPoint,
                           targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        overlayTranslation = 0
        scrollViewTranslation = 0
        // (gz) 2018-11-27 We reset the translation each time the user ends dragging.
        // Otherwise the calculation is wrong in `overlayScrollViewDidScroll(_:)`
        // if the user drags the overlay while the animation did not finish.
        scrollView.panGestureRecognizer.setTranslation(.zero, in: view)
        switch translationPosition {
        case .bottom where targetContentOffset.pointee.y > -scrollView.contentInset.top:
            // (gz) 2018-11-26 The user raises its finger in the bottom position
            // and the content offset will exceed the top content inset.
            targetContentOffset.pointee.y = -scrollView.contentInset.top
        case .inFlight where !overlayHasReachedANotch():
            targetContentOffset.pointee.y = lastContentOffsetWhileScrolling.y
        case .top, .bottom, .inFlight:
            break
        }
        endOverlayTranslation(withVelocity: velocity)
    }

    // MARK: - Action

    @objc private func overlayPanGestureAction(_ sender: OverlayTranslationGestureRecognizer) {
        guard let overlay = topViewController else { return }
        let translation = sender.translation(in: nil)
        switch sender.state {
        case .began:
            let location = sender.location(in: nil)
            let startingPoint = location.offset(by: translation.multiply(by: -1))
            let shouldStartDragging = configuration.shouldStartDraggingOverlay(
                overlay,
                at: startingPoint,
                in: view
            )
            if shouldStartDragging {
                dragOverlay(forOffset: translation.y, usesFunction: true)
            } else {
                sender.cancel()
            }
        case .changed:
            dragOverlay(forOffset: translation.y, usesFunction: true)
        case .failed, .ended, .cancelled:
            let convertedVelocity = sender.velocity(in: nil)
            endOverlayTranslation(withVelocity: convertedVelocity)
        case .possible:
            break
        }
    }

    // MARK: - Private

    private func loadTranslationViews() {
        view.addSubview(overlayTranslationView)
        overlayTranslationView.addSubview(overlayContainerView)
        overlayTranslationView.pinToSuperview(edges: [.bottom, .left, .right])
        overlayContainerView.pinToSuperview(edges: [.left, .top, .right])
        translationHeightConstraint = overlayTranslationView.heightAnchor.constraint(equalToConstant: 0)
        translationHeightConstraint?.isActive = true
        overlayContainerViewHeightConstraint = overlayContainerView.heightAnchor.constraint(equalToConstant: 0)
        overlayContainerViewHeightConstraint?.isActive = true
    }

    private func loadOverlayViews() {
        viewControllers.forEach { addChild($0, in: overlayContainerView) }
        if let topViewController = topViewController,
            let scrollView = configuration.scrollView(drivingOverlay: topViewController) {
            proxy.forward(to: self, delegateInvocationsFrom: scrollView)
        }
    }

    private func setUpPanGesture() {
        view.addGestureRecognizer(overlayPanGesture)
    }

    private func overlayHasReachedANotch() -> Bool {
        return configuration.heights().contains { $0 == overlayTranslationHeight }
    }

    private func overlayHasAmibiguousTranslationHeight() -> Bool {
        guard let index = configuration.heights().index(where: { $0 == overlayTranslationHeight }) else {
            return true
        }
        return configuration.heightForNotch(at: index) != targetNotchHeight
    }

    private func shouldDragOverlay(following scrollView: UIScrollView) -> Bool {
        guard scrollView.isTracking else { return false }
        switch translationPosition {
        case .bottom:
            return !scrollView.isContentOriginInBounds && scrollView.scrollsUp
        case .top:
            return scrollView.isContentOriginInBounds && !scrollView.scrollsUp
        case .inFlight:
            return scrollView.isContentOriginInBounds || scrollView.scrollsUp
        }
    }

    private func dragOverlay(forOffset offset: CGFloat, usesFunction: Bool) {
        guard let viewController = topViewController else { return }
        let translation = targetNotchHeight - offset
        let height: CGFloat
        if usesFunction {
            let parameters = ConcreteOverlayTranslationParameters(
                minimumHeight: configuration.firstNotchHeight,
                maximumHeight: configuration.lastNotchHeight,
                translation: translation
            )
            let function = configuration.overlayTranslationFunction(using: parameters, for: viewController)
            height = function.overlayTranslationHeight(using: parameters)
        } else {
            height = max(configuration.firstNotchHeight, min(configuration.lastNotchHeight, translation))
        }
        dragOverlay(toHeight: height)
    }

    private func adjustedContentOffset(dragging scrollView: UIScrollView) -> CGPoint {
        var contentOffset = lastContentOffsetWhileScrolling
        switch translationPosition {
        case .inFlight, .top:
            // (gz) 2018-11-26 The user raised its finger in the top or in flight positions while scrolling bottom.
            // If the scroll's animation did not finish when the user drags the overlay,
            // the content offset may have exceeded the top inset. We adjust it.
            if scrollView.isContentOriginInBounds {
                scrollView.scrollToTop()
            }
        case .bottom:
            break
        }
        // (gz) 2018-11-26 Between two `overlayScrollViewDidScroll:` calls,
        // the scrollView exceeds the top's contentInset. We adjust the target.
        let topInset = -scrollView.contentInset.top
        if (contentOffset.y - topInset) * (scrollView.contentOffset.y - topInset) < 0 {
            contentOffset.y = topInset
        }
        return contentOffset
    }

    private func endOverlayTranslation(withVelocity velocity: CGPoint) {
        guard let controller = topViewController, overlayHasAmibiguousTranslationHeight() else { return }
        let values = (0..<configuration.numberOfNotches()).map { ($0, configuration.heightForNotch(at: $0)) }
        let context = ConcreteOverlayContainerContextTargetNotchPolicy(
            overlayViewController: controller,
            overlayTranslationHeight: overlayTranslationHeight,
            velocity: velocity,
            notchHeightByIndex: Dictionary(uniqueKeysWithValues: values)
        )
        let policy = configuration.overlayTargetNotchPolicy(forOverlay: controller)
        let index = policy.targetNotchIndex(using: context)
        moveOverlay(toNotchAt: index, velocity: velocity, animated: true)
    }

    private func moveOverlay(toNotchAt index: Int, velocity: CGPoint, animated: Bool) {
        guard let overlay = topViewController else { return }
        let height = overlayTranslationHeight
        targetNotchIndex = index
        dragOverlay(toHeight: targetNotchHeight)
        guard animated else { return }
        let context = ConcreteOverlayContainerContextTransitioning(
            overlayViewController: overlay,
            overlayTranslationHeight: height,
            velocity: velocity,
            targetNotchIndex: targetNotchIndex,
            targetNotchHeight: targetNotchHeight
        )
        let animationController = configuration.animationController(forOverlay: overlay)
        let animator = animationController.interruptibleAnimator(using: context)
        let coordinator = InterruptibleAnimatorOverlayContainerTransitionCoordinator(
            animator: animator,
            context: context
        )
        delegate?.overlayContainerViewController(
            self,
            willEndReachingNotchAt: targetNotchIndex,
            transitionCoordinator: coordinator
        )
        animator.addAnimations? {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    private func dragOverlay(toHeight height: CGFloat) {
        guard translationHeightConstraint?.constant != height else { return }
        translationHeightConstraint?.constant = height
        if let topViewController = topViewController {
            delegate?.overlayContainerViewController(
                self,
                didDragOverlay: topViewController,
                toHeight: height
            )
        }
    }

    private func makeConfiguration() -> OverlayContainerViewControllerConfiguration {
        return OverlayContainerViewControllerConfiguration(overlayContainerViewController: self)
    }

    private func makePanGesture() -> OverlayTranslationGestureRecognizer {
        return OverlayTranslationGestureRecognizer(
            target: self,
            action: #selector(overlayPanGestureAction(_:))
        )
    }
}
