//
//  OverlayViewController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 12/11/2018.
//

import UIKit

/// A `OverlayContainerViewController` is a container view controller that manages one or more
/// child view controllers in an overlay interface. It defines an area where its children can be dragged up and down
/// hidding or revealing the content underneath it. The container does not contain this underlying content.
public class OverlayContainerViewController: UIViewController {

    /// `OverlayStyle` defines how the overlay view controllers will be constrained in the container.
    public enum OverlayStyle {
        /// The overlay view controller will not be height-constrained. They will grow and shrink
        /// as the user drags them up and down.
        case flexibleHeight
        /// The overlay view controller will be constrained with a height equal to the highest notch.
        /// They will be fully visible only when the user has drag them up to this notch.
        case rigid
        /// The overlay view controller will be constrained with a height greater or equal to the highest notch.
        /// Its height will be expanded if the overlay goes beyond the highest notch.
        case expandableHeight
    }

    /// The container's delegate.
    public var delegate: OverlayContainerViewControllerDelegate? {
        set {
            configuration.delegate = newValue
            configuration.invalidateOverlayMetrics()
            setNeedsOverlayContainerHeightUpdate()
        }
        get {
            return configuration.delegate
        }
    }

    /// The overlay view controllers.
    public var viewControllers: [UIViewController] = [] {
        didSet {
            guard isViewLoaded else { return }
            oldValue.forEach { removeChild($0) }
            loadOverlayViews()
        }
    }

    /// The visible overlay view controller.
    public var topViewController: UIViewController? {
        return viewControllers.last
    }

    /// The scroll view managing the overlay translation.
    public weak var drivingScrollView: UIScrollView? {
        didSet {
            guard drivingScrollView !== oldValue else { return }
            guard isViewLoaded else { return }
            loadTranslationDrivers()
        }
    }

    /// The overlay container's style.
    public let style: OverlayStyle

    private lazy var overlayPanGesture: OverlayTranslationGestureRecognizer = self.makePanGesture()
    private lazy var overlayContainerView = OverlayContainerView()
    private lazy var overlayTranslationView = OverlayTranslationView()
    private lazy var groundView = GroundView()
    private var overlayContainerViewStyleConstraint: NSLayoutConstraint?
    private var translationHeightConstraint: NSLayoutConstraint?

    private lazy var configuration = makeConfiguration()

    private var needsOverlayContainerHeightUpdate = true

    private var previousSize: CGSize = .zero
    private var translationController: HeightConstraintOverlayTranslationController?
    private var translationDrivers: [OverlayTranslationDriver] = []

    // MARK: - Life Cycle

