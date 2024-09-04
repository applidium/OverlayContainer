//
//  OverlayViewController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 12/11/2018.
//

import UIKit

/// A `OverlayContainerViewController` is a container view controller that manages one or more
/// child view controllers in an overlay interface.
///
/// It defines an area where a view controller, called the overlay view controller,
/// can be dragged up and down, hiding or revealing the content underneath it.
///
/// OverlayContainer uses the last view controller of its viewControllers as the overlay view controller.
/// It stacks the other view controllers on top of each other, if any, and adds them underneath the overlay view controller.
open class OverlayContainerViewController: UIViewController {

    /// `OverlayStyle` defines how the overlay view controller will be constrained in the container.
    public enum OverlayStyle {
        /// The overlay view controller will not be height-constrained. It will grow and shrink
        /// as the user drags it up and down.
        case flexibleHeight
        /// The overlay view controller will be constrained with a height equal to the highest notch.
        /// It will be fully visible only when the user has drag it up to this notch.
        case rigid
        /// The overlay view controller will be constrained with a height greater or equal to the highest notch.
        /// Its height will be expanded if the overlay goes beyond the highest notch.
        case expandableHeight
    }
	
	public enum DashViewStyle {
		case none
		case `default`
	}

    /// The delegate of the container.
    weak open var delegate: OverlayContainerViewControllerDelegate? {
        set {
            configuration.delegate = newValue
            configuration.invalidateOverlayMetrics()
            setNeedsOverlayContainerHeightUpdate()
        }
        get {
            return configuration.delegate
        }
    }
	
	open var maximumHeight: CGFloat? {
		nil
	}

