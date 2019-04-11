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
    }

    /// The container's delegate.
    public var delegate: OverlayContainerViewControllerDelegate? {
        set {
            configuration.delegate = newValue
            needsOverlayContainerHeightUpdate = true
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

    private lazy var configuration: OverlayContainerViewControllerConfiguration = self.makeConfiguration()

    private var needsOverlayContainerHeightUpdate = true {
        didSet {
            view.setNeedsLayout()
        }
    }

    private var previousSize: CGSize = .zero
    private var translationController: HeightConstraintOverlayTranslationController?
    private var translationDrivers: [OverlayTranslationDriver] = []

    private var overlayContainerConstraintsAreActive: Bool {
        return (overlayContainerViewStyleConstraint?.isActive ?? false)
            && (translationHeightConstraint?.isActive ?? false)
    }

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
        loadTranslationViews()
        loadOverlayViews()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpPanGesture()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard needsOverlayContainerHeightUpdate || previousSize != view.bounds.size else { return }
        self.previousSize = view.bounds.size
        needsOverlayContainerHeightUpdate = false
        updateOverlayConstraints(forNew: view.bounds.size)
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        self.previousSize = size
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
        if !overlayContainerConstraintsAreActive {
            view.layoutIfNeeded()
        }
        translationController?.moveOverlay(toNotchAt: index, velocity: .zero, animated: animated, completion: completion)
    }

    /// Invalidates the current container's notches.
    ///
    /// This method does not reload the notch heights immediately. The changes are scheduled to the next layout pass.
    /// Call `moveOverlay(toNotchAt:animated:)` to perform the change immediately.
    ///
    /// - warning: Be sure to move the overlay to a correct notch if the number of notches has changed.
    ///
    public func invalidateNotchHeights() {
        needsOverlayContainerHeightUpdate = true
    }

    // MARK: - Private

    private func loadTranslationViews() {
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
        }
    }

    private func updateOverlayConstraints(forNew size: CGSize) {
        guard let controller = translationController else {
            return
        }
        configuration.reloadNotchHeights()
        switch style {
        case .flexibleHeight:
            overlayContainerViewStyleConstraint?.constant = 0
        case .rigid:
            overlayContainerViewStyleConstraint?.constant = configuration.maximumNotchHeight
        }
        controller.moveOverlay(toNotchAt: controller.translationEndNotchIndex, velocity: .zero, animated: false)
        translationHeightConstraint?.isActive = true
        overlayContainerViewStyleConstraint?.isActive = true
    }

    private func loadOverlayViews() {
        guard !viewControllers.isEmpty else { return }
        groundView.isHidden = viewControllers.count == 1
        var truncatedViewControllers = viewControllers
        truncatedViewControllers.popLast().flatMap { addChild($0, in: overlayContainerView) }
        truncatedViewControllers.forEach { addChild($0, in: groundView) }
        loadTranslationController()
        loadTranslationDrivers()
    }

    private func loadTranslationController() {
        guard let translationHeightConstraint = translationHeightConstraint,
            let overlayController = topViewController else {
                return
        }
        translationController = HeightConstraintOverlayTranslationController(
            translationHeightConstraint: translationHeightConstraint,
            overlayViewController: overlayController,
            configuration: configuration
        )
        translationController?.delegate = self
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

    private func setUpPanGesture() {
        view.addGestureRecognizer(overlayPanGesture)
    }
    private func makeConfiguration() -> OverlayContainerViewControllerConfiguration {
        return OverlayContainerViewControllerConfiguration(overlayContainerViewController: self)
    }

    private func makePanGesture() -> OverlayTranslationGestureRecognizer {
        return OverlayTranslationGestureRecognizer()
    }
}

extension OverlayContainerViewController: OverlayTranslationControllerDelegate {

    // MARK: - HeightContrainstOverlayTranslationControllerDelegate

    func translationController(_ translationController: OverlayTranslationController,
                               didDragOverlayToHeight height: CGFloat) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            didDragOverlay: controller,
            toHeight: height,
            availableSpace: previousSize.height
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willReachNotchAt index: Int,
                               transitionCoordinator: OverlayContainerTransitionCoordinator) {
        guard let controller = topViewController else { return }
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
        }, completion: { _ in })
        delegate?.overlayContainerViewController(
            self,
            didEndDraggingOverlay: controller,
            transitionCoordinator: transitionCoordinator
        )
    }
}