    /// Creates an instance with the specified `style`.
    ///
    /// - parameter style: The style uses by the container. The default value is `flexibleHeight`.
    ///
    /// - returns: The new `OverlayContainerViewController` instance.
    public init(style: OverlayStyle = .flexibleHeight) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.style = .flexibleHeight
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    public override func loadView() {
        view = PassThroughView()
        loadContainerViews()
        loadOverlayViews()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpPanGesture()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let hasNewSize = previousSize != view.bounds.size
        guard needsOverlayContainerHeightUpdate || hasNewSize else { return }
        self.previousSize = view.bounds.size
        if hasNewSize {
            configuration.invalidateOverlayMetrics()
        }
        needsOverlayContainerHeightUpdate = false
        updateOverlayConstraints(forNew: view.bounds.size)
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        self.previousSize = size
        if let controller = translationController {
            controller.moveOverlay(
                toNotchAt: controller.lastTranslationEndNotchIndex,
                velocity: .zero,
                animated: true
            )
        }
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateOverlayConstraints(forNew: size)
        }, completion: nil)
    }

    // MARK: - Public

    /// Moves the overlay view controllers to the specified notch.
    ///
    /// - parameter index: The index of the target notch.
    /// - parameter animated: Defines either the transition should be animated or not.
    ///
    public func moveOverlay(toNotchAt index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        loadViewIfNeeded()
        translationController?.moveOverlay(
            toNotchAt: index,
            velocity: .zero,
            animated: animated,
            completion: completion
        )
    }

    /// Invalidates the current container's notches.
    ///
    /// This method does not reload the notch heights immediately. The changes are scheduled to the next layout pass.
    /// Call `moveOverlay(toNotchAt:animated:)` to perform the change immediately.
    ///
    /// - warning: Be sure to move the overlay to a correct notch if the number of notches has changed.
    ///
    public func invalidateNotchHeights() {
        configuration.invalidateOverlayMetrics()
        setNeedsOverlayContainerHeightUpdate()
    }

    // MARK: - Private

    private func loadContainerViews() {
        view.addSubview(groundView)
        groundView.pinToSuperview()
        view.addSubview(overlayTranslationView)
        overlayTranslationView.addSubview(overlayContainerView)
        overlayTranslationView.pinToSuperview(edges: [.bottom, .left, .right])
        overlayContainerView.pinToSuperview(edges: [.left, .top, .right])
        translationHeightConstraint = overlayTranslationView.heightAnchor.constraint(equalToConstant: 0)
        switch style {
        case .flexibleHeight:
            overlayContainerViewStyleConstraint = overlayContainerView.bottomAnchor.constraint(
                equalTo: overlayTranslationView.bottomAnchor
            )
        case .rigid:
            overlayContainerViewStyleConstraint = overlayContainerView.heightAnchor.constraint(
                equalToConstant: 0
            )
        case .expandableHeight:
            overlayContainerViewStyleConstraint = overlayContainerView.heightAnchor.constraint(
                equalToConstant: 0
            )
            overlayContainerViewStyleConstraint?.priority = .defaultHigh
            let bottomConstraint = overlayContainerView.bottomAnchor.constraint(
                greaterThanOrEqualTo: overlayTranslationView.bottomAnchor
            )
            bottomConstraint.isActive = true
        }
        loadTranslationController()
    }

    private func loadTranslationController() {
        guard let translationHeightConstraint = translationHeightConstraint else { return }
        translationController = HeightConstraintOverlayTranslationController(
            translationHeightConstraint: translationHeightConstraint,
            configuration: configuration
        )
        translationController?.delegate = self
        translationController?.moveOverlay(toNotchAt: 0, velocity: .zero, animated: false, completion: nil)
    }

    private func loadOverlayViews() {
        guard !viewControllers.isEmpty else { return }
        groundView.isHidden = viewControllers.count == 1
        var truncatedViewControllers = viewControllers
        truncatedViewControllers.popLast().flatMap { addChild($0, in: overlayContainerView) }
        truncatedViewControllers.forEach { addChild($0, in: groundView) }
        loadTranslationDrivers()
    }

    private func loadTranslationDrivers() {
        guard let translationController = translationController,
            let overlayController = topViewController else {
                return
        }
        translationDrivers.forEach { $0.clean() }
        translationDrivers.removeAll()
        var drivers: [OverlayTranslationDriver] = []
        let panGestureDriver = PanGestureOverlayTranslationDriver(
            translationController: translationController,
            panGestureRecognizer: overlayPanGesture
        )
        drivers.append(panGestureDriver)
        let scrollView = drivingScrollView ?? configuration.scrollView(drivingOverlay: overlayController)
        if let scrollView = scrollView {
            overlayPanGesture.drivingScrollView = scrollView
            let driver = ScrollViewOverlayTranslationDriver(
                translationController: translationController,
                scrollView: scrollView
            )
            drivers.append(driver)
        }
        translationDrivers = drivers
    }

    private func setNeedsOverlayContainerHeightUpdate() {
        needsOverlayContainerHeightUpdate = true
        view.setNeedsLayout()
    }

    private func updateOverlayConstraints(forNew size: CGSize) {
        guard let controller = translationController else {
            return
        }
        switch style {
        case .flexibleHeight:
            overlayContainerViewStyleConstraint?.constant = 0
        case .rigid, .expandableHeight:
            overlayContainerViewStyleConstraint?.constant = configuration.maximumNotchHeight
        }
        controller.performDeferredTranslations()
        translationHeightConstraint?.isActive = true
        overlayContainerViewStyleConstraint?.isActive = true
    }

    private func setUpPanGesture() {
        view.addGestureRecognizer(overlayPanGesture)
    }
    private func makeConfiguration() -> OverlayContainerConfigurationImplementation {
        return OverlayContainerConfigurationImplementation(
            overlayContainerViewController: self
        )
    }

    private func makePanGesture() -> OverlayTranslationGestureRecognizer {
        return OverlayTranslationGestureRecognizer()
    }
}

extension OverlayContainerViewController: HeightConstraintOverlayTranslationControllerDelegate {

    // MARK: - HeightOverlayTranslationControllerDelegate

    func translationController(_ translationController: OverlayTranslationController,
                               didDragOverlayToHeight height: CGFloat) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            didDragOverlay: controller,
            toHeight: height
        )
    }

    func translationControllerDidStartDraggingOverlay(_ translationController: OverlayTranslationController) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            willStartDraggingOverlay: controller
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willEndDraggingToTargetIndex index: Int) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            willEndDraggingOverlay: controller,
            targetNotchIndex: index
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willTranslateOverlayWith transitionCoordinator: OverlayContainerTransitionCoordinator) {
        guard let controller = topViewController else { return }
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
        }, completion: { _ in })
        delegate?.overlayContainerViewController(
            self,
            willTranslateOverlay: controller,
            transitionCoordinator: transitionCoordinator
        )
    }

    func translationControllerDidScheduleTranslations(_ translationController: OverlayTranslationController) {
        setNeedsOverlayContainerHeightUpdate()
    }

    func overlayViewController(for translationController: OverlayTranslationController) -> UIViewController? {
        return topViewController
    }
}