    /// The view controllers displayed.
    open var viewControllers: [UIViewController] = [] {
        didSet {
            guard isViewLoaded else { return }
            oldValue.forEach { removeChild($0) }
            loadOverlayViews()
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// The overlay view controller
    open var topViewController: UIViewController? {
        return viewControllers.last
    }

    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    /// The scroll view managing the overlay translation.
    weak open var drivingScrollView: UIScrollView? {
        didSet {
            guard drivingScrollView !== oldValue else { return }
            guard isViewLoaded else { return }
            loadTranslationDrivers()
        }
    }

    /// The height of the area where the overlay view controller can be dragged up and down.
    /// It will only be valid once the container view is laid out or in the delegate callbacks.
    open var availableSpace: CGFloat {
        return view.frame.height
    }
	
	public var lastNotchIndex: Int? {
		translationController?.lastTranslationEndNotchIndex
	}

    /// The style of the container.
    public let style: OverlayStyle

    internal lazy var kbObserver: KeyboardObserverInterface = KeyboardObserver()
    internal var pinnedView: PassThroughView?

    private lazy var overlayPanGesture: OverlayTranslationGestureRecognizer = self.makePanGesture()
    internal lazy var overlayContainerView = OverlayContainerView()
    internal lazy var overlayTranslationView = OverlayTranslationView()
    internal lazy var overlayTranslationContainerView = OverlayTranslationContainerView()
	private lazy var overlayContainerWrappedView = OverlayContainerView()
    private lazy var groundView = GroundView()
	public private (set) lazy var dashView = DashView(
		frame: CGRect(
			x: 0,
			y: 0,
			width: UIScreen.main.bounds.width,
			height: 20
		)
	)

    internal var pinnedViewBottomConstraint: NSLayoutConstraint? {
        didSet {
            debugPrint("pinnedViewBottomConstraint, \(pinnedViewBottomConstraint?.constant ?? 0)")
        }
    }
    internal var finalBottomContraintValue: CGFloat = 0 {
        didSet {
            debugPrint("finalBottomContraintValue, \(finalBottomContraintValue)")
        }
    }
    internal var keyboardHeight: CGFloat = 0
    internal var overlayContainerViewStyleConstraint: NSLayoutConstraint?
    private var translationHeightConstraint: NSLayoutConstraint?

    internal lazy var configuration = makeConfiguration()
	internal var externalScrollViewDelegate: ExternalOverlayScrollViewDelegate?

    private var needsOverlayContainerHeightUpdate = true

    private var previousSize: CGSize = .zero
    private var translationController: HeightConstraintOverlayTranslationController?
    private var translationDrivers: [OverlayTranslationDriver] = []

	public var overlayTranslation: OverlayTranslationController? {
		translationController
	}

	open var cornerRadius: CGFloat {
		0
	}
    
    open var needNavbarInset: Bool {
        false
    }
    
	private var dashViewHeight: CGFloat {
		switch dashViewStyle {
		case .default:
			return 20
		case .none:
			return 0
		}
	}

	private let dashViewStyle: DashViewStyle
    
    internal var navControllerTopConstraint: NSLayoutConstraint?
	internal var leftInsetConstraint: NSLayoutConstraint?
	internal var rightInsetConstraint: NSLayoutConstraint?
	internal var contentMaxHeightConstraint: NSLayoutConstraint?

	internal var topInsetValue: CGFloat = .zero

    public var statusBarHeight: CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.top ?? 0
    }

    // (gz) 2020-08-11 Uses to determine whether we can safely call `presentationController` or not.
    // See issue #72
    private var isPresentedInsideAnOverlayContainerPresentationController = false

    // MARK: - Life Cycle

    /// Creates an instance with the specified `style`.
    ///
    /// - parameter style: The style used by the container. The default value is `expandableHeight`.
    ///
    /// - returns: The new `OverlayContainerViewController` instance.
    public init(
		style: OverlayStyle = .expandableHeight,
		dashViewStyle: DashViewStyle = .default
	) {
        self.style = style
		self.dashViewStyle = dashViewStyle
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.style = .flexibleHeight
		self.dashViewStyle = .default
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    open override func loadView() {
        view = PassThroughView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadContainerViews()
        loadOverlayViews()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        loadOverlayPinnedView()
        setUpPanGesture()
        setupKeyboardObserver()
    }

    open override func viewWillLayoutSubviews() {
        // (gz) 2019-06-10 According to the documentation, the default implementation of
        // `viewWillLayoutSubviews` does nothing.
        // Nethertheless in its `Changing Constraints` Guide, Apple recommends to call it.
        defer {
            super.viewWillLayoutSubviews()
        }
        let hasNewHeight = previousSize.height != view.bounds.size.height
        let hasPendingTranslation = translationController?.hasPendingTranslation() == true
        guard needsOverlayContainerHeightUpdate || hasNewHeight else { return }
        needsOverlayContainerHeightUpdate = false
        previousSize = view.bounds.size
        if hasNewHeight {
            configuration.invalidateOverlayMetrics()
        }
        if hasNewHeight && !hasPendingTranslation {
            translationController?.scheduleOverlayTranslation(
                .toLastReachedNotchIndex,
                velocity: .zero,
                animated: false
            )
        }
        configuration.requestOverlayMetricsIfNeeded()
        performDeferredTranslations()
    }
	
	public func setDragIndicatorHidden(_ isHidden: Bool) {
		baseAnimation { [weak self] in
			self?.dashView.dragIndicator.alpha = isHidden ? 0 : 1
		}
	}
	
	internal func baseAnimation(animations: @escaping () -> Void) {
		let timing = UISpringTimingParameters(
			mass: 1,
			stiffness: pow(2 * .pi / 0.3, 2),
			damping: 4 * .pi * 1 / 0.3,
			initialVelocity: .zero
		)
		let animator = UIViewPropertyAnimator(
			duration: 0,
			timingParameters: timing
		)
		animator.addAnimations {
			animations()
		}
		animator.startAnimation()
	}

    // MARK: - Internal

    func overlayContainerPresentationTransitionWillBegin() {
        isPresentedInsideAnOverlayContainerPresentationController = true
    }

    func overlayContainerDismissalTransitionDidEnd() {
        isPresentedInsideAnOverlayContainerPresentationController = false
    }

    // MARK: - Public

    /// Moves the overlay view controller to the specified notch.
    ///
    /// - parameter index: The index of the target notch.
    /// - parameter animated: Defines either the transition should be animated or not.
    /// - parameter completion: The block to execute after the translation finishes.
    ///   This block has no return value and takes no parameters. You may specify nil for this parameter.
    ///
    open func moveOverlay(toNotchAt index: Int, isNavBarHidden: Bool = false, insetColor: UIColor? = .clear, animated: Bool, completion: (() -> Void)? = nil) {
        loadViewIfNeeded()
        translationController?.scheduleOverlayTranslation(
            .toIndex(index),
            velocity: .zero,
            animated: animated,
            completion: completion
        )
        setNeedsOverlayContainerHeightUpdate()
    }

    /// Invalidates the current container notches.
    ///
    /// This method does not reload the notch heights immediately. The changes are scheduled to the next layout pass.
    /// By default, the overlay container will use its target notch policy to determine where to go
    /// and animates the translation.
    /// Use `moveOverlay(toNotchAt:animated:completion:)` to override this behavior.
    ///
    open func invalidateNotchHeights() {
        guard isViewLoaded else { return }
        configuration.invalidateOverlayMetrics()
        translationController?.scheduleOverlayTranslation(
            .basedOnTargetPolicy,
            velocity: .zero,
            animated: true
        )
        setNeedsOverlayContainerHeightUpdate()
    }

    // MARK: - Private

    private func loadContainerViews() {
        view.addSubview(groundView)
        groundView.pinToSuperview()
        view.addSubview(overlayTranslationContainerView)
        overlayTranslationContainerView.pinToSuperview()

        overlayTranslationContainerView.addSubview(overlayTranslationView)
        overlayTranslationView.addSubview(overlayContainerView)
		overlayContainerView.addSubview(overlayContainerWrappedView)
		
		overlayContainerView.pinToSuperview(edges: [.top, .left, .right])
		overlayContainerWrappedView.pinToSuperview(edges: [.top, .left, .right])
		
		contentMaxHeightConstraint = overlayContainerWrappedView.heightAnchor.constraint(
			equalToConstant: UIScreen.main.bounds.height + 100
		)
		
		if dashViewStyle == .default {
			overlayContainerWrappedView.addSubview(dashView)
		}
        
        overlayTranslationView.pinToSuperview(edges: [.bottom])
		
		leftInsetConstraint = overlayTranslationContainerView.leadingAnchor.constraint(
			equalTo: overlayTranslationView.leadingAnchor,
			constant: 0
		)

		rightInsetConstraint = overlayTranslationContainerView.trailingAnchor.constraint(
			equalTo: overlayTranslationView.trailingAnchor,
			constant: 0
		)

		leftInsetConstraint?.isActive = true
		rightInsetConstraint?.isActive = true
		contentMaxHeightConstraint?.isActive = true
		
		overlayContainerWrappedView.clipsToBounds = true
		overlayContainerWrappedView.layer.cornerRadius = cornerRadius
		
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
        translationController?.scheduleOverlayTranslation(
            .toIndex(0),
            velocity: .zero,
            animated: false
        )
    }

    private func loadOverlayViews() {
        guard !viewControllers.isEmpty else { return }
        groundView.isHidden = viewControllers.count == 1
        var truncatedViewControllers = viewControllers
        truncatedViewControllers.popLast().flatMap {
            navControllerTopConstraint = $0.view.topAnchor.constraint(
                equalTo: overlayContainerWrappedView.topAnchor,
                constant: dashViewHeight
            )
            addChild($0)
			overlayContainerWrappedView.addSubview($0.view)
            $0.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                $0.view.leadingAnchor.constraint(
                    equalTo: overlayContainerWrappedView.leadingAnchor
                ),
				$0.view.trailingAnchor.constraint(
					equalTo: overlayContainerWrappedView.trailingAnchor
				),
                $0.view.bottomAnchor.constraint(
                    equalTo: overlayContainerView.bottomAnchor
                ),
                navControllerTopConstraint ?? $0.view.topAnchor.constraint(
                    equalTo: overlayContainerWrappedView.topAnchor
                )
            ])
            $0.didMove(toParent: self)
        }
		navControllerTopConstraint?.isActive = true

        truncatedViewControllers.forEach { addChild($0, in: groundView) }
        loadTranslationDrivers()
    }

