//
//  OverlayViewController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 12/11/2018.
//

import UIKit

public class OverlayContainerViewController: UIViewController {

    public enum OverlayStyle {
        case flexibleHeight
        case rigid
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

    public private(set) var style: OverlayStyle

    private lazy var overlayPanGesture: OverlayTranslationGestureRecognizer = self.makePanGesture()
    private lazy var overlayContainerView = OverlayContainerView()
    private lazy var overlayTranslationView = OverlayTranslationView()
    private var overlayContainerViewStyleConstraint: NSLayoutConstraint?
    private var translationHeightConstraint: NSLayoutConstraint?

    private lazy var configuration: OverlayContainerViewControllerConfiguration = self.makeConfiguration()

    private var needsOverlayContainerHeightUpdate = true {
        didSet {
            view.setNeedsLayout()
        }
    }

    private var previousSize: CGSize = .zero
    private var translationController: HeightContrainstOverlayTranslationController?
    private var translationDrivers: [OverlayTranslationDriver] = []

    // MARK: - Life Cycle

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
        guard needsOverlayContainerHeightUpdate else { return }
        needsOverlayContainerHeightUpdate = true
        updateOverlayConstraints(forNew: view.bounds.size)
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateOverlayConstraints(forNew: size)
        }, completion: nil)
    }

    // MARK: - Public

    public func moveOverlay(toNotchAt index: Int, animated: Bool) {
        view.layoutIfNeeded()
        translationController?.moveOverlay(toNotchAt: index, velocity: .zero, animated: animated)
    }

    // MARK: - Private

    private func loadTranslationViews() {
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
        guard let controller = translationController, previousSize != size else {
            return
        }
        previousSize = size
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
        viewControllers.forEach { addChild($0, in: overlayContainerView) }
        loadTranslationDrivers()
    }

    private func loadTranslationDrivers() {
        guard let translationHeightConstraint = translationHeightConstraint,
            let overlayController = topViewController else {
            return
        }
        let controller = HeightContrainstOverlayTranslationController(
            translationHeightConstraint: translationHeightConstraint,
            overlayViewController: overlayController,
            configuration: configuration
        )
        controller.delegate = self
        var drivers: [OverlayTranslationDriver] = []
        let panGestureDriver = PanGestureOverlayTranslationDriver(
            translationController: controller,
            panGestureRecognizer: overlayPanGesture
        )
        drivers.append(panGestureDriver)
        if let scrollView = configuration.scrollView(drivingOverlay: overlayController) {
            overlayPanGesture.drivingScrollView = scrollView
            let driver = ScrollViewOverlayTranslationDriver(
                translationController: controller,
                scrollView: scrollView
            )
            drivers.append(driver)
        }
        translationDrivers = drivers
        translationController = controller
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
            willEndDraggingOverlay: controller,
            endNotchIndex: index,
            transitionCoordinator: transitionCoordinator
        )
    }
}