    internal func loadTranslationDrivers() {
        guard let translationController = translationController,
            let overlayController = topViewController else {
                return
        }
        translationDrivers.forEach { $0.clean() }
        translationDrivers.removeAll()
        var drivers: [OverlayTranslationDriver] = []
        let panGestureDriver = PanGestureOverlayTranslationDriver(
            translationController: translationController,
            panGestureRecognizer: overlayPanGesture,
			shouldBeginCondition: delegate?.overlayContainerShouldBeginDragging,
			shouldRecognizeSimultaneously: delegate?.overlayContainerShouldRecognizeSimultaneously
        )
        drivers.append(panGestureDriver)
        let scrollView = drivingScrollView ?? configuration.scrollView(drivingOverlay: overlayController)

		if let scrollView = scrollView, let externalScrollViewDelegate {
			overlayPanGesture.drivingScrollView = scrollView
			let driver = ScrollViewOverlayTranslationDriver(
				translationController: translationController,
				scrollView: scrollView,
				externalOverlayScrollViewDelegate: externalScrollViewDelegate
			)
			drivers.append(driver)
		} else if let scrollView = scrollView {
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
        viewIfLoaded?.setNeedsLayout()
    }

    internal func updateOverlayContainerConstraints() {
        switch style {
        case .flexibleHeight:
            overlayContainerViewStyleConstraint?.constant = 0
        case .rigid, .expandableHeight:
			overlayContainerViewStyleConstraint?.constant = configuration.maximumNotchHeight
        }
        translationHeightConstraint?.isActive = true
        overlayContainerViewStyleConstraint?.isActive = true
    }

    private func performDeferredTranslations() {
        translationController?.performDeferredTranslations()
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

    private var overlayPresentationController: OverlayContainerPresentationController? {
        guard isPresentedInsideAnOverlayContainerPresentationController else { return nil }
        return oc_findPresentationController(OverlayContainerPresentationController.self)
    }

    // MARK: - HeightOverlayTranslationControllerDelegate

    func translationController(_ translationController: OverlayTranslationController,
                               didMoveOverlayToNotchAt index: Int) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(self, didMoveOverlay: controller, toNotchAt: index)
        overlayPresentationController?.overlayContainerViewController(
            self,
            didMoveOverlay: controller,
            toNotchAt: index
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willMoveOverlayToNotchAt index: Int) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(self, willMoveOverlay: controller, toNotchAt: index)
        overlayPresentationController?.overlayContainerViewController(
            self,
            willMoveOverlay: controller,
            toNotchAt: index
        )

			hideKeyboardIfNeeded(forNotch: index)
			// TODO: func
			if configuration.heightForNotch(at: index) == 0 {
				self.finalBottomContraintValue = self.translationHeightConstraint?.constant ?? -700
				self.updatePinnedViewConstraints(nil)
			}
    }

    func translationControllerWillStartDraggingOverlay(_ translationController: OverlayTranslationController) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            willStartDraggingOverlay: controller
        )
        overlayPresentationController?.overlayContainerViewController(
            self,
            willStartDraggingOverlay: controller
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willEndDraggingAtVelocity velocity: CGPoint) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(
            self,
            willEndDraggingOverlay: controller,
            atVelocity: velocity
        )
        overlayPresentationController?.overlayContainerViewController(
            self,
            willEndDraggingOverlay: controller,
            atVelocity: velocity
        )
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willTranslateOverlayWith transitionCoordinator: OverlayContainerTransitionCoordinator) {
        guard let controller = topViewController else { return }
		
        if transitionCoordinator.isAnimated {
            overlayTranslationContainerView.layoutIfNeeded()
        }
        transitionCoordinator.animate(alongsideTransition: { [weak self] context in
            self?.updateOverlayContainerConstraints()
            if context is InterruptibleAnimatorOverlayContainerTransitionCoordinator {
							if context.targetTranslationHeight != 0 {
								self?.updatePinnedViewConstraints(nil)
							}
            } else {
                self?.updatePinnedViewConstraints(context)
            }
            self?.overlayTranslationContainerView.layoutIfNeeded()
        }, completion: nil)
        delegate?.overlayContainerViewController(
            self,
            willTranslateOverlay: controller,
            transitionCoordinator: transitionCoordinator
        )
        overlayPresentationController?.overlayContainerViewController(
            self,
            willTranslateOverlay: controller,
            transitionCoordinator: transitionCoordinator
        )
		if transitionCoordinator.isDragging,
			transitionCoordinator.overlayTranslationHeight > configuration.maximumNotchHeight {
			setContentHeight(
				height: transitionCoordinator.overlayTranslationHeight,
				animated: false
			)
		}
    }

    func translationControllerDidScheduleTranslations(_ translationController: OverlayTranslationController) {
        setNeedsOverlayContainerHeightUpdate()
    }

    func overlayViewController(for translationController: OverlayTranslationController) -> UIViewController? {
        return topViewController
    }
}
